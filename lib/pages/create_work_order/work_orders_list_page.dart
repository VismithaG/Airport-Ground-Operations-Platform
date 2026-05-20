import 'package:flutter/material.dart';
// Import your create page to navigate to it
import 'create_work_order_page.dart';
import '../dashboard.dart'; // Import UserInfo
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final UserInfo? currentUser;

  const WorkOrdersListPage({super.key, this.currentUser});

  @override
  State<WorkOrdersListPage> createState() => _WorkOrdersListPageState();
}

class _WorkOrdersListPageState extends State<WorkOrdersListPage> {
  // 1. State Variables for Filters
  String _searchQuery = '';
  String _selectedStatus = 'All Statuses';
  String _selectedPriority = 'All Priorities';

  // 2. Mock Data removed (using Firestore directly in StreamBuilder now)

  void _navigateToCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateWorkOrderPage(
          currentUser: widget.currentUser,
          onBack: () => Navigator.pop(context),
          onSave: (newOrder) {
            // Document is saved directly to Firestore inside CreateWorkOrderPage.
            // Keeping this empty allows CreateWorkOrderPage to show its animated success screen.
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

            // Firestore Data Stream + Table
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('workOrders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.hasData ? snapshot.data!.docs : [];

                List<WorkOrder> allWorkOrders = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  DateTime parsedDate = DateTime.now();
                  if (data['createdAt'] is Timestamp) {
                    parsedDate = (data['createdAt'] as Timestamp).toDate();
                  } else if (data['createdAt'] is String) {
                    parsedDate =
                        DateTime.tryParse(data['createdAt']) ?? DateTime.now();
                  }

                  return WorkOrder(
                    id: data['id']?.toString() ?? doc.id,
                    title: data['title']?.toString() ?? 'Unknown',
                    details: data['details']?.toString() ?? 'Service Request',
                    location: data['location']?.toString() ?? 'TBD',
                    aircraft: data['aircraft']?.toString() ?? 'Unknown',
                    status: data['status']?.toString() ?? 'Open',
                    priority: data['priority']?.toString() ?? 'Medium',
                    createdAt: parsedDate,
                    services: List<String>.from(data['services'] ?? []),
                  );
                }).toList();

                // Locally sort by created descending
                allWorkOrders.sort(
                  (a, b) => b.createdAt.compareTo(a.createdAt),
                );

                // Filter Logic
                List<WorkOrder> filteredOrders = allWorkOrders.where((wo) {
                  final matchesSearch =
                      wo.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      wo.id.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesStatus =
                      _selectedStatus == 'All Statuses' ||
                      wo.status == _selectedStatus;
                  final matchesPriority =
                      _selectedPriority == 'All Priorities' ||
                      wo.priority == _selectedPriority;
                  return matchesSearch && matchesStatus && matchesPriority;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Count Indicator
                    Text(
                      "Work Orders (${filteredOrders.length})",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Table Layout Wrapper for Horizontal Scrolling
                    LayoutBuilder(
                      builder: (context, constraints) {
                        const double minTableWidth = 1200.0;
                        final double tableWidth =
                            constraints.maxWidth > minTableWidth
                            ? constraints.maxWidth
                            : minTableWidth;

                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: tableWidth,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Table Header
                                _buildTableHeader(),
                                const Divider(),

                                // Data List
                                if (filteredOrders.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 40.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "No data is present",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: filteredOrders.length,
                                    separatorBuilder: (context, index) =>
                                        const Divider(height: 1),
                                    itemBuilder: (context, index) {
                                      return _buildWorkOrderRow(
                                        filteredOrders[index],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 48,
          ),
          child: Column(
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
        ),
        ElevatedButton.icon(
          onPressed: _navigateToCreate,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB71C1C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
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
          Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Search Input
              SizedBox(
                width: 200,
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

              // Status Dropdown
              SizedBox(
                width: 150,
                child: _buildDropdown(
                  value: _selectedStatus,
                  items: [
                    'All Statuses',
                    'Open',
                    'In Progress',
                    'Completed',
                    'On Hold',
                  ],
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
              ),

              // Priority Dropdown
              SizedBox(
                width: 150,
                child: _buildDropdown(
                  value: _selectedPriority,
                  items: [
                    'All Priorities',
                    'Critical',
                    'High',
                    'Medium',
                    'Low',
                  ],
                  onChanged: (val) => setState(() => _selectedPriority = val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
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
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
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
          SizedBox(
            width: 100,
            child: Text(
              "Work Order ID",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Title & Flight Number",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Priority",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "Services",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              "Due Date",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              "Action",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
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
          SizedBox(
            width: 100,
            child: Text(
              wo.id,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),

          // Title
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wo.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Aircraft: ${wo.aircraft}",
                  style: const TextStyle(color: Colors.blue, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  wo.details,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),

          // Priority
          Expanded(
            flex: 1,
            child: Text(wo.priority, style: const TextStyle(fontSize: 13)),
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
                ...wo.services
                    .take(2)
                    .map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          s,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                if (wo.services.length > 2)
                  const Text(
                    "+1 more",
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
              ],
            ),
          ),

          // Location
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    wo.location,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Due Date
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    wo.dueDate != null
                        ? "${wo.dueDate!.day} - ${_getMonth(wo.dueDate!.month)} - ${wo.dueDate!.year}"
                        : "N/A",
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          SizedBox(
            width: 80,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Eye button: shows details dialog
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.remove_red_eye_outlined,
                    size: 18,
                    color: Colors.yellow[700],
                  ),
                  tooltip: 'View details',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text('Work Order ${wo.id}'),
                          content: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Title: ${wo.title}'),
                                const SizedBox(height: 8),
                                Text('Aircraft / Flight: ${wo.aircraft}'),
                                const SizedBox(height: 8),
                                Text('Priority: ${wo.priority}'),
                                const SizedBox(height: 8),
                                Text('Status: ${wo.status}'),
                                const SizedBox(height: 8),
                                Text('Location: ${wo.location}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Created: ${wo.createdAt.day}-${_getMonth(wo.createdAt.month)}-${wo.createdAt.year} ${wo.createdAt.hour.toString().padLeft(2, '0')}:${wo.createdAt.minute.toString().padLeft(2, '0')}',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Due Date: ${wo.dueDate != null ? '${wo.dueDate!.day}-${_getMonth(wo.dueDate!.month)}-${wo.dueDate!.year}' : 'N/A'}',
                                ),
                                const SizedBox(height: 12),
                                const Text('Services:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                ...wo.services.map((s) => Text('- $s')).toList(),
                                const SizedBox(height: 12),
                                const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(wo.details),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: Colors.cyan,
                ), // Cyan/Blue Edit
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonth(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }
}
