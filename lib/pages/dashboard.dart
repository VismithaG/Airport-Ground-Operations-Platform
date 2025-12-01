import 'package:flutter/material.dart';
import 'dashboardheader.dart'; // Ensure this matches your file structure

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
  final String details; // Gate info, etc.
  final String status; // Open, In progress, Completed
  
  WorkOrder({
    required this.id,
    required this.title,
    required this.details,
    required this.status,
  });
}

// -------------------- Dashboard Page --------------------

class DashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
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
  // Mock Data matching the screenshot
  final List<WorkOrder> _workOrders = [
    WorkOrder(id: '22745', title: 'GPU Maintenance - Terminal A', details: 'Gate A12 • A330', status: 'In progress'),
    WorkOrder(id: '22746', title: 'Emirates EK 650 - Service Request', details: 'Gate B05 • A350', status: 'Open'),
    WorkOrder(id: '22745', title: 'Runaway Light Inspection', details: 'Gate A12 • A330', status: 'In progress'),
    WorkOrder(id: '22745', title: 'Baggage Belt Repair', details: 'Gate A12 • A330', status: 'Open'),
    WorkOrder(id: '22750', title: 'Sri Lankan UL 504 - Service Request', details: 'Gate B07 • A350', status: 'Completed'),
  ];

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tab Bar (Visual Only)
              Row(
                children: [
                  Column(
                    children: [
                      const Text("Dashboard Overview", style: TextStyle(color: Color(0xFFB71C1C), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Container(height: 2, width: 140, color: const Color(0xFFB71C1C)),
                    ],
                  ),
                  const SizedBox(width: 20),
                  const Text("Work Orders", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 30),

              // 2. Welcome Section & Action Button
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
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C), // Dark Red
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("New Work Order"),
                  )
                ],
              ),
              const SizedBox(height: 30),

              // 3. Status Cards
              _buildStatusCard(Icons.settings_outlined, "Total Work Orders", "25", Colors.brown),
              _buildStatusCard(Icons.access_time, "Open", "8", Colors.brown),
              _buildStatusCard(Icons.fast_forward, "In Progress", "5", Colors.brown),
              _buildStatusCard(Icons.check, "Completed Today", "7", Colors.brown),
              _buildStatusCard(Icons.error_outline, "Overdue", "2", Colors.brown),
              
              const SizedBox(height: 30),

              // 4. Weekly Activity Chart
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
                    // Custom Bar Chart Widget
                    SizedBox(
                      height: 180,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildBar("MON", 0.6),
                          _buildBar("TUE", 0.35),
                          _buildBar("WED", 0.4),
                          _buildBar("THU", 0.38),
                          _buildBar("FRI", 0.5),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // 5. Recent Work Orders List
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
                    Text("Recent Work Orders", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _workOrders.length,
                      separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final wo = _workOrders[index];
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
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatusCard(IconData icon, String label, String count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30), // Pill shape
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1)),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8D6E63), size: 24), // Brownish/Red tone
          const SizedBox(width: 16),
          Expanded(child: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 16))),
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBar(String label, double fillPercentage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 140 * fillPercentage, // Scale height
          decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border.all(color: Colors.black87),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor = Colors.black87;

    switch (status) {
      case 'In progress':
        bgColor = const Color(0xFFE6EE9C); // Light Green/Yellow
        break;
      case 'Open':
        bgColor = const Color(0xFFA5D6A7); // Green
        break;
      case 'Completed':
        bgColor = const Color(0xFFB2EBF2); // Light Cyan
        break;
      default:
        bgColor = Colors.grey.shade200;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
      ),
    );
  }
}