import 'package:flutter/material.dart';

const Map<String, List<String>> _serviceCategories = {
  'specialPassengerServices': [
    'Unaccompanied Minor/Young Passenger',
    'Elderly/Unsteadying Passenger',
    'MAAS (Meet and Assist)',
    'VIP or any other person via SriLankan Lounge',
    'Wheelchair (Cabin/Lavatory/Seat)',
    'VIP/CIP or any other person via Private lounge',
    'Incap (requiring wheelchair)',
    'Incap requiring Stretcher',
  ],
  'transportServices': [
    'Coach to transport passenger/crew/staff (Large coach)',
    'From Airport to terminal or vice versa (Small coach)'
  ],
  'baggageServices': [
    'Passenger/Baggage Reconciliation (BRS)',
    'Baggage ID - Interline only',
    'Baggage ID - Joining & Interline',
    'Baggage ID - Transit and/or Joining',
    'Gate checks'
  ],
  'otherServices': [
    'FOD (Foreign Object Detection)',
    'Area Cap (Area Capacity Management)'
  ]
};

class SectionServices extends StatelessWidget {
  final Map<String, List<String>> selected;
  final Map<String, int> quantities;
  final void Function(String category, String service, bool checked) onToggle;
  final void Function(String service, int qty) onQuantityChanged;

  const SectionServices({Key? key, required this.selected, required this.quantities, required this.onToggle, required this.onQuantityChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _serviceCategories.entries.map((entry) {
        final cat = entry.key;
        final title = _sectionTitle(cat);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(spacing: 12, runSpacing: 8, children: entry.value.map((service) {
                final checked = selected[cat]!.contains(service);
                return SizedBox(
                  width: 400,
                  child: Row(children: [
                    Checkbox(value: checked, onChanged: (v) => onToggle(cat, service, v ?? false)),
                    Expanded(child: Text(service)),
                    if (checked)
                      SizedBox(width: 80, child: TextFormField(initialValue: quantities[service]?.toString() ?? '', keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'Qty'), onChanged: (s) => onQuantityChanged(service, int.tryParse(s) ?? 0),),)
                  ]),
                );
              }).toList()),
            ]),
          ),
        );
      }).toList(),
    );
  }

  String _sectionTitle(String key) {
    switch (key) {
      case 'specialPassengerServices':
        return 'Special Passenger Services';
      case 'transportServices':
        return 'Transport Services';
      case 'baggageServices':
        return 'Baggage Reconciliation/Identification Services';
      case 'otherServices':
        return 'Other Services';
      default:
        return key;
    }
  }
}
