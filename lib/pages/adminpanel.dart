// lib/pages/adminpanel.dart
// Simple, clean Admin Panel implementation (responsive)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserData {
  final String name;
  final String email;
  final String role;
  final String department;
  final String status;
  final String lastLogin;

  UserData(this.name, this.email, this.role, this.department, this.status, this.lastLogin);
}

class ActivityLogData {
  final String action;
  final String user;
  final String severity;
  final String details;
  final String time;
  final IconData icon;

  ActivityLogData(this.action, this.user, this.severity, this.details, this.time, this.icon);
}

class AdminPanelPage extends StatefulWidget {
  final Map<String, String>? currentUser;
  final VoidCallback? onLogout;

  const AdminPanelPage({super.key, this.currentUser, this.onLogout});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with TickerProviderStateMixin {
  late final TabController _tabController;

  // Mock data
  final List<UserData> _users = List.generate(
    8,
    (i) => UserData('User $i', 'user$i@example.com', i % 2 == 0 ? 'Administrator' : 'Technician', 'Ground Ops', i % 3 == 0 ? 'Suspended' : 'Active', '2026-02-1$i'),
  );

  final List<ActivityLogData> _logs = List.generate(
    12,
    (i) => ActivityLogData('Action $i', 'User $i', i % 3 == 0 ? 'High' : (i % 3 == 1 ? 'Warning' : 'Info'), 'Detail for action $i', '2026-02-1$i 10:0$i', Icons.info_outline),
  );

  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _logSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    _logSearchController.dispose();
    super.dispose();
  }

  void _exportUsers() async {
    final csv = StringBuffer();
    csv.writeln('name,email,role,department,status,lastLogin');
    for (var u in _users) {
      csv.writeln('${u.name},${u.email},${u.role},${u.department},${u.status},${u.lastLogin}');
    }
    await Clipboard.setData(ClipboardData(text: csv.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Users exported to clipboard')));
  }

  void _exportLogs() async {
    final csv = StringBuffer();
    csv.writeln('action,user,severity,details,time');
    for (var l in _logs) {
      csv.writeln('${l.action},${l.user},${l.severity},${l.details},${l.time}');
    }
    await Clipboard.setData(ClipboardData(text: csv.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logs exported to clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              if (widget.onLogout != null) return widget.onLogout!();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SizedBox()));
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Users'), Tab(text: 'Activity'), Tab(text: 'Security'), Tab(text: 'System')],
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

  Widget _buildUserManagement() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isNarrow = constraints.maxWidth < 800;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _userSearchController,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search users...'),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Add')),
                const SizedBox(width: 8),
                OutlinedButton.icon(onPressed: _exportUsers, icon: const Icon(Icons.download), label: const Text('Export')),
              ],
            ),
            const SizedBox(height: 16),
            if (!isNarrow)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Role')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Status')),
                ], rows: _users.map((u) {
                  return DataRow(cells: [
                    DataCell(Text(u.name)),
                    DataCell(Text(u.email)),
                    DataCell(Text(u.role)),
                    DataCell(Text(u.department)),
                    DataCell(Text(u.status)),
                  ]);
                }).toList()),
              )
            else
              Column(children: _users.map((u) => Card(
                child: ListTile(
                  title: Text(u.name),
                  subtitle: Text('${u.email} • ${u.role}'),
                  trailing: Text(u.status),
                ),
              )).toList()),
          ],
        ),
      );
    });
  }

  Widget _buildActivityLogs() {
    return LayoutBuilder(builder: (ctx, constraints) {
      final isNarrow = constraints.maxWidth < 800;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: _logSearchController,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search activities...'),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: _exportLogs, icon: const Icon(Icons.download), label: const Text('Export')),
            const SizedBox(width: 8),
            OutlinedButton.icon(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh), label: const Text('Refresh')),
          ]),
          const SizedBox(height: 16),
          if (!isNarrow)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(columns: const [
                DataColumn(label: Text('Action')),
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Severity')),
                DataColumn(label: Text('Details')),
                DataColumn(label: Text('Time')),
              ], rows: _logs.map((l) => DataRow(cells: [
                DataCell(Text(l.action)),
                DataCell(Text(l.user)),
                DataCell(Text(l.severity)),
                DataCell(Text(l.details)),
                DataCell(Text(l.time)),
              ])).toList()),
            )
          else
            Column(children: _logs.map((l) => Card(
              child: ListTile(
                leading: Icon(l.icon),
                title: Text(l.action),
                subtitle: Text('${l.user} • ${l.severity}\n${l.details}'),
                isThreeLine: true,
                trailing: Text(l.time),
              ),
            )).toList())
        ]),
      );
    });
  }

  Widget _buildSecurity() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Security Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        SwitchListTile(value: true, onChanged: (_) {}, title: const Text('Require 2FA')),
        SwitchListTile(value: false, onChanged: (_) {}, title: const Text('Enforce Password Complexity')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () {}, child: const Text('Save Security Settings')),
      ]),
    );
  }

  Widget _buildSystemSettings() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('System Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListTile(title: const Text('App Version'), subtitle: const Text('1.0.0')),
        ListTile(title: const Text('Database'), subtitle: const Text('Connected')),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: () {}, child: const Text('Run Backup')),
      ]),
    );
  }
}
