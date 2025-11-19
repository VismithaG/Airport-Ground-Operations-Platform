// lib/pages/work_order/section_review.dart
import 'package:flutter/material.dart';

class SectionReview extends StatelessWidget {
  final String carrier;
  final String flightNumber;
  final String aircraftType;
  final String gate;
  final String scheduledTime;
  final String requestedBy;
  final String contactNumber;
  final String department;
  final String priority;
  final bool urgentRequest;
  final Map<String, List<String>> selected;
  final Map<String, int> quantities;
  final Map<String, String> notes;
  final String specialInstructions;

  const SectionReview({
    super.key,
    required this.carrier,
    required this.flightNumber,
    required this.aircraftType,
    required this.gate,
    required this.scheduledTime,
    required this.requestedBy,
    required this.contactNumber,
    required this.department,
    required this.priority,
    required this.urgentRequest,
    required this.selected,
    required this.quantities,
    required this.notes,
    required this.specialInstructions,
  });

  @override
  Widget build(BuildContext context) {
    Widget _serviceSummaryTile(String service) {
      final qty = quantities[service];
      final note = notes[service];
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(service)),
          Row(children: [
            if (qty != null) Chip(label: Text('Qty: $qty')),
            if (note != null && note.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 8), child: Text('Note: $note', style: const TextStyle(color: Colors.grey, fontSize: 12))),
          ]),
        ]),
      );
    }

    final selectedServices = selected.values.expand((e) => e).toList();

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [Icon(Icons.check_circle, color: Colors.orange), SizedBox(width: 8), Text('Review Your Request', style: TextStyle(fontWeight: FontWeight.w600))]),
            const SizedBox(height: 12),
            const Text('Flight Information', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(width: 220, child: _labelValue('Carrier', carrier)),
              SizedBox(width: 180, child: _labelValue('Flight', flightNumber)),
              SizedBox(width: 180, child: _labelValue('Aircraft', aircraftType.isEmpty ? 'Not specified' : aircraftType)),
              SizedBox(width: 160, child: _labelValue('Gate', gate.isEmpty ? 'TBD' : gate)),
            ]),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            const Text('Requested Services', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            if (selectedServices.isEmpty) const Text('No services selected', style: TextStyle(color: Colors.grey))
            else Column(children: selectedServices.map((s) => _serviceSummaryTile(s)).toList()),
            if (specialInstructions.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text('Special Instructions', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(6)), child: Text(specialInstructions)),
            ],
          ]),
        ),
      ),
    ]);
  }

  static Widget _labelValue(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    ]);
  }
}
