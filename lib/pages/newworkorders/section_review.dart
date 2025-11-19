// lib/pages/work_order/section_services.dart
import 'package:flutter/material.dart';

const Map<String, Map<String, dynamic>> _serviceDefinitions = {
  'specialPassengerServices': {
    'title': 'Special Passenger Services',
    'subtitle': 'Passenger assistance and accommodation',
    'services': [
      'Unaccompanied Minor Assistance',
      'Wheelchair Service - Ramp to Seat',
      'Wheelchair Service - Ramp to Aircraft',
      'Medical Assistance',
      'VIP/CIP Lounge Access',
      'Special Dietary Requirements',
      'Pet Transportation Services',
      'Elderly Passenger Assistance',
    ],
  },
  'groundSupportServices': {
    'title': 'Ground Support Services',
    'subtitle': 'Aircraft and equipment support',
    'services': [
      'Ground Power Unit (GPU)',
      'Air Conditioning Unit',
      'Aircraft Pushback',
      'De-icing Services',
      'Fuel Services Coordination',
      'Cargo Loading Equipment',
      'Passenger Stairs',
      'Aircraft Cleaning',
    ],
  },
  'baggageServices': {
    'title': 'Baggage & Cargo Services',
    'subtitle': 'Baggage handling and processing',
    'services': [
      'Priority Baggage Handling',
      'Oversize Baggage Processing',
      'Baggage Reconciliation',
      'Lost Baggage Investigation',
      'Cargo Documentation',
      'Hazardous Materials Handling',
      'Customs Coordination',
      'Transfer Baggage Processing',
    ],
  },
  'facilityServices': {
    'title': 'Facility & Infrastructure',
    'subtitle': 'Terminal and ground facility services',
    'services': [
      'Gate Assignment Coordination',
      'Jetbridge Operation',
      'Terminal Cleaning',
      'Security Coordination',
      'Ground Transportation',
      'Facility Maintenance',
      'Equipment Repair Request',
      'Emergency Services Coordination',
    ],
  }
};

class SectionServices extends StatelessWidget {
  final Map<String, List<String>> selected;
  final Map<String, int> quantities;
  final Map<String, String> notes;
  final void Function(String category, String service, bool checked) onToggle;
  final void Function(String service, int qty) onQuantityChanged;
  final void Function(String service, String note) onNoteChanged;
  final void Function(String) onSpecialInstructionsChanged;
  final String specialInstructions;

  const SectionServices({
    super.key,
    required this.selected,
    required this.quantities,
    required this.notes,
    required this.onToggle,
    required this.onQuantityChanged,
    required this.onNoteChanged,
    required this.onSpecialInstructionsChanged,
    required this.specialInstructions,
  });

  Widget _serviceTile(BuildContext context, String catKey, String service) {
    final isSelected = selected[catKey]!.contains(service);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Checkbox(value: isSelected, onChanged: (v) => onToggle(catKey, service, v ?? false)),
          Expanded(child: Text(service)),
        ]),
        if (isSelected)
          Padding(
            padding: const EdgeInsets.only(left: 40.0, top: 6, bottom: 6),
            child: Row(children: [
              SizedBox(
                width: 110,
                child: TextFormField(
                  initialValue: quantities[service]?.toString() ?? '',
                  onChanged: (s) => onQuantityChanged(service, int.tryParse(s) ?? 1),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Qty'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: notes[service] ?? '',
                  onChanged: (s) => onNoteChanged(service, s),
                  decoration: const InputDecoration(labelText: 'Special notes'),
                ),
              ),
            ]),
          ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _serviceDefinitions.entries.map((entry) {
        final catKey = entry.key;
        final meta = entry.value;
        final services = (meta['services'] as List).cast<String>();
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(meta['title'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(meta['subtitle'] as String, style: const TextStyle(color: Colors.grey)),
                ]),
                Chip(label: Text('${selected[catKey]!.length} selected')),
              ]),
              const SizedBox(height: 12),
              Column(children: services.map((s) => _serviceTile(context, catKey, s)).toList()),
            ]),
          ),
        );
      }).toList(),
    );
  }
}
