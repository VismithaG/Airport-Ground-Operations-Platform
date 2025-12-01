// lib/pages/create_work_order/work_orders_list_page.dart
import 'package:flutter/material.dart';
import 'create_work_order_page.dart'; 

class WorkOrdersListPage extends StatefulWidget {
  const WorkOrdersListPage({super.key});

  @override
  State<WorkOrdersListPage> createState() => _WorkOrdersListPageState();
}

class _WorkOrdersListPageState extends State<WorkOrdersListPage> {
  // Data for the Work Orders Tab
  final List<WorkOrder> _workOrders = [
    WorkOrder(
      id: '22745',
      title: 'Emirates EK 650',
      details: 'Additional service work order for Emirates flight EK',
      location: 'Gate A12',
      aircraft: 'A330',
      status: 'In Progress',
      priority: 'High',
      createdAt: DateTime.now(),
      dueDate: DateTime(2025, 8, 18),
      services: ['Unaccompanied Minor/Young...(2)', 'VIP or any other person v...(1)'],
      quantities: {},
      notes: '',
    ),
    WorkOrder(
      id: '22745',
      title: 'Sri Lankan UL 504',
      details: 'Additional service work order for Sri Lankan flight UL',
      location: 'Gate B07',
      aircraft: 'A350',
      status: 'Open',
      priority: 'Low',
      createdAt: DateTime.now(),
      dueDate: DateTime(2025, 8, 09),
      services: ['Baggage ID - Interline on...(1)', 'Gate checks(3)'],
      quantities: {},
      notes: '',
    ),
    WorkOrder(
      id: '22745',
      title: 'Emirates EK 650',
      details: 'Additional service work order for Emirates flight EK',
      location: 'Gate A12',
      aircraft: 'A330',
      status: 'Completed',
      priority: 'Critical',
      createdAt: DateTime.now(),
      dueDate: DateTime(2025, 8, 18),
      services: ['Unaccompanied Minor/Young...(2)', 'VIP or any other person v...(1)'],
      quantities: {},
      notes: '',
    ),
  ];

  void _navigateToCreatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkOrderPage(
          onBack: () => Navigator.pop(context),
          onSave: (newOrder) {
            setState(() {
              _workOrders.insert(0, newOrder);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Note: We do NOT use Scaffold here because this is embedded in DashboardPage
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Work Orders", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFB71C1C))),
                  SizedBox(height: 4),
                  Text("Manage and track service department work orders", style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _navigateToCreatePage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB71C1C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Create New Work Order"),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Filters Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Row(
                  children: const [
                    Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.filter_list, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search Work Orders...",
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildDropdownFilter("All Statuses"),
                const SizedBox(width: 16),
                _buildDropdownFilter("All Priorities"),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Table Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: const [
                SizedBox(width: 80, child: Text("Work Order ID", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text("Title & Flight Number", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text("Priority", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 2, child: Text("Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(flex: 1, child: Text("Due Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                SizedBox(width: 60, child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          const Divider(),

          // 4. List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _workOrders.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildWorkOrderRow(_workOrders[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(hint, style: const TextStyle(color: Colors.grey)),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildWorkOrderRow(WorkOrder wo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(wo.id, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Aircraft: ${wo.aircraft}", style: const TextStyle(color: Colors.blue, fontSize: 12)),
                Text(wo.details, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Expanded(flex: 1, child: Text(wo.priority ?? 'Medium', style: const TextStyle(fontSize: 13))),
          Expanded(
            flex: 1,
            child: Text(
              wo.status,
              style: TextStyle(fontWeight: FontWeight.w500, color: wo.status == 'Open' ? Colors.green : Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...wo.services.take(2).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(s, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                    )),
                if (wo.services.length > 2) const Text("+1 more", style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey), const SizedBox(width: 4), Text(wo.location, style: const TextStyle(fontSize: 13))]),
          ),
          Expanded(
            flex: 1,
            child: Row(children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(wo.dueDate != null ? "${wo.dueDate!.day} - ${_getMonth(wo.dueDate!.month)} - ${wo.dueDate!.year}" : "N/A", style: const TextStyle(fontSize: 13)),
            ]),
          ),
          SizedBox(
            width: 60,
            child: Row(children: [
              Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.yellow[700]),
              const SizedBox(width: 8),
              const Icon(Icons.edit_outlined, size: 18, color: Colors.blue),
            ]),
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    return months[month - 1];
  }
}