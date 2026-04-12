import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'work_order_approval_page.dart';
import '../dashboard.dart';

class ApprovalListPage extends StatelessWidget {
  final UserInfo? currentUser;

  const ApprovalListPage({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pending Approvals")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('workOrders').where('status', isEqualTo: 'Open').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
             return const Center(child: Text("No pending approvals.", style: TextStyle(color: Colors.grey, fontSize: 16)));
          }

          final docs = snapshot.data!.docs;
          final sortedDocs = docs.toList()..sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            
            DateTime aTime = DateTime.now();
            DateTime bTime = DateTime.now();
            
            if (aData['createdAt'] is Timestamp) aTime = (aData['createdAt'] as Timestamp).toDate();
            if (bData['createdAt'] is Timestamp) bTime = (bData['createdAt'] as Timestamp).toDate();
            
            return bTime.compareTo(aTime); // descending
          });
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDocs.length,
            itemBuilder: (context, index) {
              final data = sortedDocs[index].data() as Map<String, dynamic>;
              final id = data['id']?.toString() ?? sortedDocs[index].id;
              final title = data['title']?.toString() ?? 'Unknown Title';
              final department = data['department']?.toString() ?? 'Unknown Department';
              final subtitle = "Requested by Maintenance ($department)";
              
              return _buildApprovalItem(context, id, title, subtitle, data);
            },
          );
        },
      ),
    );
  }

  Widget _buildApprovalItem(BuildContext context, String id, String title, String subtitle, Map<String, dynamic> data) {
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
        trailing: _buildTrailing(context, id, data),
      ),
    );
  }

  Widget _buildTrailing(BuildContext context, String id, Map<String, dynamic> data) {
    final String? role = currentUser?.role;
    final bool allowed = role != null && (role == 'Supervisor' || role == 'Administrator');
    if (allowed) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WorkOrderApprovalPage(workOrderId: id, currentUser: currentUser, workOrderData: data)),
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