import 'package:flutter/material.dart';
import 'dart:math';
import 'section_flight_info.dart';
import 'section_services.dart';
import 'section_review.dart'; // We will create this file below

// --- Work Order Model ---
class WorkOrder {
  final String id;
  final String title;
  final String aircraft;
  final String status;
  final String priority;
  final DateTime createdAt;
  final List<String> services;

  WorkOrder({
    required this.id,
    required this.title,
    required this.aircraft,
    required this.status,
    required this.priority,
    required this.createdAt,
    required this.services,
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
  int _currentStep = 1;
  bool _isSubmitted = false;
  
  // --- Form State ---
  // Flight Info
  final _carrierCtl = TextEditingController();
  final _flightNoCtl = TextEditingController();
  final _timeCtl = TextEditingController();
  final _gateCtl = TextEditingController();
  String _aircraftType = 'A330'; // Default
  DateTime _serviceDate = DateTime.now();

  // Request Info
  final _requestedByCtl = TextEditingController();
  final _contactCtl = TextEditingController();
  String _department = 'Ground Operations';
  String _priority = 'Medium';

  // Services
  final Map<String, List<String>> _selectedServices = {
    'specialPassengerServices': [],
    'groundSupportServices': [],
    'baggageServices': [],
    'facilityServices': [],
  };
  final Map<String, int> _quantities = {};
  final TextEditingController _specialInstructionsCtl = TextEditingController();

  final String _workOrderId = "ASD-${Random().nextInt(99999).toString().padLeft(5, '0')}";

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildSuccessScreen();
    }

    // Constrain the card height so inner Expanded/Scroll has bounded height
    final double maxCardHeight = MediaQuery.of(context).size.height * 0.9;

    return Scaffold(
      backgroundColor: Colors.black.withAlpha((0.05 * 255).round()), // Light grey background like Figma
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 600, maxHeight: maxCardHeight), // Constrain width/height for "Page" look
          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withAlpha((0.1 * 255).round()), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const Divider(height: 1),
              _buildStepper(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildCurrentStepContent(),
                ),
              ),
              _buildFooterActions(),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Components ---

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
            child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFB71C1C).withAlpha((0.1 * 255).round()),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.assignment_add, color: Color(0xFFB71C1C)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("New Work Order\nRequest", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.1)),
                const SizedBox(height: 4),
                Text("Airport Service Department - Ground Operations", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Work Order # $_workOrderId", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text("${_serviceDate.day}-${_getMonth(_serviceDate.month)}-${_serviceDate.year}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
      color: const Color(0xFFFAFAFA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _stepItem(1, "Flight Info"),
          _stepLine(1),
          _stepItem(2, "Services"),
          _stepLine(2),
          _stepItem(3, "Review"),
        ],
      ),
    );
  }

  Widget _stepItem(int step, String label) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFB71C1C) : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(step.toString(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? (isCurrent ? Colors.black87 : Colors.black54) : Colors.grey,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(int stepAfter) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: _currentStep > stepAfter ? const Color(0xFFB71C1C) : Colors.grey[300],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 1:
        return SectionFlightInfo(
          carrierCtl: _carrierCtl,
          flightNoCtl: _flightNoCtl,
          timeCtl: _timeCtl,
          gateCtl: _gateCtl,
          aircraftType: _aircraftType,
          onAircraftChanged: (v) => setState(() => _aircraftType = v),
          onPickDate: () async {
            final d = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
            if (d != null) setState(() => _serviceDate = d);
          },
          serviceDate: _serviceDate,
          requestedByCtl: _requestedByCtl,
          contactCtl: _contactCtl,
          department: _department,
          onDepartmentChanged: (v) => setState(() => _department = v!),
          priority: _priority,
          onPriorityChanged: (v) => setState(() => _priority = v!),
        );
      case 2:
        return SectionServices(
          selected: _selectedServices,
          quantities: _quantities,
          specialInstructionsCtl: _specialInstructionsCtl,
          onToggle: (cat, service, val) {
            setState(() {
              if (val) {
                if (!_selectedServices[cat]!.contains(service)) _selectedServices[cat]!.add(service);
              } else {
                _selectedServices[cat]!.remove(service);
                _quantities.remove(service);
              }
            });
          },
          onQuantityChanged: (service, val) => setState(() => _quantities[service] = val),
        );
      case 3:
        return SectionReview(
          carrier: _carrierCtl.text,
          flightNo: _flightNoCtl.text,
          aircraft: _aircraftType,
          gate: _gateCtl.text,
          selectedServices: _selectedServices,
          quantities: _quantities,
          specialInstructions: _specialInstructionsCtl.text,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFooterActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep == 1)
            TextButton(onPressed: widget.onBack, child: const Text("Cancel", style: TextStyle(color: Colors.grey)))
          else
            OutlinedButton(
              onPressed: () => setState(() => _currentStep--),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.black87),
              child: const Text("Back"),
            ),
          
          ElevatedButton(
            onPressed: () {
              if (_currentStep < 3) {
                setState(() => _currentStep++);
              } else {
                setState(() => _isSubmitted = true);
                widget.onSave(WorkOrder(
                  id: _workOrderId,
                  title: "${_carrierCtl.text} ${_flightNoCtl.text}",
                  aircraft: _aircraftType,
                  status: "Submitted",
                  priority: _priority,
                  createdAt: DateTime.now(),
                  services: _selectedServices.values.expand((e) => e).toList(),
                ));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB71C1C),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(_currentStep == 3 ? "Submit Work Order" : "Continue"),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 24),
              const Text("Work Order Submitted\nSuccessfully", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              const SizedBox(height: 16),
              const Text("Your request has been received and will be processed by the appropriate service teams.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Reset
                    setState(() {
                      _currentStep = 1;
                      _isSubmitted = false;
                      _carrierCtl.clear();
                      _flightNoCtl.clear();
                      // ... clear others
                    });
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white, padding: const EdgeInsets.all(16)),
                  child: const Text("Create Another Work Order"),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: widget.onBack, child: const Text("Back to Dashboard"))
            ],
          ),
        ),
      ),
    );
  }

  String _getMonth(int m) => ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][m-1];
}