// lib/pages/work_order/new_work_order_form.dart
import 'package:flutter/material.dart';
import 'section_flight_info.dart';
import 'section_services.dart';
import 'section_review.dart';
import 'dart:math';

import '../newworkorders/new_work_order_page.dart' as model; // for WorkOrder type reference if you want

class NewWorkOrderForm extends StatefulWidget {
  final ValueChanged<model.WorkOrder> onSubmit;
  final VoidCallback? onCancel;

  const NewWorkOrderForm({super.key, required this.onSubmit, this.onCancel});

  @override
  State<NewWorkOrderForm> createState() => _NewWorkOrderFormState();
}

class _NewWorkOrderFormState extends State<NewWorkOrderForm> {
  // Stepper state
  int _formStep = 1;
  bool _isSubmitting = false;

  // Flight info
  final _carrierCtl = TextEditingController();
  final _flightNoCtl = TextEditingController();
  final _scheduledTimeCtl = TextEditingController();
  final _gateCtl = TextEditingController();
  String _aircraftType = '';
  DateTime _selectedDate = DateTime.now();

  // Requester info
  final _requestedByCtl = TextEditingController();
  final _contactNumberCtl = TextEditingController();
  String _department = 'Ground Operations';
  String _priority = 'Medium';
  bool _urgentRequest = false;

  // Services state (keys match categories)
  final Map<String, List<String>> _selected = {
    'specialPassengerServices': [],
    'groundSupportServices': [],
    'baggageServices': [],
    'facilityServices': [],
  };
  final Map<String, int> _quantities = {};
  final Map<String, String> _serviceNotes = {};

  // Additional
  String _specialInstructions = '';

  @override
  void dispose() {
    _carrierCtl.dispose();
    _flightNoCtl.dispose();
    _scheduledTimeCtl.dispose();
    _gateCtl.dispose();
    _requestedByCtl.dispose();
    _contactNumberCtl.dispose();
    super.dispose();
  }

  String _generateWorkOrderNumber() {
    final prefix = 'ASD';
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString().substring(9); // last digits
    final rand = Random().nextInt(99).toString().padLeft(2, '0');
    return '$prefix-$timestamp-$rand';
  }

  int _getTotalSelectedServices() => _selected.values.fold(0, (p, e) => p + e.length);

  void _toggleService(String cat, String service, bool checked) {
    setState(() {
      final list = _selected[cat]!;
      if (checked) {
        if (!list.contains(service)) list.add(service);
      } else {
        list.remove(service);
        _quantities.remove(service);
        _serviceNotes.remove(service);
      }
    });
  }

  void _setQuantity(String service, int q) {
    setState(() => _quantities[service] = q);
  }

  void _setNote(String service, String note) {
    setState(() => _serviceNotes[service] = note);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now.subtract(const Duration(days: 365)), lastDate: now.add(const Duration(days: 365)));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _resetForm() {
    setState(() {
      _carrierCtl.clear();
      _flightNoCtl.clear();
      _scheduledTimeCtl.clear();
      _gateCtl.clear();
      _aircraftType = '';
      _selected.forEach((k, v) => v.clear());
      _quantities.clear();
      _serviceNotes.clear();
      _requestedByCtl.clear();
      _contactNumberCtl.clear();
      _department = 'Ground Operations';
      _priority = 'Medium';
      _urgentRequest = false;
      _specialInstructions = '';
      _formStep = 1;
    });
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500)); // simulate network

    final services = _selected.values.expand((e) => e).toList();

    final wo = model.WorkOrder(
      id: _generateWorkOrderNumber(),
      carrier: _carrierCtl.text,
      flightNumber: _flightNoCtl.text,
      aircraftType: _aircraftType,
      gate: _gateCtl.text,
      scheduledTime: _scheduledTimeCtl.text,
      requestedBy: _requestedByCtl.text,
      contactNumber: _contactNumberCtl.text,
      department: _department,
      priority: _priority,
      status: 'Submitted',
      createdAt: DateTime.now().toIso8601String(),
      estimatedCompletionTime: '2-4 hours',
      date: _selectedDate.toIso8601String().split('T').first,
      serviceQuantities: Map.from(_quantities),
      serviceNotes: Map.from(_serviceNotes),
      services: services,
      specialInstructions: _specialInstructions,
    );

    widget.onSubmit(wo);
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final workOrderNumber = _generateWorkOrderNumber();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              const Icon(Icons.file_copy, size: 28, color: Color(0xFF7F1D1D)),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('New Work Order Request', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D))),
                const SizedBox(height: 2),
                const Text('Airport Service Department - Ground Operations', style: TextStyle(color: Colors.grey)),
              ]),
            ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Work Order #', style: TextStyle(color: Colors.grey)),
              Text(workOrderNumber, style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
              const SizedBox(height: 4),
              Text(_selectedDate.toLocal().toString().split(' ')[0], style: const TextStyle(color: Colors.grey)),
            ]),
          ],
        ),
        const SizedBox(height: 12),

        // Progress indicator (simple)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                children: [
                  _stepCircle(1, 'Flight', _formStep >= 1),
                  _line(_formStep >= 2),
                  _stepCircle(2, 'Services', _formStep >= 2),
                  _line(_formStep >= 3),
                  _stepCircle(3, 'Review', _formStep >= 3),
                ],
              ),
              Row(children: [const Icon(Icons.info_outline, color: Colors.orange), const SizedBox(width: 6), Text('${_getTotalSelectedServices()} services selected')]),
            ]),
          ),
        ),
        const SizedBox(height: 12),

        // Body depending on step
        if (_formStep == 1)
          SectionFlightInfo(
            carrierCtl: _carrierCtl,
            flightNoCtl: _flightNoCtl,
            scheduledTimeCtl: _scheduledTimeCtl,
            gateCtl: _gateCtl,
            aircraftType: _aircraftType,
            onAircraftChanged: (v) => setState(() => _aircraftType = v),
            onPickDate: _pickDate,
            selectedDate: _selectedDate,
            requestedByCtl: _requestedByCtl,
            contactNumberCtl: _contactNumberCtl,
            department: _department,
            onDepartmentChanged: (v) => setState(() => _department = v),
            priority: _priority,
            onPriorityChanged: (v) => setState(() => _priority = v),
            urgentRequest: _urgentRequest,
            onUrgentChanged: (v) => setState(() => _urgentRequest = v),
          )
        else if (_formStep == 2)
          SectionServices(
            selected: _selected,
            quantities: _quantities,
            notes: _serviceNotes,
            onToggle: _toggleService,
            onQuantityChanged: _setQuantity,
            onNoteChanged: _setNote,
            onSpecialInstructionsChanged: (v) => setState(() => _specialInstructions = v),
            specialInstructions: _specialInstructions,
          )
        else
          SectionReview(
            carrier: _carrierCtl.text,
            flightNumber: _flightNoCtl.text,
            aircraftType: _aircraftType,
            gate: _gateCtl.text,
            scheduledTime: _scheduledTimeCtl.text,
            requestedBy: _requestedByCtl.text,
            contactNumber: _contactNumberCtl.text,
            department: _department,
            priority: _priority,
            urgentRequest: _urgentRequest,
            selected: _selected,
            quantities: _quantities,
            notes: _serviceNotes,
            specialInstructions: _specialInstructions,
          ),

        const SizedBox(height: 12),

        // Navigator buttons
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          if (_formStep > 1)
            OutlinedButton(onPressed: () => setState(() => _formStep--), child: const Text('Back'))
          else
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
          Row(children: [
            if (_formStep < 3)
              ElevatedButton(
                onPressed: (_formStep == 1 && (_carrierCtl.text.isEmpty || _flightNoCtl.text.isEmpty || _requestedByCtl.text.isEmpty || _contactNumberCtl.text.isEmpty))
                    ? null
                    : () => setState(() => _formStep++),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                child: Text(_formStep == 1 ? 'Continue to Services' : 'Review Request'),
              )
            else
              Row(children: [
                OutlinedButton.icon(onPressed: _resetForm, icon: const Icon(Icons.refresh), label: const Text('Reset Form')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                  child: _isSubmitting ? const SizedBox(width: 120, child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))) : const Text('Submit Work Order'),
                ),
              ])
          ])
        ]),
        const SizedBox(height: 12),

        // Footer card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: const [Icon(Icons.access_time, size: 16), SizedBox(width: 6), Text('Auto-save enabled')]),
              Row(children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 6),
                const Text('Airport Service Department'),
                const SizedBox(width: 12),
                OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.print), label: const Text('Print')),
                const SizedBox(width: 8),
                TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
              ]),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _stepCircle(int n, String label, bool active) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: active ? Colors.red.shade600 : Colors.grey.shade300, shape: BoxShape.circle),
        child: Center(child: Text('$n', style: const TextStyle(color: Colors.white))),
      ),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: active ? Colors.red.shade600 : Colors.grey)),
      const SizedBox(width: 8),
    ]);
  }

  Widget _line(bool active) => Container(width: 36, height: 4, color: active ? Colors.red.shade600 : Colors.grey.shade200);
}
