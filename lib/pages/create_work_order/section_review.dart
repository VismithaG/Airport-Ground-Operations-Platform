import 'package:flutter/material.dart';

class SectionReview extends StatelessWidget {
  final String carrier;
  final String flightNo;
  final String aircraft;
  final String gate;
  final Map<String, List<String>> selectedServices;
  final Map<String, int> quantities;
  final String specialInstructions;

  const SectionReview({
    super.key,
    required this.carrier,
    required this.flightNo,
    required this.aircraft,
    required this.gate,
    required this.selectedServices,
    required this.quantities,
    required this.specialInstructions,
  });

  @override
  Widget build(BuildContext context) {
    final allServices = selectedServices.values.expand((e) => e).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: const [
          Icon(Icons.check_circle_outline, color: Colors.grey),
          SizedBox(width: 8),
          Text("Review Your Request", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ]),
        const SizedBox(height: 20),
        
        // Flight Info Summary
        const Text("Flight Information", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _summaryItem("Airline/Carrier", carrier),
              _summaryItem("Flight Number", flightNo),
              _summaryItem("Aircraft", aircraft),
              _summaryItem("Gate", gate),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text("Requested Services", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
          child: Column(
            children: allServices.isEmpty 
              ? [const Padding(padding: EdgeInsets.all(16), child: Text("No services selected"))]
              : allServices.map((s) => ListTile(
                  dense: true,
                  title: Text(s),
                  trailing: Text("Qty: ${quantities[s] ?? 1}", style: const TextStyle(color: Colors.grey)),
                )).toList(),
          ),
        ),

        if (specialInstructions.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text("Special Instructions", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(specialInstructions, style: const TextStyle(color: Colors.grey)),
        ]
      ],
    );
  }

  Widget _summaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value.isEmpty ? "-" : value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}