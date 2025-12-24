import 'package:flutter/material.dart';

class SectionNotesAndActions extends StatelessWidget {
  final TextEditingController notesCtl;
  final VoidCallback onReset;
  final VoidCallback onSubmit;

  const SectionNotesAndActions({super.key, required this.notesCtl, required this.onReset, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(controller: notesCtl, maxLines: 4, decoration: const InputDecoration(hintText: 'Confirm the services provided above have been received...')),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            OutlinedButton(onPressed: onReset, child: Row(children: const [Icon(Icons.close), SizedBox(width: 6), Text('Reset Form')])) ,
            const SizedBox(width: 8),
            ElevatedButton(onPressed: onSubmit, child: Row(children: const [Icon(Icons.save), SizedBox(width: 6), Text('Submit Service Request')]))
          ])
        ]),
      ),
    );
  }
}