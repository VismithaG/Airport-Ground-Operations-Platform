// lib/pages/dashboard.dart
import 'package:flutter/material.dart';
import 'dashboardheader.dart';
import 'create_work_order/work_orders_list_page.dart';
import 'approval/approval_list_page.dart'; // Import the approval list
import 'package:cloud_firestore/cloud_firestore.dart';

// -------------------- Models --------------------

class UserInfo {
  final String name;
  final String role;
  final String email;
  UserInfo({required this.name, required this.role, required this.email});
}

class WorkOrder {
  final String id;
  final String title;
  final String details;
  final String status;
  
  WorkOrder({
    required this.id,
    required this.title,
    required this.details,
    required this.status,
  });
}

// -------------------- Dashboard Page --------------------

class DashboardPage extends StatefulWidget {
  final void Function(BuildContext) onLogout;
  final UserInfo? currentUser;

  const DashboardPage({
    super.key,
    required this.onLogout,
    this.currentUser,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // 0: Overview, 1: Work Orders

  // Using Firestore for recent work orders

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: DashboardHeader(
        onLogout: widget.onLogout,
        currentUser: widget.currentUser != null
            ? {
                "name": widget.currentUser!.name,
                "role": widget.currentUser!.role,
                "email": widget.currentUser!.email
              }
            : null,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tab Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
            child: Row(
              children: [
                _buildTabItem(0, "Dashboard Overview"),
                const SizedBox(width: 30),
                _buildTabItem(1, "Work Orders"),
              ],
            ),
          ),
          
          // 2. Content Area (Switches based on selection)
          Expanded(
            child: _selectedIndex == 0 
              ? _buildOverview() 
              : WorkOrdersListPage(currentUser: widget.currentUser),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFB71C1C) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          // Underline indicator
          if (isSelected)
            Container(height: 2, width: 40, color: const Color(0xFFB71C1C))
          else
            const SizedBox(height: 2), // Placeholder to prevent jump
        ],
      ),
    );
  }

  // --- Overview Tab Content ---
  Widget _buildOverview() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('workOrders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        int total = 0;
        int open = 0;
        int pending = 0;
        int completedToday = 0;
        int overdue = 0;

        List<int> weekdayCounts = [0, 0, 0, 0, 0, 0, 0];

        List<QueryDocumentSnapshot> docs = [];
        if (snapshot.hasData) {
          docs = snapshot.data!.docs;
          total = docs.length;
          final now = DateTime.now();

          final int currentWeekday = now.weekday;
          final DateTime startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: currentWeekday - 1));

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = data['status']?.toString() ?? 'Open';
            
            if (status == 'Open') open++;
            if (status == 'Pending Approval') pending++;

            DateTime createdAt = now;
            if (data['createdAt'] is Timestamp) {
              createdAt = (data['createdAt'] as Timestamp).toDate();
            } else if (data['createdAt'] != null) {
              createdAt = DateTime.tryParse(data['createdAt'].toString()) ?? now;
            }

            DateTime? dueDate;
            if (data['dueDate'] is Timestamp) {
              dueDate = (data['dueDate'] as Timestamp).toDate();
            } else if (data['dueDate'] != null) {
              dueDate = DateTime.tryParse(data['dueDate'].toString());
            }

            if (status == 'Completed') {
              DateTime completedDate = createdAt;
              if (data['updatedAt'] is Timestamp) {
                completedDate = (data['updatedAt'] as Timestamp).toDate();
              } else if (data['updatedAt'] != null) {
                completedDate = DateTime.tryParse(data['updatedAt'].toString()) ?? createdAt;
              }
              if (completedDate.year == now.year && completedDate.month == now.month && completedDate.day == now.day) {
                completedToday++;
              }
            }

            if (dueDate != null) {
              final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
              final todayDay = DateTime(now.year, now.month, now.day);
              if (dueDay.isBefore(todayDay) && status != 'Completed' && status != 'Closed') {
                overdue++;
              }
            }

            if (createdAt.isAfter(startOfWeek) || createdAt.isAtSameMomentAs(startOfWeek)) {
              if (createdAt.weekday >= 1 && createdAt.weekday <= 7) {
                weekdayCounts[createdAt.weekday - 1]++;
              }
            }
          }
        }

        int maxCount = weekdayCounts.reduce((a, b) => a > b ? a : b);
        if (maxCount == 0) maxCount = 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome to\nService Operations",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w600, color: Color(0xFFB71C1C), height: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Monitor and manage airport ground\nservice operations efficiently.",
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              // --- ACTION BUTTONS ---
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => setState(() => _selectedIndex = 1), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("New Work Order"),
                  ),
                  const SizedBox(height: 8),
                  // Button linking to Approval Workflow (only for Supervisor/Admin)
                  if (widget.currentUser != null &&
                      (widget.currentUser!.role == 'Supervisor' || widget.currentUser!.role == 'Administrator'))
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ApprovalListPage(currentUser: widget.currentUser)));
                      }, 
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7F1D1D), // Slightly darker red for distinction
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text("Approve Work Orders"),
                    ),
                ],
              )
            ],
          ),
          const SizedBox(height: 30),

          // Status Cards
          _buildStatusCard(Icons.settings_outlined, "Total Work Orders", "$total"),
          _buildStatusCard(Icons.access_time, "Open", "$open"),
          _buildStatusCard(Icons.history_edu, "Pending Approval", "$pending"), // Updated label
          _buildStatusCard(Icons.check, "Completed Today", "$completedToday"),
          _buildStatusCard(Icons.error_outline, "Overdue", "$overdue"),
          
          const SizedBox(height: 30),

          // Weekly Activity Chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today, color: Color(0xFFB71C1C), size: 20),
                    SizedBox(width: 8),
                    Text("Weekly Activity", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 20),
                LayoutBuilder(builder: (ctx, chartConstraints) {
                  final isNarrow = chartConstraints.maxWidth < 480;
                  final bars = [
                    _buildBar("MON", weekdayCounts[0], maxCount),
                    _buildBar("TUE", weekdayCounts[1], maxCount),
                    _buildBar("WED", weekdayCounts[2], maxCount),
                    _buildBar("THU", weekdayCounts[3], maxCount),
                    _buildBar("FRI", weekdayCounts[4], maxCount),
                    _buildBar("SAT", weekdayCounts[5], maxCount),
                    _buildBar("SUN", weekdayCounts[6], maxCount),
                  ];

                  Widget yAxis = SizedBox(
                    height: 168,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("$maxCount", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        Text("${(maxCount / 2).ceil()}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const Text("0", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(height: 14),
                      ],
                    ),
                  );

                  if (isNarrow) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        yAxis,
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 180,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: bars.map((b) => SizedBox(width: 64, child: b)).toList()),
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      yAxis,
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 180,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: bars,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          // Recent Work Orders List (Small view)
          Container(
             decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Recent Activity", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                const SizedBox(height: 10),
                if (docs.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text("No recent work orders found."),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.take(5).length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final doc = docs.take(5).toList()[index];
                      final data = doc.data() as Map<String, dynamic>;
                      
                      final wo = WorkOrder(
                        id: data['id']?.toString() ?? doc.id,
                        title: data['title']?.toString() ?? 'Untitled',
                        details: data['details']?.toString() ?? 'No Details',
                        status: data['status']?.toString() ?? 'Open',
                      );
                      
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(wo.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text("${wo.id} • ${wo.details}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                              ],
                            ),
                          ),
                          _buildStatusBadge(wo.status),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
      },
    );
  }

  // --- Helpers ---

  Widget _buildStatusCard(IconData icon, String label, String count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 24),
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 16))),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int count, int maxCount) {
    double fillPercentage = maxCount > 0 ? count / maxCount : 0.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Tooltip(
          message: "$count Work Orders",
          preferBelow: false,
          triggerMode: TooltipTriggerMode.tap,
          child: Container(
            width: 30,
            height: 140 * fillPercentage,
            decoration: BoxDecoration(color: Colors.grey[300], border: Border.all(color: Colors.black87)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    switch (status) {
      case 'In progress': bgColor = const Color(0xFFE6EE9C); break;
      case 'Open': bgColor = const Color(0xFFA5D6A7); break;
      case 'Completed': bgColor = const Color(0xFFB2EBF2); break;
      case 'Pending Approval': bgColor = Colors.orange.shade100; break;
      default: bgColor = Colors.grey.shade200;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87)),
    );
  }
}