import 'package:flutter/material.dart';
import 'create_work_order_header.dart';
import 'section_flight_info.dart';
import 'section_services.dart';
import 'section_notes_and_actions.dart';

// Simple WorkOrder model (replace/use your existing model as needed)
class WorkOrder {
  final String id;
  final String title;
  final String details;
  final String location;
  final String aircraft;
  final String status;
  final String? priority; // Added this field
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> services;
  final Map<String, int> quantities;
  final String notes;

  WorkOrder({
    required this.id,
    required this.title,
    required this.details,
    required this.location,
    required this.aircraft,
    required this.status,
    this.priority = 'Medium', // Default value
    required this.createdAt,
    this.dueDate,
    required this.services,
    required this.quantities,
    required this.notes,
  });
}

class CreateWorkOrderPage extends StatefulWidget {
  final VoidCallback onBack;
  final ValueChanged<WorkOrder> onSave;

  const CreateWorkOrderPage({super.key, required this.onBack, required this.onSave});

  @override
  State<CreateWorkOrderPage> createState() => _CreateWorkOrderPageState();
}

class _CreateWorkOrderPageState extends State<CreateWorkOrderPage> {
  // Controllers for basic flight info
  final _carrierCtl = TextEditingController();
  final _flightNoCtl = TextEditingController();
  final _dateCtl = TextEditingController();
  final _gateCtl = TextEditingController();
  String _aircraftType = '';

  // Services state
  final Map<String, List<String>> _selected = {
    'specialPassengerServices': [],
    'transportServices': [],
    'baggageServices': [],
    'otherServices': [],
  };

  final Map<String, int> _quantities = {};

  DateTime? _dueDate;
  final _notesCtl = TextEditingController();

  @override
  void dispose() {
    _carrierCtl.dispose();
    _flightNoCtl.dispose();
    _dateCtl.dispose();
    _gateCtl.dispose();
    _notesCtl.dispose();
    super.dispose();
  }

  String _generateWoNumber() {
    return (10000 + (DateTime.now().millisecondsSinceEpoch % 90000)).toString();
  }

  void _toggleService(String category, String service, bool checked) {
    setState(() {
      final list = _selected[category]!;
      if (checked) {
        if (!list.contains(service)) list.add(service);
      } else {
        list.remove(service);
        _quantities.remove(service);
      }
    });
  }

  void _setQuantity(String service, int qty) {
    setState(() { _quantities[service] = qty; });
  }

  void _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now.subtract(const Duration(days: 365)), lastDate: now.add(const Duration(days: 365)));
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _reset() {
    setState(() {
      _carrierCtl.clear();
      _flightNoCtl.clear();
      _dateCtl.clear();
      _gateCtl.clear();
      _aircraftType = '';
      _selected.forEach((k, v) => v.clear());
      _quantities.clear();
      _dueDate = null;
      _notesCtl.clear();
    });
  }

  void _submit() {
    final id = _generateWoNumber();
    final title = '${_carrierCtl.text} ${_flightNoCtl.text} - Service Request';
    final allServices = _selected.values.expand((e) => e).toList();
    final wo = WorkOrder(
      id: id,
      title: title,
      details: 'Additional service: ${_carrierCtl.text} ${_flightNoCtl.text}',
      location: _gateCtl.text.isNotEmpty ? 'Gate ${_gateCtl.text}' : 'TBD',
      aircraft: _aircraftType,
      status: 'Open',
      createdAt: DateTime.now(),
      dueDate: _dueDate,
      services: allServices,
      quantities: Map.from(_quantities),
      notes: _notesCtl.text,
    );

    widget.onSave(wo);
  }

  @override
  Widget build(BuildContext context) {
    final workOrderNumber = _generateWoNumber();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CreateWorkOrderHeader(workOrderNumber: workOrderNumber, onBack: widget.onBack, onPickImage: () {}),
          const SizedBox(height: 12),

          // Flight info section
          SectionFlightInfo(
            carrierCtl: _carrierCtl,
            flightNoCtl: _flightNoCtl,
            dateCtl: _dateCtl,
            gateCtl: _gateCtl,
            aircraftType: _aircraftType,
            onAircraftChanged: (v) => setState(() => _aircraftType = v),
            onPickDueDate: _pickDueDate,
            dueDate: _dueDate,
          ),

          const SizedBox(height: 12),

          // All services in single section file
          SectionServices(
            selected: _selected,
            quantities: _quantities,
            onToggle: _toggleService,
            onQuantityChanged: _setQuantity,
          ),

          const SizedBox(height: 12),

          SectionNotesAndActions(
            notesCtl: _notesCtl,
            onReset: _reset,
            onSubmit: _submit,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}