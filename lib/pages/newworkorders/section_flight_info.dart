// lib/pages/work_order/section_flight_info.dart
import 'package:flutter/material.dart';

class SectionFlightInfo extends StatelessWidget {
  final TextEditingController carrierCtl;
  final TextEditingController flightNoCtl;
  final TextEditingController scheduledTimeCtl;
  final TextEditingController gateCtl;
  final String aircraftType;
  final ValueChanged<String> onAircraftChanged;
  final VoidCallback onPickDate;
  final DateTime selectedDate;
  final TextEditingController requestedByCtl;
  final TextEditingController contactNumberCtl;
  final String department;
  final ValueChanged<String> onDepartmentChanged;
  final String priority;
  final ValueChanged<String> onPriorityChanged;
  final bool urgentRequest;
  final ValueChanged<bool> onUrgentChanged;

  const SectionFlightInfo({
    super.key,
    required this.carrierCtl,
    required this.flightNoCtl,
    required this.scheduledTimeCtl,
    required this.gateCtl,
    required this.aircraftType,
    required this.onAircraftChanged,
    required this.onPickDate,
    required this.selectedDate,
    required this.requestedByCtl,
    required this.contactNumberCtl,
    required this.department,
    required this.onDepartmentChanged,
    required this.priority,
    required this.onPriorityChanged,
    required this.urgentRequest,
    required this.onUrgentChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [Icon(Icons.flight_takeoff, color: Colors.blue), SizedBox(width: 8), Text('Flight Information', style: TextStyle(fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              SizedBox(width: 260, child: TextField(controller: carrierCtl, decoration: const InputDecoration(labelText: 'Airline/Carrier *'))),
              SizedBox(width: 180, child: TextField(controller: flightNoCtl, decoration: const InputDecoration(labelText: 'Flight Number *'))),
              SizedBox(width: 180, child: TextField(controller: scheduledTimeCtl, decoration: const InputDecoration(labelText: 'Scheduled Time'))),
              SizedBox(width: 140, child: TextField(controller: gateCtl, decoration: const InputDecoration(labelText: 'Gate Assignment'))),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: aircraftType.isEmpty ? null : aircraftType,
                  decoration: const InputDecoration(labelText: 'Aircraft Type'),
                  onChanged: (v) => onAircraftChanged(v ?? ''),
                  items: const [
                    DropdownMenuItem(value: 'A320', child: Text('Airbus A320')),
                    DropdownMenuItem(value: 'A330', child: Text('Airbus A330')),
                    DropdownMenuItem(value: 'A350', child: Text('Airbus A350')),
                    DropdownMenuItem(value: 'A380', child: Text('Airbus A380')),
                    DropdownMenuItem(value: 'B737', child: Text('Boeing 737')),
                    DropdownMenuItem(value: 'B777', child: Text('Boeing 777')),
                    DropdownMenuItem(value: 'B787', child: Text('Boeing 787')),
                  ],
                ),
              ),
              SizedBox(width: 160, child: OutlinedButton(onPressed: onPickDate, child: Text(selectedDate.toLocal().toString().split(' ')[0]))),
            ]),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [Icon(Icons.person, color: Colors.green), SizedBox(width: 8), Text('Request Information', style: TextStyle(fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              SizedBox(width: 260, child: TextField(controller: requestedByCtl, decoration: const InputDecoration(labelText: 'Requested By *'))),
              SizedBox(width: 180, child: TextField(controller: contactNumberCtl, decoration: const InputDecoration(labelText: 'Contact Number *'))),
              SizedBox(
                width: 240,
                child: DropdownButtonFormField<String>(
                  initialValue: department,
                  decoration: const InputDecoration(labelText: 'Department'),
                  onChanged: (v) => onDepartmentChanged(v ?? ''),
                  items: const [
                    DropdownMenuItem(value: 'Ground Operations', child: Text('Ground Operations')),
                    DropdownMenuItem(value: 'Passenger Services', child: Text('Passenger Services')),
                    DropdownMenuItem(value: 'Ramp Services', child: Text('Ramp Services')),
                    DropdownMenuItem(value: 'Cargo Operations', child: Text('Cargo Operations')),
                    DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                  ],
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: priority,
                  decoration: const InputDecoration(labelText: 'Priority Level'),
                  onChanged: (v) => onPriorityChanged(v ?? ''),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low - Standard processing')),
                    DropdownMenuItem(value: 'Medium', child: Text('Medium - Expedited')),
                    DropdownMenuItem(value: 'High', child: Text('High - Urgent')),
                    DropdownMenuItem(value: 'Critical', child: Text('Critical - Immediate')),
                  ],
                ),
              ),
              Row(children: [
                Checkbox(value: urgentRequest, onChanged: (v) => onUrgentChanged(v ?? false)),
                const SizedBox(width: 6),
                const Text('This is an urgent request requiring immediate attention'),
              ]),
            ]),
          ]),
        ),
      ),
    ]);
  }
}
