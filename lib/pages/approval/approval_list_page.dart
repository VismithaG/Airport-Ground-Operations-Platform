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
      appBar: AppBar(title: const Text("Approval Management")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('workOrders')
            .where('status', whereIn: ['Open', 'Approved', 'Rejected'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No records found.",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final pendingDocs = <DocumentSnapshot>[];
          final historyDocs = <DocumentSnapshot>[];

          for (final doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'Open') {
              pendingDocs.add(doc);
            } else {
              historyDocs.add(doc);
            }
          }

          int sortDocs(DocumentSnapshot a, DocumentSnapshot b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            DateTime aTime = DateTime.now();
            DateTime bTime = DateTime.now();
            if (aData['createdAt'] is Timestamp) {
              aTime = (aData['createdAt'] as Timestamp).toDate();
            }
            if (bData['createdAt'] is Timestamp) {
              bTime = (bData['createdAt'] as Timestamp).toDate();
            }
            return bTime.compareTo(aTime);
          }

          pendingDocs.sort(sortDocs);
          historyDocs.sort(sortDocs);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show a critical notification banner if there are critical pending WOs
                Builder(builder: (ctx) {
                  final criticalCount = pendingDocs.where((doc) {
                    final d = doc.data() as Map<String, dynamic>;
                    return (d['priority']?.toString().toLowerCase() == 'critical') && (d['status'] == 'Open');
                  }).length;

                  if (criticalCount > 0) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        border: Border.all(color: Colors.red.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '$criticalCount critical work order(s) require immediate attention.',
                              style: TextStyle(color: Colors.red.shade800, fontWeight: FontWeight.bold),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              final criticalDocs = pendingDocs.where((doc) {
                                final d = doc.data() as Map<String, dynamic>;
                                return d['priority']?.toString().toLowerCase() == 'critical';
                              }).toList();

                              showDialog(
                                context: ctx,
                                builder: (dialogCtx) {
                                  return AlertDialog(
                                    title: const Text('Critical Work Orders'),
                                    content: Container(
                                      width: double.maxFinite,
                                      constraints: const BoxConstraints(maxHeight: 400),
                                      child: ListView.separated(
                                        shrinkWrap: true,
                                        itemCount: criticalDocs.length,
                                        separatorBuilder: (context, index) => const Divider(),
                                        itemBuilder: (dCtx, i) {
                                          final doc = criticalDocs[i];
                                          final data = doc.data() as Map<String, dynamic>;
                                          final id = data['id']?.toString() ?? doc.id;
                                          final title = data['title']?.toString() ?? 'Untitled';
                                          return ListTile(
                                            tileColor: Colors.red.shade50,
                                            leading: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
                                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            subtitle: Text(id),
                                            trailing: ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                                              onPressed: () {
                                                // Close the dialog then navigate immediately to avoid using
                                                // the build context across async gaps. Marking notifications
                                                // as read is performed asynchronously afterwards.
                                                Navigator.of(dialogCtx).pop();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => WorkOrderApprovalPage(
                                                      workOrderId: id,
                                                      currentUser: currentUser,
                                                      workOrderData: data,
                                                    ),
                                                  ),
                                                );

                                                // Mark any related supervisor notifications as read (async, no context use)
                                                FirebaseFirestore.instance
                                                    .collection('notifications')
                                                    .where('workOrderId', isEqualTo: id)
                                                    .where('targetRole', isEqualTo: 'Supervisor')
                                                    .where('read', isEqualTo: false)
                                                    .get()
                                                    .then((snap) {
                                                  for (final n in snap.docs) {
                                                    n.reference.update({
                                                      'read': true,
                                                      'readAt': FieldValue.serverTimestamp(),
                                                    });
                                                  }
                                                }).catchError((e) {
                                                  debugPrint('Failed to mark notifications read: $e');
                                                });
                                              },
                                              child: const Text('Review'),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: const Text('Close')),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Text('View'),
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                }),

                const Text(
                  "Pending Approvals",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (pendingDocs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No pending approvals.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: pendingDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          pendingDocs[index].data() as Map<String, dynamic>;
                      final id =
                          data['id']?.toString() ?? pendingDocs[index].id;
                      final title =
                          data['title']?.toString() ?? 'Unknown Title';
                      final department =
                          data['department']?.toString() ??
                          'Unknown Department';
                      return _buildApprovalItem(
                        context,
                        id,
                        title,
                        "Requested by Maintenance ($department)",
                        data,
                      );
                    },
                  ),

                const SizedBox(height: 32),

                const Text(
                  "Approval History",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                if (historyDocs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      "No historical records yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: historyDocs.length,
                    itemBuilder: (context, index) {
                      final data =
                          historyDocs[index].data() as Map<String, dynamic>;
                      final id =
                          data['id']?.toString() ?? historyDocs[index].id;
                      final title =
                          data['title']?.toString() ?? 'Unknown Title';
                      final supervisor =
                          data['supervisorName']?.toString() ??
                          'Unknown Supervisor';
                      return _buildApprovalItem(
                        context,
                        id,
                        title,
                        "Processed by $supervisor",
                        data,
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApprovalItem(
    BuildContext context,
    String id,
    String title,
    String subtitle,
    Map<String, dynamic> data,
  ) {
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
            Text(
              id,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(subtitle),
          ],
        ),
        trailing: _buildTrailing(context, id, data),
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) {
    final status = data['status']?.toString();

    if (status == 'Approved') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "Approved",
          style: TextStyle(
            color: Colors.green.shade800,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (status == 'Rejected') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "Rejected",
          style: TextStyle(
            color: Colors.red.shade800,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final String? role = currentUser?.role;
    final bool allowed =
        role != null && (role == 'Supervisor' || role == 'Administrator');
    if (allowed) {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkOrderApprovalPage(
                workOrderId: id,
                currentUser: currentUser,
                workOrderData: data,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB71C1C),
          foregroundColor: Colors.white,
        ),
        child: const Text("Review"),
      );
    }

    return OutlinedButton(onPressed: null, child: const Text("No Access"));
  }
}
