import 'package:flutter/material.dart';
import 'work_order_approval_page.dart';

class ApprovalListPage extends StatelessWidget {
  final String? currentUserRole;

  const ApprovalListPage({super.key, this.currentUserRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Approvals")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildApprovalItem(context, "ASD-1234564", "Emirates EK 650", "Requested by Vismitha"),
          _buildApprovalItem(context, "ASD-9988771", "Sri Lankan UL 504", "Requested by Maintenance Team"),
          _buildApprovalItem(context, "ASD-4455662", "Qatar Airways QR 220", "Requested by Cargo Ops"),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(BuildContext context, String id, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.orange.shade100,
          child: const Icon(Icons.history_edu, color: Colors.orange),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(subtitle),
          ],
        ),
        trailing: _buildTrailing(context, id),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, String id) {
    final bool allowed = currentUserRole != null && (currentUserRole == 'Supervisor' || currentUserRole == 'Administrator');
    if (allowed) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkOrderApprovalPage(workOrderId: id, currentUserRole: currentUserRole)),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
        child: const Text("Review"),
      );
    }

    return OutlinedButton(
      onPressed: null,
      child: const Text("No Access"),
    );
  }
}