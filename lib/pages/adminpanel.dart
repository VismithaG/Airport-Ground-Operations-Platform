// lib/pages/adminpanel.dart
// Recreated Admin Panel with 4 tabs: User Management, Activity Logs, Security, System Settings.

// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final String details;
  final String severity; // Info, Warning, High
  final String time;
  final IconData icon;

  ActivityLogData(this.action, this.user, this.details, this.severity, this.time, this.icon);
}

class AdminPanelPage extends StatefulWidget {
  final Map<String, String>? currentUser;
  final void Function(BuildContext)? onLogout;

  const AdminPanelPage({super.key, this.currentUser, this.onLogout});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  // Mock data stores
  final List<UserData> _users = List.generate(
    10,
    (i) => UserData('User $i', 'user$i@example.com', i % 3 == 0 ? 'Administrator' : 'Technician', 'Ground Ops', i % 4 == 0 ? 'Suspended' : 'Active', '2026-02-1${i + 1}'),
  );

  final List<ActivityLogData> _logs = List.generate(
    16,
    (i) => ActivityLogData('Action $i', 'User ${i % 10}', 'Details for action $i', i % 3 == 0 ? 'High' : (i % 3 == 1 ? 'Warning' : 'Info'), '2026-02-1${i + 1} 10:0$i', Icons.info_outline),
  );

  // UI state
  late List<UserData> _displayedUsers;
  late List<ActivityLogData> _displayedLogs;
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _logSearchController = TextEditingController();
  String _userFilterStatus = 'All';
  String _logSeverityFilter = 'All';

  // Security/System settings (mock)
  bool _requireUppercase = true;
  bool _requireLowercase = true;
  bool _requireNumbers = true;
  bool _requireSpecial = false;
  int _minPasswordLength = 8;
  int _passwordExpiryDays = 90;

  String _sessionTimeout = '30m';
  String _maxConcurrentSessions = '3';
  bool _requireReauth = false;
  bool _logoutOnClose = false;

  int _maxFailedAttempts = 5;
  String _lockoutDuration = '15m';
  bool _twoFactor = false;

  String _companyName = 'AGO Platform';
  String _defaultTimezone = 'UTC';
  bool _maintenanceMode = false;
  bool _autoAssign = true;
  String _defaultPriority = 'Medium';

  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _displayedUsers = List.from(_users);
    _displayedLogs = List.from(_logs);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    _logSearchController.dispose();
    super.dispose();
  }

  // -------------------- Helpers --------------------
  void _filterUsers() {
    final q = _userSearchController.text.toLowerCase();
    setState(() {
      _displayedUsers = _users.where((u) {
        final matchesQuery = q.isEmpty || u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.role.toLowerCase().contains(q);
        final matchesStatus = _userFilterStatus == 'All' || u.status == _userFilterStatus;
        return matchesQuery && matchesStatus;
      }).toList();
    });
  }

  void _filterLogs() {
    final q = _logSearchController.text.toLowerCase();
    setState(() {
      _displayedLogs = _logs.where((l) {
        final matchesQuery = q.isEmpty || l.action.toLowerCase().contains(q) || l.user.toLowerCase().contains(q) || l.details.toLowerCase().contains(q);
        final matchesSeverity = _logSeverityFilter == 'All' || l.severity == _logSeverityFilter;
        return matchesQuery && matchesSeverity;
      }).toList();
    });
  }

  Future<void> _exportUsers() async {
    final csv = StringBuffer();
    csv.writeln('name,email,role,department,status,lastLogin');
    for (var u in _displayedUsers) {
      csv.writeln('${u.name},${u.email},${u.role},${u.department},${u.status},${u.lastLogin}');
    }
    await Clipboard.setData(ClipboardData(text: csv.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Users exported to clipboard')));
  }

  Future<void> _exportLogs() async {
    final csv = StringBuffer();
    csv.writeln('action,user,details,severity,time');
    for (var l in _displayedLogs) {
      csv.writeln('${l.action},${l.user},${l.details},${l.severity},${l.time}');
    }
    await Clipboard.setData(ClipboardData(text: csv.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs exported to clipboard')));
  }

  Future<void> _showUserDialog({UserData? editUser}) async {
    final nameCtl = TextEditingController(text: editUser?.name ?? '');
    final emailCtl = TextEditingController(text: editUser?.email ?? '');
    final roleCtl = TextEditingController(text: editUser?.role ?? 'Service Technician');
    final deptCtl = TextEditingController(text: editUser?.department ?? 'Ground Operations');
    String status = editUser?.status ?? 'Active';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(editUser == null ? 'Add User' : 'Edit User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Full Name')),
              TextField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: roleCtl, decoration: const InputDecoration(labelText: 'Role')),
              TextField(controller: deptCtl, decoration: const InputDecoration(labelText: 'Department')),
              DropdownButtonFormField<String>(initialValue: status, items: const ['Active', 'Inactive', 'Suspended'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) => status = v ?? status),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(editUser == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      final newUser = UserData(nameCtl.text, emailCtl.text, roleCtl.text, deptCtl.text, status, DateTime.now().toIso8601String());
      setState(() {
        if (editUser != null) {
          final idx = _users.indexOf(editUser);
          if (idx >= 0) _users[idx] = newUser;
        } else {
          _users.insert(0, newUser);
        }
        _filterUsers();
      });
    }
  }

  Future<void> _confirmDeleteUser(UserData user) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: const Text('Delete user'), content: Text('Delete ${user.name}?'), actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete'))]));
    if (ok == true) {
      setState(() {
        _users.remove(user);
        _filterUsers();
      });
    }
  }

  // -------------------- Build --------------------
  @override
  Widget build(BuildContext context) {
    final userName = widget.currentUser?['name'] ?? 'Administrator';
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin - $userName'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'profile') {
                  showDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Profile'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(radius: 28, child: Text(userName.isNotEmpty ? userName[0] : 'A')),
                          const SizedBox(height: 12),
                          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(widget.currentUser?['email'] ?? '', style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(widget.currentUser?['role'] ?? '', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            if (widget.onLogout != null) widget.onLogout!(context);
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                }
                if (v == 'logout') {
                  if (widget.onLogout != null) return widget.onLogout!(context);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SizedBox()));
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'profile', child: Text('Profile')),
                PopupMenuItem(value: 'logout', child: Text('Logout')),
              ],
              child: CircleAvatar(radius: 18, child: Text(userName.isNotEmpty ? userName[0] : 'A')),
            ),
          ),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Users'), Tab(text: 'Activity'), Tab(text: 'Security'), Tab(text: 'System')]),
      ),
      body: TabBarView(controller: _tabController, children: [_buildUserManagement(), _buildActivityLogs(), _buildSecurity(), _buildSystemSettings()]),
    );
  }

  // -------------------- User Management Tab --------------------
  Widget _buildUserManagement() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isNarrow = constraints.maxWidth < 900;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stat cards
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              const SizedBox(width: 8),
              SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('Total Users', '${_users.length}', Icons.people, Colors.blue)),
              const SizedBox(width: 12),
              SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('Active', '${_users.where((u) => u.status == 'Active').length}', Icons.check_circle, Colors.green)),
              const SizedBox(width: 12),
              SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('Inactive', '${_users.where((u) => u.status == 'Inactive').length}', Icons.pause_circle, Colors.orange)),
              const SizedBox(width: 12),
              SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('Suspended', '${_users.where((u) => u.status == 'Suspended').length}', Icons.block, Colors.red)),
              const SizedBox(width: 8),
            ]),
          ),
          const SizedBox(height: 20),

          // Toolbar
          Row(children: [
            Expanded(
              child: TextField(
                controller: _userSearchController,
                decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search users...', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300))),
                onChanged: (v) => _filterUsers(),
              ),
            ),
            const SizedBox(width: 12),
            DropdownButton<String>(value: _userFilterStatus, items: const ['All', 'Active', 'Inactive', 'Suspended'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) { if (v == null) return; setState(() { _userFilterStatus = v; _filterUsers(); }); }),
            const SizedBox(width: 12),
            ElevatedButton.icon(onPressed: () => _showUserDialog(), icon: const Icon(Icons.add), label: const Text('Add User')),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: _exportUsers, icon: const Icon(Icons.download), label: const Text('Export')),
          ]),
          const SizedBox(height: 16),

          // Table or Cards
          if (!isNarrow)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 900),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.grey[50]),
                  columns: const [
                    DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Department', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Last Login', style: TextStyle(fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                  rows: _displayedUsers.map((user) {
                    return DataRow(cells: [
                      DataCell(Row(children: [CircleAvatar(radius: 16, backgroundColor: Colors.red.shade50, child: Text(user.name[0], style: const TextStyle(color: Colors.red, fontSize: 12))), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(user.name, style: const TextStyle(fontWeight: FontWeight.w600)), Text(user.email, style: const TextStyle(fontSize: 11, color: Colors.grey))])])),
                      DataCell(Text(user.role)),
                      DataCell(Text(user.department)),
                      DataCell(_buildStatusBadge(user.status)),
                      DataCell(Text(user.lastLogin)),
                      DataCell(Row(children: [IconButton(icon: const Icon(Icons.visibility_outlined, size: 18, color: Colors.grey), onPressed: () {}), IconButton(icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue), onPressed: () => _showUserDialog(editUser: user)), IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () => _confirmDeleteUser(user))])),
                    ]);
                  }).toList(),
                ),
              ),
            )
          else
            Column(
              children: _displayedUsers
                  .map((user) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.red.shade50, child: Text(user.name[0])),
                          title: Text(user.name),
                          subtitle: Text('${user.email}\n${user.role}'),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'edit') _showUserDialog(editUser: user);
                              if (v == 'delete') _confirmDeleteUser(user);
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ]),
      );
    });
  }

  // -------------------- Activity Logs --------------------
  Widget _buildActivityLogs() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isNarrow = constraints.maxWidth < 900;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Stats
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [const SizedBox(width: 8), SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('Total Events', '${_logs.length}', Icons.list_alt, Colors.blue)), const SizedBox(width: 12), SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('High Priority', '${_logs.where((l) => l.severity == 'High').length}', Icons.warning, Colors.red)), const SizedBox(width: 12), SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('Warnings', '${_logs.where((l) => l.severity == 'Warning').length}', Icons.error_outline, Colors.orange)), const SizedBox(width: 12), SizedBox(width: isNarrow ? 240 : 200, child: _buildStatCard('Information', '${_logs.where((l) => l.severity == 'Info').length}', Icons.info_outline, Colors.blueAccent)), const SizedBox(width: 8)])),
          const SizedBox(height: 20),

          // Toolbar
          Row(children: [
            Expanded(child: TextField(controller: _logSearchController, decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search activities...', filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300))), onChanged: (v) => _filterLogs())),
            const SizedBox(width: 12),
            DropdownButton<String>(value: _logSeverityFilter, items: const ['All', 'Info', 'Warning', 'High'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(), onChanged: (v) { if (v == null) return; setState(() { _logSeverityFilter = v; _filterLogs(); }); }),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: _exportLogs, icon: const Icon(Icons.download), label: const Text('Export Logs')),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh), label: const Text('Refresh')),
          ]),
          const SizedBox(height: 20),

          // Table or Card list
          if (!isNarrow)
            SingleChildScrollView(scrollDirection: Axis.horizontal, child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 900), child: DataTable(headingRowColor: WidgetStateProperty.all(Colors.grey[50]), columns: const [DataColumn(label: Text('Activity', style: TextStyle(fontWeight: FontWeight.bold))), DataColumn(label: Text('User', style: TextStyle(fontWeight: FontWeight.bold))), DataColumn(label: Text('Details', style: TextStyle(fontWeight: FontWeight.bold))), DataColumn(label: Text('Severity', style: TextStyle(fontWeight: FontWeight.bold))), DataColumn(label: Text('Time Stamp', style: TextStyle(fontWeight: FontWeight.bold)))], rows: _displayedLogs.map((log) {
              return DataRow(cells: [
                DataCell(Row(children: [Icon(log.icon, size: 18, color: Colors.grey[700]), const SizedBox(width: 8), Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600))])),
                DataCell(Row(children: [CircleAvatar(radius: 12, backgroundColor: Colors.grey[200], child: Text(log.user[0], style: const TextStyle(fontSize: 10, color: Colors.black87))), const SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [Text(log.user, style: const TextStyle(fontWeight: FontWeight.w500))])])),
                DataCell(SizedBox(width: 300, child: Text(log.details, overflow: TextOverflow.ellipsis))),
                DataCell(_buildSeverityBadge(log.severity)),
                DataCell(Text(log.time)),
              ]);
            }).toList())) )
          else
            Column(children: _displayedLogs.map((log) => Card(margin: const EdgeInsets.symmetric(vertical: 8), child: ListTile(leading: Icon(log.icon, color: Colors.grey[700]), title: Text(log.action), subtitle: Text(log.details), trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ _buildSeverityBadge(log.severity), const SizedBox(height: 6), Text(log.time, style: const TextStyle(fontSize: 11, color: Colors.grey)) ],),), ), ).toList()),
        ]),
      );
    });
  }

  // -------------------- Security --------------------
  Widget _buildSecurity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        if (isNarrow) {
          return Column(children: [
            _buildSettingsSection('Password Policy', Icons.vpn_key, [
              _buildSwitchRow('Require Uppercase', _requireUppercase, (v) => setState(() => _requireUppercase = v)),
              _buildSwitchRow('Require Lowercase', _requireLowercase, (v) => setState(() => _requireLowercase = v)),
              _buildSwitchRow('Require Numbers', _requireNumbers, (v) => setState(() => _requireNumbers = v)),
              _buildSwitchRow('Require Special Characters', _requireSpecial, (v) => setState(() => _requireSpecial = v)),
              _buildInputRow('Minimum Length', '$_minPasswordLength', onChanged: (v) => setState(() => _minPasswordLength = int.tryParse(v) ?? _minPasswordLength)),
              _buildInputRow('Password Expiry (days)', '$_passwordExpiryDays', onChanged: (v) => setState(() => _passwordExpiryDays = int.tryParse(v) ?? _passwordExpiryDays)),
              _buildButtonRow('Update Policy', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password policy saved')))),
            ]),
            const SizedBox(height: 16),
            _buildSettingsSection('Session Security', Icons.timer, [
              _buildInputRow('Session Timeout', _sessionTimeout, onChanged: (v) => setState(() => _sessionTimeout = v)),
              _buildInputRow('Max Concurrent Sessions', _maxConcurrentSessions, onChanged: (v) => setState(() => _maxConcurrentSessions = v)),
              _buildSwitchRow('Require Re-authentication', _requireReauth, (v) => setState(() => _requireReauth = v)),
              _buildSwitchRow('Logout on Browser Close', _logoutOnClose, (v) => setState(() => _logoutOnClose = v)),
              _buildButtonRow('Update Session', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session settings saved')))),
            ]),
            const SizedBox(height: 16),
            _buildSettingsSection('Access Control', Icons.shield, [
              _buildInputRow('Max Failed Attempts', '$_maxFailedAttempts', onChanged: (v) => setState(() => _maxFailedAttempts = int.tryParse(v) ?? _maxFailedAttempts)),
              _buildInputRow('Lockout Duration', _lockoutDuration, onChanged: (v) => setState(() => _lockoutDuration = v)),
              _buildSwitchRow('Two-Factor Authentication', _twoFactor, (v) => setState(() => _twoFactor = v)),
              const Divider(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Allowed IP Ranges', style: TextStyle(fontWeight: FontWeight.bold))),
              const ListTile(dense: true, title: Text('192.168.1.0/24'), trailing: Icon(Icons.delete, size: 16)),
              const ListTile(dense: true, title: Text('10.0.0.0/16'), trailing: Icon(Icons.delete, size: 16)),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Add Range')),
            ]),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Security Status Overview', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), _buildSecurityStatusItem('System Secure', 'All security checks passed', Colors.green, Icons.check_circle), const SizedBox(height: 12), _buildSecurityStatusItem('1 Warning', 'Failed login attempts detected', Colors.orange, Icons.warning), const SizedBox(height: 12), _buildSecurityStatusItem('Security Score', '92/100 - Excellent', Colors.blue, Icons.shield),])),
          ]);
        }

        // Wide layout: two columns
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: Column(children: [
            _buildSettingsSection('Password Policy', Icons.vpn_key, [
              _buildSwitchRow('Require Uppercase', _requireUppercase, (v) => setState(() => _requireUppercase = v)),
              _buildSwitchRow('Require Lowercase', _requireLowercase, (v) => setState(() => _requireLowercase = v)),
              _buildSwitchRow('Require Numbers', _requireNumbers, (v) => setState(() => _requireNumbers = v)),
              _buildSwitchRow('Require Special Characters', _requireSpecial, (v) => setState(() => _requireSpecial = v)),
              _buildInputRow('Minimum Length', '$_minPasswordLength', onChanged: (v) => setState(() => _minPasswordLength = int.tryParse(v) ?? _minPasswordLength)),
              _buildInputRow('Password Expiry (days)', '$_passwordExpiryDays', onChanged: (v) => setState(() => _passwordExpiryDays = int.tryParse(v) ?? _passwordExpiryDays)),
              _buildButtonRow('Update Policy', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password policy saved')))),
            ]),
            const SizedBox(height: 20),
            _buildSettingsSection('Session Security', Icons.timer, [
              _buildInputRow('Session Timeout', _sessionTimeout, onChanged: (v) => setState(() => _sessionTimeout = v)),
              _buildInputRow('Max Concurrent Sessions', _maxConcurrentSessions, onChanged: (v) => setState(() => _maxConcurrentSessions = v)),
              _buildSwitchRow('Require Re-authentication', _requireReauth, (v) => setState(() => _requireReauth = v)),
              _buildSwitchRow('Logout on Browser Close', _logoutOnClose, (v) => setState(() => _logoutOnClose = v)),
              _buildButtonRow('Update Session', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session settings saved')))),
            ]),
            const SizedBox(height: 20),
            _buildSettingsSection('Access Control', Icons.shield, [
              _buildInputRow('Max Failed Attempts', '$_maxFailedAttempts', onChanged: (v) => setState(() => _maxFailedAttempts = int.tryParse(v) ?? _maxFailedAttempts)),
              _buildInputRow('Lockout Duration', _lockoutDuration, onChanged: (v) => setState(() => _lockoutDuration = v)),
              _buildSwitchRow('Two-Factor Authentication', _twoFactor, (v) => setState(() => _twoFactor = v)),
              const Divider(),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Text('Allowed IP Ranges', style: TextStyle(fontWeight: FontWeight.bold))),
              const ListTile(dense: true, title: Text('192.168.1.0/24'), trailing: Icon(Icons.delete, size: 16)),
              const ListTile(dense: true, title: Text('10.0.0.0/16'), trailing: Icon(Icons.delete, size: 16)),
              OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.add, size: 16), label: const Text('Add Range')),
            ]),
          ])),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: Column(children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(children: [const Text('Security Status Overview', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 16), _buildSecurityStatusItem('System Secure', 'All security checks passed', Colors.green, Icons.check_circle), const SizedBox(height: 12), _buildSecurityStatusItem('1 Warning', 'Failed login attempts detected', Colors.orange, Icons.warning), const SizedBox(height: 12), _buildSecurityStatusItem('Security Score', '92/100 - Excellent', Colors.blue, Icons.shield)])),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Recent Security Events', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), ListTile(contentPadding: EdgeInsets.zero, leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.warning_amber, color: Colors.red, size: 20)), title: const Text('Security Alert', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)), subtitle: const Text('Multiple failed logins from IP 198.51.100.42', style: TextStyle(fontSize: 11)), trailing: const Text('10m ago', style: TextStyle(fontSize: 11, color: Colors.grey))), Center(child: TextButton(onPressed: () {}, child: const Text('View All Security Events')))])),
          ]))
        ]);
      }),
    );
  }

  // -------------------- System Settings --------------------
  Widget _buildSystemSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: LayoutBuilder(builder: (ctx, constraints) {
        final isNarrow = constraints.maxWidth < 900;
        if (isNarrow) {
          return Column(children: [
            _buildSettingsSection('General Settings', Icons.settings, [
              _buildInputRow('Company Name', _companyName, onChanged: (v) => setState(() => _companyName = v)),
              _buildInputRow('Default Timezone', _defaultTimezone, onChanged: (v) => setState(() => _defaultTimezone = v)),
              _buildSwitchRow('Enable Maintenance Mode', _maintenanceMode, (v) => setState(() => _maintenanceMode = v)),
              _buildButtonRow('Save General', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('General settings saved')))),
            ]),
            const SizedBox(height: 16),
            _buildSettingsSection('Work Order Settings', Icons.build_circle, [
              _buildSwitchRow('Enable Auto-Assign', _autoAssign, (v) => setState(() => _autoAssign = v)),
              _buildInputRow('Default Priority', _defaultPriority, onChanged: (v) => setState(() => _defaultPriority = v)),
              _buildButtonRow('Save Work Order', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work order settings saved')))),
            ]),
            const SizedBox(height: 16),
            _buildSettingsSection('Notifications', Icons.notifications, [
              _buildSwitchRow('Email Notifications', _emailNotifications, (v) => setState(() => _emailNotifications = v)),
              _buildSwitchRow('SMS Notifications', _smsNotifications, (v) => setState(() => _smsNotifications = v)),
              _buildSwitchRow('Push Notifications', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
              _buildButtonRow('Save Notifications', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings saved')))),
            ]),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('System Info', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), _buildInfoRow('Version', '1.0.3'), _buildInfoRow('Uptime', '3 days 4 hours'), _buildInfoRow('DB Status', 'Connected'), _buildInfoRow('Storage', '120GB / 256GB')])),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Backups', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), _buildInfoRow('Last Backup', '2 hours ago'), _buildInfoRow('Next Backup', 'in 22 hours'), const SizedBox(height: 12), Row(children: [ElevatedButton(onPressed: () {}, child: const Text('Run Backup Now')), const SizedBox(width: 8), OutlinedButton(onPressed: () {}, child: const Text('Restore'))])])),
          ]);
        }

        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 2, child: Column(children: [
            _buildSettingsSection('General Settings', Icons.settings, [
              _buildInputRow('Company Name', _companyName, onChanged: (v) => setState(() => _companyName = v)),
              _buildInputRow('Default Timezone', _defaultTimezone, onChanged: (v) => setState(() => _defaultTimezone = v)),
              _buildSwitchRow('Enable Maintenance Mode', _maintenanceMode, (v) => setState(() => _maintenanceMode = v)),
              _buildButtonRow('Save General', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('General settings saved')))),
            ]),
            const SizedBox(height: 20),
            _buildSettingsSection('Work Order Settings', Icons.build_circle, [
              _buildSwitchRow('Enable Auto-Assign', _autoAssign, (v) => setState(() => _autoAssign = v)),
              _buildInputRow('Default Priority', _defaultPriority, onChanged: (v) => setState(() => _defaultPriority = v)),
              _buildButtonRow('Save Work Order', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work order settings saved')))),
            ]),
            const SizedBox(height: 20),
            _buildSettingsSection('Notifications', Icons.notifications, [
              _buildSwitchRow('Email Notifications', _emailNotifications, (v) => setState(() => _emailNotifications = v)),
              _buildSwitchRow('SMS Notifications', _smsNotifications, (v) => setState(() => _smsNotifications = v)),
              _buildSwitchRow('Push Notifications', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
              _buildButtonRow('Save Notifications', () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notification settings saved')))),
            ]),
          ])),
          const SizedBox(width: 24),
          Expanded(flex: 1, child: Column(children: [
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('System Info', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), _buildInfoRow('Version', '1.0.3'), _buildInfoRow('Uptime', '3 days 4 hours'), _buildInfoRow('DB Status', 'Connected'), _buildInfoRow('Storage', '120GB / 256GB')])),
            const SizedBox(height: 20),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Backups', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 12), _buildInfoRow('Last Backup', '2 hours ago'), _buildInfoRow('Next Backup', 'in 22 hours'), const SizedBox(height: 12), Row(children: [ElevatedButton(onPressed: () {}, child: const Text('Run Backup Now')), const SizedBox(width: 8), OutlinedButton(onPressed: () {}, child: const Text('Restore'))])])),
          ])),
        ]);
      }),
    );
  }

  // -------------------- Small UI helpers --------------------
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      // ignore: deprecated_member_use
      child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))])]),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    if (status == 'Active') {
      bg = Colors.green.shade50;
    } else if (status == 'Suspended') bg = Colors.red.shade50;
    else bg = Colors.orange.shade50;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Text(status, style: const TextStyle(fontSize: 12)));
  }

  Widget _buildSeverityBadge(String severity) {
    Color c;
    if (severity == 'High') c = Colors.red;
    else if (severity == 'Warning') c = Colors.orange;
    else c = Colors.blue;
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Text(severity, style: TextStyle(color: c, fontSize: 12)));
  }

  Widget _buildSettingsSection(String title, IconData icon, List<Widget> children) {
    return Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(icon, color: Colors.grey[700]), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]), const SizedBox(height: 12), ...children]));
  }

  Widget _buildSwitchRow(String label, bool value, ValueChanged<bool> onChanged) => SwitchListTile(value: value, onChanged: onChanged, title: Text(label));

  Widget _buildInputRow(String label, String initial, {ValueChanged<String>? onChanged}) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: TextField(decoration: InputDecoration(labelText: label, filled: true, fillColor: Colors.grey[50], border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200))), controller: TextEditingController(text: initial), onChanged: onChanged));

  Widget _buildButtonRow(String label, VoidCallback onPressed) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [ElevatedButton(onPressed: onPressed, child: Text(label))]));

  Widget _buildInfoRow(String key, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(key), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]));

  Widget _buildSecurityStatusItem(String title, String subtitle, Color color, IconData icon) => Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.grey))])]);
}

