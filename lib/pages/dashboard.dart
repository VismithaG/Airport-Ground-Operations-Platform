// lib/dashboard.dart
import 'package:flutter/material.dart';

// -------------------- Models & Mock Data --------------------

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
  final String location;
  final String aircraft;
  final String status; // Open, In Progress, Completed, Overdue, Pending Approval
  final DateTime createdAt;

  WorkOrder({
    this.id = '',
    this.title = '',
    this.details = '',
    this.location = '',
    this.aircraft = '',
    this.status = 'Open',
    required this.createdAt,
  });
}

final List<WorkOrder> _mockWorkOrders = [
  WorkOrder(createdAt: DateTime.now().subtract(const Duration(hours: 4)), title: 'Inspect APU', id: 'WO-001'),
  WorkOrder(createdAt: DateTime.now().subtract(const Duration(days: 1)), title: 'Refuel', id: 'WO-002'),
  WorkOrder(createdAt: DateTime.now().subtract(const Duration(days: 2)), title: 'Tire check', id: 'WO-003'),
  WorkOrder(createdAt: DateTime.now().subtract(const Duration(hours: 8)), title: 'Hydraulic check', id: 'WO-004'),
];

// -------------------- Dashboard Page --------------------

class DashboardPage extends StatefulWidget {
  final VoidCallback onLogout;
  final UserInfo? currentUser;

  const DashboardPage({
    Key? key,
    required this.onLogout,
    this.currentUser,
  }) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<WorkOrder> _workOrders = List.from(_mockWorkOrders);

  void _addMockWorkOrder() {
    setState(() {
      _workOrders.insert(
        0,
        WorkOrder(createdAt: DateTime.now(), title: 'New WO', id: 'WO-${_workOrders.length + 1}'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard - ${user?.name ?? 'Guest'}'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, color: Colors.red),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${user?.role ?? 'N/A'}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _addMockWorkOrder,
              icon: const Icon(Icons.add),
              label: const Text('Create Work Order'),
            ),
            const SizedBox(height: 16),
            const Text('Recent Work Orders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _workOrders.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final wo = _workOrders[index];
                  return ListTile(
                    title: Text(wo.title.isNotEmpty ? wo.title : wo.id),
                    subtitle: Text(wo.details.isNotEmpty ? wo.details : 'Created ${wo.createdAt}'),
                    trailing: Text(wo.status, style: TextStyle(color: wo.status == 'Open' ? Colors.orange : Colors.green)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
