import 'package:flutter/material.dart';

const Map<String, String> _categoryTitles = {
  'specialPassengerServices': 'Special Passenger Services',
  'groundSupportServices': 'Ground Support Services',
  'baggageServices': 'Baggage & Cargo Services',
  'facilityServices': 'Facility & Infrastructure',
};

const Map<String, List<String>> _serviceOptions = {
  'specialPassengerServices': ['Unaccompanied Minor Assistance', 'Wheelchair Service - Ramp to Seat', 'Medical Assistance', 'VIP/CIP Lounge Access'],
  'groundSupportServices': ['Ground Power Unit (GPU)', 'Air Conditioning Unit', 'Aircraft Pushback', 'De-icing Services', 'Fuel Services Coordination'],
  'baggageServices': ['Priority Baggage Handling', 'Oversize Baggage Processing', 'Baggage Reconciliation'],
  'facilityServices': ['Gate Assignment Coordination', 'Terminal Cleaning'],
};

class SectionServices extends StatelessWidget {
  final Map<String, List<String>> selected;
  final Map<String, int> quantities;
  final TextEditingController specialInstructionsCtl;
  final Function(String cat, String service, bool val) onToggle;
  final Function(String service, int val) onQuantityChanged;

  const SectionServices({
    super.key,
    required this.selected,
    required this.quantities,
    required this.specialInstructionsCtl,
    required this.onToggle,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text("Service Categories", style: TextStyle(fontWeight: FontWeight.bold)),
        const Text("Select required services. You can specify quantities.", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 16),
        
        ..._categoryTitles.keys.map((catKey) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ExpansionTile(
              title: Text(_categoryTitles[catKey]!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFB71C1C))),
              trailing: Text("${selected[catKey]?.length ?? 0} selected", style: const TextStyle(fontSize: 12, color: Colors.grey)),
              initiallyExpanded: true,
              children: _serviceOptions[catKey]!.map((service) {
                final isSelected = selected[catKey]!.contains(service);
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  leading: Checkbox(
                    value: isSelected,
                    activeColor: const Color(0xFFB71C1C),
                    onChanged: (v) => onToggle(catKey, service, v ?? false),
                  ),
                  title: Text(service, style: const TextStyle(fontSize: 13)),
                  trailing: isSelected
                      ? SizedBox(
                          width: 60,
                          height: 30,
                          child: TextFormField(
                            initialValue: (quantities[service] ?? 1).toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8), border: OutlineInputBorder()),
                            onChanged: (v) => onQuantityChanged(service, int.tryParse(v) ?? 1),
                          ),
                        )
                      : null,
                );
              }).toList(),
            ),
          );
        }),

        const SizedBox(height: 16),
        const Text("Additional Instructions", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: specialInstructionsCtl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: "Provide any specific instructions...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}