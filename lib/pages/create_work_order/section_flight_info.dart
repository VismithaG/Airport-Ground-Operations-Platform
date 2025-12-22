import 'package:flutter/material.dart';

class SectionFlightInfo extends StatelessWidget {
  final TextEditingController carrierCtl;
  final TextEditingController flightNoCtl;
  final TextEditingController dateCtl;
  final TextEditingController gateCtl;
  final String aircraftType;
  final ValueChanged<String> onAircraftChanged;
  final VoidCallback onPickDueDate;
  final DateTime? dueDate;

  const SectionFlightInfo({
    super.key,
    required this.carrierCtl,
    required this.flightNoCtl,
    required this.dateCtl,
    required this.gateCtl,
    required this.aircraftType,
    required this.onAircraftChanged,
    required this.onPickDueDate,
    required this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Flight Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D))),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;
              if (isNarrow) {
                // stacked full-width inputs for narrow screens
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(controller: carrierCtl, decoration: const InputDecoration(labelText: 'Carrier')),
                    const SizedBox(height: 8),
                    TextField(controller: flightNoCtl, decoration: const InputDecoration(labelText: 'Flight No.')),
                    const SizedBox(height: 8),
                    TextField(controller: dateCtl, decoration: const InputDecoration(labelText: 'Date')),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: aircraftType.isEmpty ? null : aircraftType,
                      items: const [
                        DropdownMenuItem(value: 'A330', child: Text('A330')),
                        DropdownMenuItem(value: 'A350', child: Text('A350')),
                        DropdownMenuItem(value: 'A380', child: Text('A380')),
                        DropdownMenuItem(value: 'B777', child: Text('B777')),
                      ],
                      onChanged: (String? value) {
                        if (value != null) onAircraftChanged(value);
                      },
                      decoration: const InputDecoration(labelText: 'Aircraft Type'),
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: gateCtl, decoration: const InputDecoration(labelText: 'Gate No.')),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(onPressed: onPickDueDate, icon: const Icon(Icons.calendar_today), label: Text(dueDate == null ? 'Pick Due Date' : dueDate!.toLocal().toIso8601String().split('T').first)),
                  ],
                );
              }

              // wider screens: use horizontal wrap with constrained widths
              final leftWidth = (constraints.maxWidth / 2) - 16;
              return Wrap(spacing: 8, runSpacing: 8, children: [
                SizedBox(width: leftWidth * 0.9.clamp(180, leftWidth), child: TextField(controller: carrierCtl, decoration: const InputDecoration(labelText: 'Carrier'))),
                SizedBox(width: leftWidth * 0.65.clamp(120, leftWidth), child: TextField(controller: flightNoCtl, decoration: const InputDecoration(labelText: 'Flight No.'))),
                SizedBox(width: 140, child: TextField(controller: dateCtl, decoration: const InputDecoration(labelText: 'Date'))),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String>(
                    initialValue: aircraftType.isEmpty ? null : aircraftType,
                    items: const [
                      DropdownMenuItem(value: 'A330', child: Text('A330')),
                      DropdownMenuItem(value: 'A350', child: Text('A350')),
                      DropdownMenuItem(value: 'A380', child: Text('A380')),
                      DropdownMenuItem(value: 'B777', child: Text('B777')),
                    ],
                    onChanged: (String? value) {
                      if (value != null) onAircraftChanged(value);
                    },
                    decoration: const InputDecoration(labelText: 'Aircraft Type'),
                  ),
                ),
                SizedBox(width: 120, child: TextField(controller: gateCtl, decoration: const InputDecoration(labelText: 'Gate No.'))),
                SizedBox(
                  width: 160,
                  child: OutlinedButton.icon(
                    onPressed: onPickDueDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(dueDate == null ? 'Pick Due Date' : dueDate!.toLocal().toIso8601String().split('T').first),
                  ),
                ),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}