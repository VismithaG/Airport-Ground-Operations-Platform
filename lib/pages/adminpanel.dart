// lib/pages/adminpanel.dart
import 'package:flutter/material.dart';

// -------------------- Models & Mock Data --------------------

class UserData {
  final String name;
  final String email;
  final String role;
  final String department;
  final String status; // Active, Inactive, Suspended
  final String lastLogin;

  UserData(this.name, this.email, this.role, this.department, this.status, this.lastLogin);
}

class ActivityLogData {
  final String action;
  final String user;
  final String userRole; // Added to match UI avatar context
  final String details;
  final String severity; // Info, Warning, High
  final String time;
  final IconData icon;

  ActivityLogData(this.action, this.user, this.userRole, this.details, this.severity, this.time, this.icon);
}

// -------------------- Admin Panel Page --------------------

class AdminPanelPage extends StatefulWidget {
  final Map<String, String>? currentUser;
  final VoidCallback? onLogout;

  const AdminPanelPage({super.key, this.currentUser, this.onLogout});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock Users matching the "User Table" in the image
  final List<UserData> _users = [
    UserData("John Smith", "john.smith@airport.com", "Service Technician", "Ground Operations", "Active", "1/20/2025 09:15 AM"),
    UserData("Michael Johnson", "michael.j@airport.com", "Operations Supervisor", "Ground Operations", "Active", "4/20/2025 08:30 AM"),
    UserData("Sarah Wilson", "sarah.wilson@airport.com", "Service Technician", "Aircraft Maintenance", "Active", "1/19/2025 11:15 AM"),
    UserData("Robert Davis", "robert.davis@airport.com", "Ground Crew", "Baggage Handling", "Inactive", "1/20/2025 11:00 AM"),
    UserData("Emily Rodriguez", "emily.r@airport.com", "Safety Inspector", "Safety & Compliance", "Active", "1/20/2025 11:45 AM"),
  ];

  // Mock Logs matching the "Activity Table" in the image
  final List<ActivityLogData> _logs = [
    ActivityLogData("Login", "John Smith", "Service Technician", "Successful login from workstation WS-001", "Info", "1/20/2025 09:15 AM", Icons.login),
    ActivityLogData("Work Order Created", "System", "System", "Work order ASD-240820-003 created for Emirates EK 650", "Info", "1/20/2025 10:12 AM", Icons.add_circle_outline),
    ActivityLogData("Work Order Approved", "Michael Johnson", "Supervisor", "Work order ASD-240820-002 approved with digital signature", "Info", "1/20/2025 09:58 AM", Icons.check_circle_outline),
    ActivityLogData("Failed Login", "Sarah Wilson", "Service Technician", "Failed login attempt from 203.0.113.10 - incorrect password", "Warning", "1/20/2025 10:05 AM", Icons.warning_amber),
    ActivityLogData("User Account Modified", "Administrator", "Admin", "Updated permissions for Robert Davis (usr-004)", "Info", "1/20/2025 09:45 AM", Icons.manage_accounts),
    ActivityLogData("System Backup", "System", "System", "Automated daily backup completed successfully (2.3GB)", "Info", "1/20/2025 09:30 AM", Icons.backup),
    ActivityLogData("Security Alert", "System", "System", "Multiple failed login attempts detected from IP 198.51.100.42", "High", "1/20/2025 08:45 AM", Icons.security),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser ?? {"name": "Admin User", "role": "System Administrator"};

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.admin_panel_settings, color: Color(0xFFB71C1C)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Admin Panel", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                Text("System Administration", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ],
        ),
        actions: [
          Center(child: Text("Welcome, ${user['name']}", style: const TextStyle(fontSize: 14, color: Colors.black87))),
          const SizedBox(width: 12),
          IconButton(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, color: Colors.grey),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 16),
        ],
        iconTheme: const IconThemeData(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFB71C1C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFB71C1C),
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.group_outlined), text: "User Management"),
            Tab(icon: Icon(Icons.history), text: "Activity Logs"),
            Tab(icon: Icon(Icons.security), text: "Security"),
            Tab(icon: Icon(Icons.settings), text: "System Settings"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserManagement(),
          _buildActivityLogs(),
          _buildSecurity(),
          _buildSystemSettings(),
        ],
      ),
    );
  }

  // -------------------- 1. User Management Tab --------------------
  Widget _buildUserManagement() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Stats Row
          Row(
            children: [
              _buildStatCard("Total Users", "5", Icons.group, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard("Active Users", "4", Icons.check_circle, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard("Inactive Users", "1", Icons.person_off, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard("Suspended", "0", Icons.block, Colors.red),
            ],
          ),
          const SizedBox(height: 24),

          // Main Card
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.withAlpha((0.1 * 255).round()), blurRadius: 10)]),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("User Management", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Manage user accounts, roles, and permissions", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.filter_list, size: 18), label: const Text("Filters")),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 18), label: const Text("Export")),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Add User"),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search Bar
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search Users...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
                const SizedBox(height: 20),

                // User Table
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 800),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                      columns: const [
                        DataColumn(label: Text("User", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Title/Job Role", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Department", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Status", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Last Login", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _users.map((user) {
                        return DataRow(cells: [
                          DataCell(Row(
                            children: [
                              CircleAvatar(radius: 16, backgroundColor: Colors.red.shade50, child: Text(user.name[0], style: const TextStyle(color: Colors.red, fontSize: 12))),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  Text(user.email, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ],
                          )),
                          DataCell(Text(user.role)),
                          DataCell(Text(user.department)),
                          DataCell(_buildStatusBadge(user.status)),
                          DataCell(Text(user.lastLogin)),
                          DataCell(Row(children: [
                            IconButton(icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.grey), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue), onPressed: () {}),
                            IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () {}),
                          ])),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- 2. Activity Logs Tab --------------------
  Widget _buildActivityLogs() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Stats
          Row(
            children: [
              _buildStatCard("Total Events", "10", Icons.list_alt, Colors.blue),
              const SizedBox(width: 16),
              _buildStatCard("High Priority", "1", Icons.warning, Colors.red),
              const SizedBox(width: 16),
              _buildStatCard("Warnings", "1", Icons.error_outline, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard("Information", "8", Icons.info_outline, Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.grey.withAlpha((0.1 * 255).round()), blurRadius: 10)]),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                      Text("Recent Activity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text("System events and user activities in real-time", style: TextStyle(color: Colors.grey)),
                    ]),
                    Row(children: [
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download, size: 18), label: const Text("Export Logs")),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh, size: 18), label: const Text("Refresh")),
                    ]),
                  ],
                ),
                const SizedBox(height: 20),

                // Search
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search activities...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                  ),
                ),
                const SizedBox(height: 20),

                // Activity Table (Replacing ListView with DataTable)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 800),
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                      columns: const [
                        DataColumn(label: Text("Activity", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("User", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Details", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Severity", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text("Time Stamp", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: _logs.map((log) {
                        return DataRow(cells: [
                          // Activity Column
                          DataCell(Row(children: [
                            Icon(log.icon, size: 18, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ])),
                          // User Column
                          DataCell(Row(children: [
                            CircleAvatar(radius: 12, backgroundColor: Colors.grey[200], child: Text(log.user[0], style: const TextStyle(fontSize: 10, color: Colors.black87))),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(log.user, style: const TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            )
                          ])),
                          // Details Column
                          DataCell(SizedBox(width: 300, child: Text(log.details, overflow: TextOverflow.ellipsis))),
                          // Severity Column
                          DataCell(_buildSeverityBadge(log.severity)),
                          // Time Column
                          DataCell(Text(log.time)),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- 3. Security Tab --------------------
  Widget _buildSecurity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column (Settings)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildSettingsSection("Password Policy", Icons.vpn_key, [
                  _buildSwitchRow("Require Uppercase", true),
                  _buildSwitchRow("Require Lowercase", true),
                  _buildSwitchRow("Require Numbers", true),
                  _buildSwitchRow("Require Special Characters", false),
                  _buildInputRow("Minimum Length", "8 characters"),
                  _buildInputRow("Password Expiry", "90 days"),
                  _buildButtonRow("Update Policy"),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection("Session Security", Icons.timer, [
                  _buildInputRow("Session Timeout", "30 minutes"),
                  _buildInputRow("Max Concurrent Sessions", "3 sessions"),
                  _buildSwitchRow("Require Re-authentication", true),
                  _buildSwitchRow("Logout on Browser Close", false),
                  _buildButtonRow("Update Session"),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection("Access Control", Icons.shield, [
                  _buildInputRow("Max Failed Attempts", "5 attempts"),
                  _buildInputRow("Lockout Duration", "15 minutes"),
                  _buildSwitchRow("Two-Factor Authentication", true),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text("Allowed IP Ranges", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const ListTile(dense: true, title: Text("192.168.1.0/24"), trailing: Icon(Icons.delete, size: 16)),
                  const ListTile(dense: true, title: Text("10.0.0.0/16"), trailing: Icon(Icons.delete, size: 16)),
                  OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text("Add Range")),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Right Column (Overview)
          Expanded(
            flex: 1,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: Column(
                    children: [
                      const Text("Security Status Overview", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildSecurityStatusItem("System Secure", "All security checks passed", Colors.green, Icons.check_circle),
                      const SizedBox(height: 12),
                      _buildSecurityStatusItem("1 Warning", "Failed login attempts detected", Colors.orange, Icons.warning),
                      const SizedBox(height: 12),
                      _buildSecurityStatusItem("Security Score", "92/100 - Excellent", Colors.blue, Icons.shield),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Recent Security Events", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(padding:const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.warning_amber, color: Colors.red, size: 20)),
                        title: const Text("Security Alert", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        subtitle: const Text("Multiple failed logins from IP 198.51.100.42", style: TextStyle(fontSize: 11)),
                        trailing: const Text("10m ago", style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ),
                      Center(child: TextButton(onPressed: () {}, child: const Text("View All Security Events"))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- 4. System Settings Tab --------------------
  Widget _buildSystemSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Config
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _buildSettingsSection("General Configuration", Icons.settings, [
                  _buildInputRow("Timezone", "Asia/Colombo"),
                  _buildInputRow("Date Format", "MM/DD/YYYY"),
                  _buildInputRow("Language", "English"),
                  _buildSwitchRow("Maintenance Mode", false),
                  _buildButtonRow("Update General Settings"),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection("Work Order Configuration", Icons.assignment, [
                  _buildInputRow("Default Priority", "Medium"),
                  _buildSwitchRow("Estimation Required", true),
                  _buildSwitchRow("Approval Workflow", true),
                  _buildButtonRow("Update Work Order Settings"),
                ]),
                const SizedBox(height: 20),
                _buildSettingsSection("Notification Settings", Icons.notifications, [
                  _buildSwitchRow("Email Notifications", true),
                  _buildSwitchRow("SMS Notifications", false),
                  _buildSwitchRow("Push Notifications", true),
                  _buildButtonRow("Update Notifications"),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 24),
          // Backup & Integrations
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildSettingsSection("Backup Configuration", Icons.cloud_upload, [
                  _buildSwitchRow("Auto Backup", true),
                  _buildInputRow("Frequency", "Daily"),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: OutlinedButton(onPressed: () {}, child: const Text("Backup Now"))),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white), child: const Text("Configure"))),
                    ],
                  )
                ]),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("System Integrations", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      _buildIntegrationItem("Flight Info System", true, "Connected"),
                      _buildIntegrationItem("Equipment Management", true, "Connected"),
                      _buildIntegrationItem("Payroll System", false, "Disconnected"),
                      const SizedBox(height: 12),
                      SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text("Add Integration"))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Helpers --------------------

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == "Active" ? Colors.green : (status == "Inactive" ? Colors.orange : Colors.red);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(12)),
      child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSeverityBadge(String severity) {
    Color color;
    switch (severity) {
      case "Info": color = Colors.blue; break;
      case "Warning": color = Colors.orange; break;
      case "High": color = Colors.red; break;
      default: color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(4)),
      child: Text(severity, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: const Color(0xFFB71C1C), size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Switch(value: value, activeThumbColor: const Color(0xFFB71C1C), onChanged: (v) {})]),
    );
  }

  Widget _buildInputRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500))]),
    );
  }

  Widget _buildButtonRow(String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB71C1C), foregroundColor: Colors.white),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildSecurityStatusItem(String title, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withAlpha((0.1 * 255).round()), borderRadius: BorderRadius.circular(8)),
      child: Row(children: [Icon(icon, color: color), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)), Text(subtitle, style: TextStyle(fontSize: 12, color: color.withAlpha((0.8 * 255).round())))])]),
    );
  }

  Widget _buildIntegrationItem(String name, bool connected, String statusText) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: connected ? Colors.green : Colors.red, shape: BoxShape.circle)),
      title: Text(name, style: const TextStyle(fontSize: 14)),
      subtitle: Text("https://api.example.com • $statusText", style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: Switch(value: connected, activeThumbColor: Colors.green, onChanged: (v) {}),
    );
  }
}