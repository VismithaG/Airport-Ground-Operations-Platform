import 'package:flutter/material.dart';
// Import your create page to navigate to it
import 'create_work_order_page.dart'; 

// -------------------- Model --------------------
// Ensure this matches the model in your create_work_order_page.dart
class WorkOrder {
  final String id;
  final String title;
  final String details;
  final String location;
  final String aircraft;
  final String status;
  final String priority;
  final DateTime createdAt;
  final DateTime? dueDate;
  final List<String> services;

  WorkOrder({
    required this.id,
    required this.title,
    required this.details,
    required this.location,
    required this.aircraft,
    required this.status,
    this.priority = 'Medium',
    required this.createdAt,
    this.dueDate,
    required this.services,
  });
}

// -------------------- Main List Page --------------------

class WorkOrdersListPage extends StatefulWidget {
  const WorkOrdersListPage({super.key});

  @override
  State<WorkOrdersListPage> createState() => _WorkOrdersListPageState();
}

class _WorkOrdersListPageState extends State<WorkOrdersListPage> {
  // 1. State Variables for Filters
  String _searchQuery = '';
  String _selectedStatus = 'All Statuses';
  String _selectedPriority = 'All Priorities';

  // 2. Mock Data (Matches your screenshot)
  final List<WorkOrder> _allWorkOrders = [
    WorkOrder(
      id: '22745',
      title: 'Emirates EK 650',
      aircraft: 'A330',
      details: 'Additional service work order for Emirates flight EK',
      location: 'Gate A12',
      status: 'In Progress',
      priority: 'High',
      createdAt: DateTime.now(),
      dueDate: DateTime(2025, 8, 18),
      services: ['Unaccompanied Minor/Young...(2)', 'VIP or any other person v...(1)'],
    ),
    WorkOrder(
      id: '22745',
      title: 'Sri Lankan UL 504',
      aircraft: 'A350',
      details: 'Additional service work order for Sri Lankan flight UL',
      location: 'Gate B07',
      status: 'Open',
      priority: 'Low',
      createdAt: DateTime.now(),
      dueDate: DateTime(2025, 8, 9),
      services: ['Baggage ID - Interline on...(1)', 'Gate checks(3)'],
    ),
    WorkOrder(
      id: '22745',
      title: 'Emirates EK 650',
      aircraft: 'A330',
      details: 'Additional service work order for Emirates flight EK',
      location: 'Gate A12',
      status: 'Completed',
      priority: 'Critical',
      createdAt: DateTime.now(),
      dueDate: DateTime(2025, 8, 18),
      services: ['Unaccompanied Minor/Young...(2)', 'VIP or any other person v...(1)'],
    ),
    WorkOrder(
      id: '22745',
      title: 'Sri Lankan UL 504',
      aircraft: 'A350',
      details: 'Additional service work order for Sri Lankan flight UL',
      location: 'Gate B07',
      status: 'Open',
      priority: 'Low',
      createdAt: DateTime.now(),
      dueDate: DateTime(2025, 8, 9),
      services: ['Baggage ID - Interline on...(1)', 'Gate checks(3)'],
    ),
  ];

  // 3. Filter Logic
  List<WorkOrder> get _filteredOrders {
    return _allWorkOrders.where((wo) {
      final matchesSearch = wo.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          wo.id.contains(_searchQuery);
      final matchesStatus = _selectedStatus == 'All Statuses' || wo.status == _selectedStatus;
      final matchesPriority = _selectedPriority == 'All Priorities' || wo.priority == _selectedPriority;
      return matchesSearch && matchesStatus && matchesPriority;
    }).toList();
  }

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkOrderPage(
          onBack: () => Navigator.pop(context),
          onSave: (newOrder) {
            // In a real app, you would add this to the list via API or Provider
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 24),

            // Filters Section
            _buildFilterBar(),
            const SizedBox(height: 24),

            // Count Indicator
            Text(
              "Work Orders (${_filteredOrders.length})",
              style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Table Header
            _buildTableHeader(),
            const Divider(),

            // Data List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredOrders.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _buildWorkOrderRow(_filteredOrders[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Work Orders",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFB71C1C), // SriLankan Red
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Manage and track service department work orders",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: _navigateToCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text("Create New Work Order"),
        ),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text("Filters", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.filter_list, size: 16, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Search Input
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: "Search Work Orders...",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Status Dropdown
              Expanded(child: _buildDropdown(
                value: _selectedStatus,
                items: ['All Statuses', 'Open', 'In Progress', 'Completed', 'On Hold'],
                onChanged: (val) => setState(() => _selectedStatus = val!),
              )),
              
              const SizedBox(width: 16),
              
              // Priority Dropdown
              Expanded(child: _buildDropdown(
                value: _selectedPriority,
                items: ['All Priorities', 'Critical', 'High', 'Medium', 'Low'],
                onChanged: (val) => setState(() => _selectedPriority = val!),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({required String value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
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
    );
  }

  Widget _buildWorkOrderRow(WorkOrder wo) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID
          SizedBox(width: 80, child: Text(wo.id, style: const TextStyle(fontWeight: FontWeight.w500))),
          
          // Title
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(wo.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text("Aircraft: ${wo.aircraft}", style: const TextStyle(color: Colors.blue, fontSize: 12)),
                const SizedBox(height: 2),
                Text(wo.details, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          
          // Priority
          Expanded(
            flex: 1, 
            child: Text(wo.priority, style: const TextStyle(fontSize: 13))
          ),
          
          // Status
          Expanded(
            flex: 1,
            child: Text(
              wo.status,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: wo.status == 'Open' ? Colors.green : Colors.black87,
              ),
            ),
          ),
          
          // Services (Blue Links)
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...wo.services.take(2).map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Text(s, style: const TextStyle(color: Colors.blue, fontSize: 12, decoration: TextDecoration.underline)),
                    )),
                if (wo.services.length > 2)
                  const Text("+1 more", style: TextStyle(color: Colors.blue, fontSize: 12)),
              ],
            ),
          ),
          
          // Location
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(wo.location, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          
          // Due Date
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  wo.dueDate != null 
                    ? "${wo.dueDate!.day} - ${_getMonth(wo.dueDate!.month)} - ${wo.dueDate!.year}" 
                    : "N/A",
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          
          // Actions
          Flexible(
            fit: FlexFit.loose,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.remove_red_eye_outlined, size: 18, color: Colors.yellow[700]), // Yellow Eye
                const SizedBox(width: 8),
                const Icon(Icons.edit_outlined, size: 18, color: Colors.cyan), // Cyan/Blue Edit
              ],
            ),
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