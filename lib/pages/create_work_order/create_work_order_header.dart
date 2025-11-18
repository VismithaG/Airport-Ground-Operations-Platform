import 'package:flutter/material.dart';

class CreateWorkOrderHeader extends StatelessWidget {
  final String workOrderNumber;
  final VoidCallback onBack;
  final VoidCallback onPickImage;

  const CreateWorkOrderHeader({Key? key, required this.workOrderNumber, required this.onBack, required this.onPickImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Row(
            children: [
              OutlinedButton.icon(onPressed: onBack, icon: const Icon(Icons.arrow_left), label: const Text('Back to Work Orders')),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Additional Service Work Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7F1D1D))),
                  SizedBox(height: 4),
                  Text('Based on Airport Service Department form template', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('No. $workOrderNumber', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onPickImage,
              child: Container(
                width: 120,
                height: 72,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: const Center(child: Icon(Icons.photo, color: Colors.grey)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}