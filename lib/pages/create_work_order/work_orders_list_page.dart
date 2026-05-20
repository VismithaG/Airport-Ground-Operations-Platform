import 'package:flutter/material.dart';
// Import your create page to navigate to it
import 'create_work_order_page.dart';
import '../dashboard.dart'; // Import UserInfo
// FirebaseAuth not required here; UserInfo is provided via dashboard.dart
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
  final DateTime? serviceDate;
  final String? scheduledTime;
  final String? createdBy;
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
    this.serviceDate,
    this.scheduledTime,
    this.createdBy,
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
              stream: FirebaseFirestore.instance.collection('workOrders').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snapshot.hasData ? snapshot.data!.docs : [];

                List<WorkOrder> allWorkOrders = docs.map((doc) {
                  final raw = doc.data();
                  final Map<String, dynamic> data = raw is Map<String, dynamic>
                      ? raw
                      : (raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{});

                  DateTime parsedDate = DateTime.now();
                  if (data['createdAt'] is Timestamp) {
                    parsedDate = (data['createdAt'] as Timestamp).toDate();
                  } else if (data['createdAt'] is String) {
                    parsedDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
                  }

                  // Determine dueDate: prefer explicit scheduledAt, otherwise try to combine serviceDate + scheduledTime
                  DateTime? dueDate;
                  DateTime? serviceDate;
                  String? scheduledTime;

                  if (data['scheduledAt'] is Timestamp) {
                    dueDate = (data['scheduledAt'] as Timestamp).toDate();
                  }

                  if (data['serviceDate'] is Timestamp) {
                    serviceDate = (data['serviceDate'] as Timestamp).toDate();
                  } else if (data['serviceDate'] is String) {
                    serviceDate = DateTime.tryParse(data['serviceDate']);
                  }

                  if (data['scheduledTime'] != null) {
                    scheduledTime = data['scheduledTime'].toString();
                  }

                  if (dueDate == null && serviceDate != null && scheduledTime != null && scheduledTime.isNotEmpty) {
                    try {
                      final timeParts = scheduledTime.split(' ');
                      if (timeParts.length >= 2) {
                        final hm = timeParts[0].split(':');
                        int hour = int.parse(hm[0]);
                        final minute = hm.length > 1 ? int.parse(hm[1]) : 0;
                        final period = timeParts[1].toUpperCase();
                        if (period == 'PM' && hour < 12) {
                          hour += 12;
                        }
                        if (period == 'AM' && hour == 12) {
                          hour = 0;
                        }
                        dueDate = DateTime(serviceDate.year, serviceDate.month, serviceDate.day, hour, minute);
                      }
                    } catch (e) {
                      debugPrint('Failed to parse scheduledTime from doc ${doc.id}: $e');
                    }
                  }

                  // Robust services extraction (handles List, Map, and categorized maps)
                  List<String> services = [];
                  final rawServices = data['services'];
                  if (rawServices is List) {
                    services = rawServices.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
                  } else if (rawServices is Map) {
                    rawServices.forEach((k, v) {
                      if (v is List) {
                        services.addAll(v.map((e) => e.toString()));
                      } else if (v != null) {
                        services.add(v.toString());
                      }
                    });
                  } else {
                    // try known category keys
                    const List<String> categories = [
                      'specialPassengerServices',
                      'groundSupportServices',
                      'baggageServices',
                      'facilityServices',
                      'selectedServices',
                    ];
                    for (final key in categories) {
                      final r = data[key];
                      if (r is List) {
                        services.addAll(r.map((e) => e.toString()));
                      } else if (r is Map) {
                        r.forEach((k, v) {
                          if (v is List) {
                            services.addAll(v.map((e) => e.toString()));
                          } else if (v != null) {
                            services.add(v.toString());
                          }
                        });
                      }
                    }
                  }

                  // Determine display title with fallbacks
                  String title = '';
                  if (data['title'] != null && data['title'].toString().trim().isNotEmpty) {
                    title = data['title'].toString();
                  } else if ((data['carrier'] != null || data['flightNo'] != null) && ((data['carrier']?.toString().isNotEmpty ?? false) || (data['flightNo']?.toString().isNotEmpty ?? false))) {
                    title = '${data['carrier'] ?? ''} ${data['flightNo'] ?? ''}'.trim();
                  } else if (data['flightNumber'] != null) {
                    title = data['flightNumber'].toString();
                  } else if (data['flightNo'] != null) {
                    title = data['flightNo'].toString();
                  } else {
                    title = data['aircraft']?.toString() ?? 'Unknown';
                  }

                  return WorkOrder(
                    id: data['id']?.toString() ?? doc.id,
                    title: title,
                    details: data['details']?.toString() ?? data['description']?.toString() ?? 'Service Request',
                    location: data['location']?.toString() ?? data['gate']?.toString() ?? 'TBD',
                    aircraft: data['aircraft']?.toString() ?? data['aircraftType']?.toString() ?? 'Unknown',
                    status: data['status']?.toString() ?? 'Open',
                    priority: data['priority']?.toString() ?? 'Medium',
                    createdAt: parsedDate,
                    dueDate: dueDate,
                    serviceDate: serviceDate,
                    scheduledTime: scheduledTime,
                    createdBy: data['createdBy']?.toString(),
                    services: services,
                  );
                }).toList();

                // Locally sort by created descending
                allWorkOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                // Filter Logic
                List<WorkOrder> filteredOrders = allWorkOrders.where((wo) {
                  final matchesSearch = wo.title.toLowerCase().contains(_searchQuery.toLowerCase()) || wo.id.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesStatus = _selectedStatus == 'All Statuses' || wo.status == _selectedStatus;
                  final matchesPriority = _selectedPriority == 'All Priorities' || wo.priority == _selectedPriority;
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

                    // Responsive layout: show a compact mobile list for narrow screens
                    Builder(builder: (ctx) {
                      final bool isMobile = MediaQuery.of(ctx).size.width < 720;
                      if (isMobile) {
                        if (filteredOrders.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40.0),
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
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) => _buildWorkOrderRow(filteredOrders[index]),
                        );
                      }

                      // Desktop / wide layout: table with horizontal scroll when needed
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          const double minTableWidth = 1200.0;
                          final double tableWidth = constraints.maxWidth > minTableWidth ? constraints.maxWidth : minTableWidth;

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
                                      padding: EdgeInsets.symmetric(vertical: 40.0),
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
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: filteredOrders.length,
                                      separatorBuilder: (context, index) => const Divider(height: 1),
                                      itemBuilder: (context, index) => _buildWorkOrderRow(filteredOrders[index]),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),
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
    final double w = MediaQuery.of(context).size.width;
    if (w < 720) {
      // Compact mobile layout to avoid horizontal overflow
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(wo.id, style: const TextStyle(fontWeight: FontWeight.w600)),
                          if (wo.priority.toLowerCase() == 'critical') ...[
                            const SizedBox(width: 6),
                            Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red.shade700),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(wo.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 36, height: 36),
                  icon: Icon(Icons.remove_red_eye_outlined, size: 20, color: Colors.yellow[700]),
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
                                Text('Created: ${wo.createdAt.day}-${_getMonth(wo.createdAt.month)}-${wo.createdAt.year} ${wo.createdAt.hour.toString().padLeft(2, '0')}:${wo.createdAt.minute.toString().padLeft(2, '0')}'),
                                const SizedBox(height: 8),
                                Text('Service Date: ${wo.serviceDate != null ? '${wo.serviceDate!.day}-${_getMonth(wo.serviceDate!.month)}-${wo.serviceDate!.year}' : 'N/A'}'),
                                const SizedBox(height: 8),
                                Text('Scheduled Time: ${wo.scheduledTime ?? 'N/A'}'),
                                const SizedBox(height: 8),
                                Text('Due Date: ${wo.dueDate != null ? '${wo.dueDate!.day}-${_getMonth(wo.dueDate!.month)}-${wo.dueDate!.year} ${wo.dueDate!.hour.toString().padLeft(2, '0')}:${wo.dueDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}'),
                                const SizedBox(height: 12),
                                const Text('Services:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                ...wo.services.map((s) => Text('- $s')),
                                const SizedBox(height: 12),
                                const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(wo.details),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(wo.location, style: const TextStyle(fontSize: 13))),
                const SizedBox(width: 12),
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(wo.dueDate != null ? '${wo.dueDate!.day} - ${_getMonth(wo.dueDate!.month)} - ${wo.dueDate!.year}' : 'N/A', style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
          ],
        ),
      );
    }

    // Desktop / wide layout (table-style row)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ID
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    wo.id,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (wo.priority.toLowerCase() == 'critical')
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Tooltip(
                      message: 'Critical priority',
                      child: Icon(Icons.warning_amber_rounded, size: 16, color: Colors.red.shade700),
                    ),
                  ),
              ],
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

          // Actions (only view)
          SizedBox(
            width: 72,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints.tightFor(width: 28, height: 28),
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
                                Text('Service Date: ${wo.serviceDate != null ? '${wo.serviceDate!.day}-${_getMonth(wo.serviceDate!.month)}-${wo.serviceDate!.year}' : 'N/A'}'),
                                const SizedBox(height: 8),
                                Text('Scheduled Time: ${wo.scheduledTime ?? 'N/A'}'),
                                const SizedBox(height: 8),
                                Text(
                                  'Due Date: ${wo.dueDate != null ? '${wo.dueDate!.day}-${_getMonth(wo.dueDate!.month)}-${wo.dueDate!.year} ${wo.dueDate!.hour.toString().padLeft(2, '0')}:${wo.dueDate!.minute.toString().padLeft(2, '0')}' : 'N/A'}',
                                ),
                                const SizedBox(height: 12),
                                const Text('Services:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                ...wo.services.map((s) => Text('- $s')),
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
