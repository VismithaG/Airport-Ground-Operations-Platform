// lib/admin_panel.dart
import 'package:flutter/material.dart';

// ----------------------------
// Models & Mock Data (replace with your real data files)
// ----------------------------
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String status;
  final String? lastLogin;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.status,
    this.lastLogin,
  });
}

class ActivityLog {
  final String id;
  final String action;
  final String user;
  final String details;
  final String type;
  final String severity;
  final String timestamp;

  ActivityLog({
    required this.id,
    required this.action,
    required this.user,
    required this.details,
    required this.type,
    required this.severity,
    required this.timestamp,
  });
}

class PasswordPolicy {
  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireNumbers;
  final bool requireSpecialChars;
  final int passwordExpiry;
  final int preventReuse;

  PasswordPolicy({
    required this.minLength,
    required this.requireUppercase,
    required this.requireLowercase,
    required this.requireNumbers,
    required this.requireSpecialChars,
    required this.passwordExpiry,
    required this.preventReuse,
  });
}

class SecuritySettings {
  final PasswordPolicy passwordPolicy;
  final SessionSecurity sessionSecurity;
  final AccessControl accessControl;
  final AuditSettings auditSettings;

  SecuritySettings({
    required this.passwordPolicy,
    required this.sessionSecurity,
    required this.accessControl,
    required this.auditSettings,
  });
}

class SessionSecurity {
  final int sessionTimeout;
  final int maxConcurrentSessions;
  final bool requireReauth;
  final bool logoutOnClose;

  SessionSecurity({
    required this.sessionTimeout,
    required this.maxConcurrentSessions,
    required this.requireReauth,
    required this.logoutOnClose,
  });
}

class AccessControl {
  final int maxFailedAttempts;
  final int lockoutDuration;
  final bool enableTwoFactor;
  final List<String> allowedIpRanges;

  AccessControl({
    required this.maxFailedAttempts,
    required this.lockoutDuration,
    required this.enableTwoFactor,
    required this.allowedIpRanges,
  });
}

class AuditSettings {
  final int logRetention;
  final bool enableRealTimeAlerts;
  final int alertThreshold;
  final bool exportEnabled;

  AuditSettings({
    required this.logRetention,
    required this.enableRealTimeAlerts,
    required this.alertThreshold,
    required this.exportEnabled,
  });
}

class WorkOrderSettings {
  final bool autoAssignment;
  final List<String> priorityLevels;
  final String defaultPriority;
  final bool estimationRequired;
  final int maxActiveOrders;
  final bool approvalWorkflow;

  WorkOrderSettings({
    required this.autoAssignment,
    required this.priorityLevels,
    required this.defaultPriority,
    required this.estimationRequired,
    required this.maxActiveOrders,
    required this.approvalWorkflow,
  });
}

class NotificationsSettings {
  final bool emailEnabled;
  final bool smsEnabled;
  final bool pushEnabled;
  final int escalationTime;
  final int reminderInterval;
  final QuietHours quietHours;

  NotificationsSettings({
    required this.emailEnabled,
    required this.smsEnabled,
    required this.pushEnabled,
    required this.escalationTime,
    required this.reminderInterval,
    required this.quietHours,
  });
}

class QuietHours {
  final bool enabled;
  final String start;
  final String end;
  QuietHours({required this.enabled, required this.start, required this.end});
}

class BackupSettings {
  final bool autoBackup;
  final String frequency;
  final int retentionDays;
  final String location;
  final String? lastBackup;
  final String? nextBackup;

  BackupSettings({
    required this.autoBackup,
    required this.frequency,
    required this.retentionDays,
    required this.location,
    this.lastBackup,
    this.nextBackup,
  });
}

class IntegrationInfo {
  final String endpoint;
  final String status;
  final bool enabled;
  final String? lastSync;

  IntegrationInfo({
    required this.endpoint,
    required this.status,
    required this.enabled,
    this.lastSync,
  });
}

class SystemSettings {
  final GeneralSettings general;
  final WorkOrderSettings workOrders;
  final NotificationsSettings notifications;
  final BackupSettings backup;
  final Map<String, IntegrationInfo> integrations;

  SystemSettings({
    required this.general,
    required this.workOrders,
    required this.notifications,
    required this.backup,
    required this.integrations,
  });
}

class GeneralSettings {
  final String systemName;
  final String timezone;
  final String dateFormat;
  final String timeFormat;
  final String language;
  final bool maintenanceMode;

  GeneralSettings({
    required this.systemName,
    required this.timezone,
    required this.dateFormat,
    required this.timeFormat,
    required this.language,
    required this.maintenanceMode,
  });
}

// --- Minimal mock data to make the file runnable (replace with your own)
final List<UserModel> mockUsers = [
  UserModel(
    id: 'u1',
    name: 'Alice Johnson',
    email: 'alice@airport.com',
    role: 'Supervisor',
    department: 'Ground Ops',
    status: 'active',
    lastLogin: DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
  ),
  UserModel(
    id: 'u2',
    name: 'Bob Smith',
    email: 'bob@airport.com',
    role: 'Technician',
    department: 'Maintenance',
    status: 'inactive',
    lastLogin: DateTime.now().subtract(const Duration(days: 3)).toIso8601String(),
  ),
  UserModel(
    id: 'u3',
    name: 'Admin User',
    email: 'admin@airport.com',
    role: 'Administrator',
    department: 'IT',
    status: 'active',
    lastLogin: DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
  ),
];

final List<ActivityLog> mockActivityLogs = [
  ActivityLog(
    id: 'a1',
    action: 'User login',
    user: 'Alice Johnson',
    details: 'Successful login from 192.168.1.10',
    type: 'authentication',
    severity: 'info',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
  ),
  ActivityLog(
    id: 'a2',
    action: 'Work order created',
    user: 'Bob Smith',
    details: 'WO#12345: Replace brake pads',
    type: 'work_order',
    severity: 'warning',
    timestamp: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
  ),
  ActivityLog(
    id: 'a3',
    action: 'Failed login attempts',
    user: 'System',
    details: 'Multiple failed logins from 10.0.0.5',
    type: 'security',
    severity: 'high',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
  ),
];

final SecuritySettings securitySettings = SecuritySettings(
  passwordPolicy: PasswordPolicy(
    minLength: 8,
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: false,
    passwordExpiry: 90,
    preventReuse: 5,
  ),
  sessionSecurity: SessionSecurity(
    sessionTimeout: 30,
    maxConcurrentSessions: 3,
    requireReauth: true,
    logoutOnClose: false,
  ),
  accessControl: AccessControl(
    maxFailedAttempts: 5,
    lockoutDuration: 30,
    enableTwoFactor: true,
    allowedIpRanges: ['192.168.0.0/24', '10.0.0.0/16'],
  ),
  auditSettings: AuditSettings(
    logRetention: 365,
    enableRealTimeAlerts: true,
    alertThreshold: 10,
    exportEnabled: false,
  ),
);

final SystemSettings systemSettings = SystemSettings(
  general: GeneralSettings(
    systemName: 'Airport Ops',
    timezone: 'Asia/Colombo',
    dateFormat: 'yyyy-MM-dd',
    timeFormat: 'HH:mm',
    language: 'English',
    maintenanceMode: false,
  ),
  workOrders: WorkOrderSettings(
    autoAssignment: true,
    priorityLevels: ['Low', 'Medium', 'High'],
    defaultPriority: 'Medium',
    estimationRequired: false,
    maxActiveOrders: 50,
    approvalWorkflow: true,
  ),
  notifications: NotificationsSettings(
    emailEnabled: true,
    smsEnabled: false,
    pushEnabled: true,
    escalationTime: 30,
    reminderInterval: 60,
    quietHours: QuietHours(enabled: true, start: '22:00', end: '06:00'),
  ),
  backup: BackupSettings(
    autoBackup: true,
    frequency: 'daily',
    retentionDays: 30,
    location: 'us-east-1',
    lastBackup: DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
    nextBackup: DateTime.now().add(const Duration(hours: 12)).toIso8601String(),
  ),
  integrations: {
    'PaymentAPI': IntegrationInfo(
      endpoint: 'https://api.payment.example',
      status: 'connected',
      enabled: true,
      lastSync: DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
    ),
    'WeatherService': IntegrationInfo(
      endpoint: 'https://api.weather.example',
      status: 'disconnected',
      enabled: false,
      lastSync: null,
    ),
  },
);

// ----------------------------
// Admin Panel Widget
// ----------------------------
class AdminPanelPage extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onLogout;
  final void Function(String userId) onNavigateToUserDetails;
  final List<UserModel> users;
  final List<ActivityLog> activityLogs;
  final SecuritySettings security;
  final SystemSettings settings;

  AdminPanelPage({
    super.key,
    required this.currentUser,
    required this.onLogout,
    required this.onNavigateToUserDetails,
    this.users = const [],
    this.activityLogs = const [],
    SecuritySettings? security,
    SystemSettings? settings,
  })  : security = security ?? securitySettings,
        settings = settings ?? systemSettings;

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> with SingleTickerProviderStateMixin {
  // Filters & state
  String searchQuery = '';
  String statusFilter = 'all';
  String departmentFilter = 'all';

  String activitySearchQuery = '';
  String activityTypeFilter = 'all';
  String activitySeverityFilter = 'all';

  late TabController _tabController;

  late List<UserModel> _users;
  late List<ActivityLog> _activityLogs;
  late SecuritySettings _security;
  late SystemSettings _settings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Set defaults from widget or use mock data
    _users = widget.users.isEmpty ? mockUsers : widget.users;
    _activityLogs = widget.activityLogs.isEmpty ? mockActivityLogs : widget.activityLogs;
    _security = widget.security;
    _settings = widget.settings;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Derived lists
  List<UserModel> get _filteredUsers {
    return _users
        .where((u) =>
            (searchQuery.isEmpty || u.name.toLowerCase().contains(searchQuery.toLowerCase()) || u.email.toLowerCase().contains(searchQuery.toLowerCase())) &&
            (statusFilter == 'all' || u.status == statusFilter) &&
            (departmentFilter == 'all' || u.department == departmentFilter))
        .toList();
  }

  List<ActivityLog> get _filteredActivityLogs {
    return _activityLogs
        .where((log) =>
            (activitySearchQuery.isEmpty || log.action.toLowerCase().contains(activitySearchQuery.toLowerCase()) || log.details.toLowerCase().contains(activitySearchQuery.toLowerCase())) &&
            (activityTypeFilter == 'all' || log.type == activityTypeFilter) &&
            (activitySeverityFilter == 'all' || log.severity == activitySeverityFilter))
        .toList();
  }

  // Helper derived stats
  Map<String, int> get userStats {
    final total = _users.length;
    final active = _users.where((u) => u.status == 'active').length;
    final inactive = _users.where((u) => u.status == 'inactive').length;
    final suspended = _users.where((u) => u.status == 'suspended').length;
    return {'total': total, 'active': active, 'inactive': inactive, 'suspended': suspended};
  }

  Map<String, int> get activityStats {
    final total = _activityLogs.length;
    final high = _activityLogs.where((a) => a.severity == 'high').length;
    final warning = _activityLogs.where((a) => a.severity == 'warning').length;
    final info = _activityLogs.where((a) => a.severity == 'info').length;
    return {'total': total, 'high': high, 'warning': warning, 'info': info};
  }

  List<String> get departments {
    final set = _users.map((u) => u.department).where((d) => d.isNotEmpty).toSet();
    return set.toList();
  }

  // Formatting helpers
  String formatTimestamp(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  Widget severityBadge(String severity) {
    Color bg;
    Color text;
    String label;
    switch (severity) {
      case 'high':
        bg = Colors.red.shade100;
        text = Colors.red.shade800;
        label = 'High';
        break;
      case 'warning':
        bg = Colors.yellow.shade100;
        text = Colors.yellow.shade800;
        label = 'Warning';
        break;
      case 'info':
        bg = Colors.blue.shade50;
        text = Colors.blue.shade800;
        label = 'Info';
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade800;
        label = 'Unknown';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: text, fontSize: 12)),
    );
  }

  Icon getActivityIcon(String type) {
    switch (type) {
      case 'authentication':
        return const Icon(Icons.vpn_key, size: 16);
      case 'work_order':
        return const Icon(Icons.build_circle_outlined, size: 16);
      case 'approval':
        return const Icon(Icons.check_circle_outline, size: 16);
      case 'user_management':
        return const Icon(Icons.group_outlined, size: 16);
      case 'system':
        return const Icon(Icons.storage_outlined, size: 16);
      case 'security':
        return const Icon(Icons.shield_outlined, size: 16);
      case 'compliance':
        return const Icon(Icons.dataset_outlined, size: 16);
      default:
        return const Icon(Icons.info_outline, size: 16);
    }
  }

  Color severityColor(String severity) {
    switch (severity) {
      case 'high':
        return Colors.red.shade600;
      case 'warning':
        return Colors.orange.shade600;
      case 'info':
        return Colors.blue.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use DefaultTabController for tabs
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            const Icon(Icons.shield_outlined, color: Colors.blueAccent),
            const SizedBox(width: 8),
            const Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('System Administrator', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          Center(child: Text('Welcome, ${widget.currentUser.name}', style: const TextStyle(fontSize: 14))),
          const SizedBox(width: 12),
          TextButton.icon(
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.group_outlined), text: 'User Management'),
            Tab(icon: Icon(Icons.history), text: 'Activity Logs'),
            Tab(icon: Icon(Icons.security), text: 'Security'),
            Tab(icon: Icon(Icons.settings), text: 'System Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(context),
          _buildActivityTab(context),
          _buildSecurityTab(context),
          _buildSettingsTab(context),
        ],
      ),
    );
  }

  Widget _buildUsersTab(BuildContext context) {
    final stats = userStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StatsCard(title: 'Total Users', value: stats['total'].toString(), icon: Icons.group, color: Colors.blue),
              const SizedBox(width: 12),
              _StatsCard(title: 'Active Users', value: stats['active'].toString(), icon: Icons.check_circle, color: Colors.green),
              const SizedBox(width: 12),
              _StatsCard(title: 'Inactive Users', value: stats['inactive'].toString(), icon: Icons.warning_amber_outlined, color: Colors.orange),
              const SizedBox(width: 12),
              _StatsCard(title: 'Suspended', value: stats['suspended'].toString(), icon: Icons.block, color: Colors.red),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Header with actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('User Management', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Manage user accounts, roles, and permissions', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                      Row(
                        children: [
                          TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('Export')),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.person_add), label: const Text('Add User')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filters row
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: 'Search users...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                          ),
                          onChanged: (v) => setState(() => searchQuery = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField<String>(
                          initialValue: statusFilter,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Status')),
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                            DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                          ],
                          onChanged: (v) => setState(() => statusFilter = v ?? 'all'),
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 180,
                        child: DropdownButtonFormField<String>(
                          initialValue: departmentFilter,
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text('All Departments')),
                            ...departments.map((d) => DropdownMenuItem(value: d, child: Text(d))),
                          ],
                          onChanged: (v) => setState(() => departmentFilter = v ?? 'all'),
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                          onPressed: () => setState(() {
                                searchQuery = '';
                                statusFilter = 'all';
                                departmentFilter = 'all';
                              }),
                          icon: const Icon(Icons.refresh)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Users table (DataTable for desktop-like view, fallback to ListView for small widths)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Department')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Last Login')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredUsers.map((u) {
                        return DataRow(cells: [
                          DataCell(Row(
                            children: [
                              CircleAvatar(child: Text(_initials(u.name), style: const TextStyle(fontSize: 12))),
                              const SizedBox(width: 8),
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(u.name),
                                    Text(u.email, style: const TextStyle(fontSize: 12, color: Colors.grey))
                                  ]),
                            ],
                          )),
                          DataCell(Text(u.role)),
                          DataCell(Text(u.department)),
                          DataCell(_statusBadge(u.status)),
                          DataCell(Text(u.lastLogin == null ? 'Never' : formatTimestamp(u.lastLogin!))),
                          DataCell(Row(
                            children: [
                              IconButton(onPressed: () => widget.onNavigateToUserDetails(u.id), icon: const Icon(Icons.remove_red_eye)),
                              IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                              IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline)),
                            ],
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab(BuildContext context) {
    final stats = activityStats;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats
          Row(
            children: [
              _StatsCard(title: 'Total Events', value: stats['total'].toString(), icon: Icons.history, color: Colors.blue),
              const SizedBox(width: 12),
              _StatsCard(title: 'High Priority', value: stats['high'].toString(), icon: Icons.warning_amber, color: Colors.red),
              const SizedBox(width: 12),
              _StatsCard(title: 'Warnings', value: stats['warning'].toString(), icon: Icons.report_problem, color: Colors.orange),
              const SizedBox(width: 12),
              _StatsCard(title: 'Information', value: stats['info'].toString(), icon: Icons.info_outline, color: Colors.blueAccent),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                        Text('Recent Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('System events and user activities in real-time', style: TextStyle(color: Colors.grey)),
                      ]),
                      Row(children: [
                        TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('Export Logs')),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(onPressed: () => setState(() {}), icon: const Icon(Icons.refresh), label: const Text('Refresh')),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Filters
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: 'Search activities...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          onChanged: (v) => setState(() => activitySearchQuery = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 160,
                        child: DropdownButtonFormField<String>(
                          initialValue: activityTypeFilter,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Types')),
                            DropdownMenuItem(value: 'authentication', child: Text('Authentication')),
                            DropdownMenuItem(value: 'work_order', child: Text('Work Orders')),
                            DropdownMenuItem(value: 'approval', child: Text('Approvals')),
                            DropdownMenuItem(value: 'user_management', child: Text('User Management')),
                            DropdownMenuItem(value: 'system', child: Text('System')),
                            DropdownMenuItem(value: 'security', child: Text('Security')),
                            DropdownMenuItem(value: 'compliance', child: Text('Compliance')),
                          ],
                          onChanged: (v) => setState(() => activityTypeFilter = v ?? 'all'),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 140,
                        child: DropdownButtonFormField<String>(
                          initialValue: activitySeverityFilter,
                          items: const [
                            DropdownMenuItem(value: 'all', child: Text('All Levels')),
                            DropdownMenuItem(value: 'high', child: Text('High')),
                            DropdownMenuItem(value: 'warning', child: Text('Warning')),
                            DropdownMenuItem(value: 'info', child: Text('Info')),
                          ],
                          onChanged: (v) => setState(() => activitySeverityFilter = v ?? 'all'),
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Activity list
                  Column(
                    children: _filteredActivityLogs.map((log) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        leading: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: severityColor(log.severity).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                          child: getActivityIcon(log.type),
                        ),
                        title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(log.details),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            severityBadge(log.severity),
                            const SizedBox(height: 6),
                            Text(formatTimestamp(log.timestamp), style: const TextStyle(fontSize: 11))
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab(BuildContext context) {
    final s = _security;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // security cards grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SettingCard(
                title: 'Password Policy',
                icon: Icons.vpn_key,
                description: 'Configure password requirements and security',
                child: Column(
                  children: [
                    _labelRow('Minimum Length', '${s.passwordPolicy.minLength} characters'),
                    _switchRow('Require Uppercase', s.passwordPolicy.requireUppercase, (v) {}),
                    _switchRow('Require Lowercase', s.passwordPolicy.requireLowercase, (v) {}),
                    _switchRow('Require Numbers', s.passwordPolicy.requireNumbers, (v) {}),
                    _switchRow('Require Special Characters', s.passwordPolicy.requireSpecialChars, (v) {}),
                    _labelRow('Password Expiry', '${s.passwordPolicy.passwordExpiry} days'),
                    _labelRow('Prevent Reuse', 'Last ${s.passwordPolicy.preventReuse} passwords'),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Update Policy'))),
                  ],
                ),
              ),
              _SettingCard(
                title: 'Session Security',
                icon: Icons.lock_clock,
                description: 'Manage user session settings and timeouts',
                child: Column(
                  children: [
                    _labelRow('Session Timeout', '${s.sessionSecurity.sessionTimeout} minutes'),
                    _labelRow('Max Concurrent Sessions', '${s.sessionSecurity.maxConcurrentSessions} sessions'),
                    _switchRow('Require Re-authentication', s.sessionSecurity.requireReauth, (v) {}),
                    _switchRow('Logout on Browser Close', s.sessionSecurity.logoutOnClose, (v) {}),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Update Sessions'))),
                  ],
                ),
              ),
              _SettingCard(
                title: 'Access Control',
                icon: Icons.shield_outlined,
                description: 'Configure login security and IP restrictions',
                child: Column(
                  children: [
                    _labelRow('Max Failed Attempts', '${s.accessControl.maxFailedAttempts} attempts'),
                    _labelRow('Lockout Duration', '${s.accessControl.lockoutDuration} minutes'),
                    _switchRow('Two-Factor Authentication', s.accessControl.enableTwoFactor, (v) {}),
                    const SizedBox(height: 8),
                    const Align(alignment: Alignment.centerLeft, child: Text('Allowed IP Ranges', style: TextStyle(fontWeight: FontWeight.w600))),
                    Column(
                      children: s.accessControl.allowedIpRanges.map((range) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade50),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(range, style: const TextStyle(fontFamily: 'monospace')),
                              IconButton(onPressed: () {}, icon: const Icon(Icons.delete_outline, size: 18)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.public), label: const Text('Add IP Range')),
                  ],
                ),
              ),
              _SettingCard(
                title: 'Audit & Logging',
                icon: Icons.storage_outlined,
                description: 'Configure audit logging and retention settings',
                child: Column(
                  children: [
                    _labelRow('Log Retention', '${s.auditSettings.logRetention} days'),
                    _switchRow('Real-time Alerts', s.auditSettings.enableRealTimeAlerts, (v) {}),
                    _labelRow('Alert Threshold', '${s.auditSettings.alertThreshold} events'),
                    _switchRow('Export Enabled', s.auditSettings.exportEnabled, (v) {}),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Update Audit Settings'))),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Security status overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Security Status Overview', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('Current security health and recent alerts', style: TextStyle(color: Colors.grey)),
                            ]),
                        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.remove_red_eye), label: const Text('View All Security Events')),
                      ]),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _statusPill(Colors.green, Icons.check_circle, 'System Secure', 'All security checks passed'),
                    _statusPill(Colors.orange, Icons.report_problem, '1 Warning', 'Failed login attempts detected'),
                    _statusPill(Colors.blue, Icons.bar_chart, 'Security Score', '92/100 - Excellent'),
                  ]),
                  const SizedBox(height: 12),
                  Column(
                    children: _activityLogs.where((log) => log.type == 'security' || log.severity == 'high').take(3).map((log) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                children: [
                                  Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(color: severityColor(log.severity).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                                      child: getActivityIcon(log.type)),
                                  const SizedBox(width: 8),
                                  Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(log.action, style: const TextStyle(fontWeight: FontWeight.w600)),
                                        Text(log.details, style: const TextStyle(color: Colors.grey))
                                      ]),
                                ]),
                            Text(formatTimestamp(log.timestamp), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final s = _settings;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SettingCard(
                title: 'General Configuration',
                icon: Icons.settings,
                description: 'Basic system settings and preferences',
                child: Column(
                  children: [
                    _readonlyRow('System Name', s.general.systemName),
                    _readonlyRow('Timezone', s.general.timezone),
                    _readonlyRow('Date Format', s.general.dateFormat),
                    _readonlyRow('Time Format', s.general.timeFormat),
                    _readonlyRow('Language', s.general.language),
                    _switchRow('Maintenance Mode', s.general.maintenanceMode, (v) {}),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Update General Settings'))),
                  ],
                ),
              ),
              _SettingCard(
                title: 'Work Order Configuration',
                icon: Icons.task,
                description: 'Configure work order processing and workflows',
                child: Column(
                  children: [
                    _switchRow('Auto Assignment', s.workOrders.autoAssignment, (v) {}),
                    Wrap(spacing: 6, children: s.workOrders.priorityLevels.map((lvl) => Chip(label: Text(lvl))).toList()),
                    _readonlyRow('Default Priority', s.workOrders.defaultPriority),
                    _switchRow('Estimation Required', s.workOrders.estimationRequired, (v) {}),
                    _readonlyRow('Max Active Orders', s.workOrders.maxActiveOrders.toString()),
                    _switchRow('Approval Workflow', s.workOrders.approvalWorkflow, (v) {}),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.task), label: const Text('Update Work Order Settings'))),
                  ],
                ),
              ),
              _SettingCard(
                title: 'Notification Settings',
                icon: Icons.notifications,
                description: 'Configure alerts and communication preferences',
                child: Column(
                  children: [
                    _switchRow('Email Notifications', s.notifications.emailEnabled, (v) {}),
                    _switchRow('SMS Notifications', s.notifications.smsEnabled, (v) {}),
                    _switchRow('Push Notifications', s.notifications.pushEnabled, (v) {}),
                    _readonlyRow('Escalation Time', '${s.notifications.escalationTime} minutes'),
                    _readonlyRow('Reminder Interval', '${s.notifications.reminderInterval} minutes'),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Quiet Hours'),
                      Switch(value: s.notifications.quietHours.enabled, onChanged: (_) {}),
                    ]),
                    Text('${s.notifications.quietHours.start} - ${s.notifications.quietHours.end}', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.notifications), label: const Text('Update Notifications'))),
                  ],
                ),
              ),
              _SettingCard(
                title: 'Backup Configuration',
                icon: Icons.cloud_upload_outlined,
                description: 'Manage automated backups and data retention',
                child: Column(
                  children: [
                    _switchRow('Auto Backup', s.backup.autoBackup, (v) {}),
                    _readonlyRow('Frequency', s.backup.frequency),
                    _readonlyRow('Retention Period', '${s.backup.retentionDays} days'),
                    _readonlyRow('Storage Location', s.backup.location),
                    _readonlyRow('Last Backup', s.backup.lastBackup != null ? formatTimestamp(s.backup.lastBackup!) : 'N/A'),
                    _readonlyRow('Next Backup', s.backup.nextBackup != null ? formatTimestamp(s.backup.nextBackup!) : 'N/A'),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.save_alt), label: const Text('Backup Now'))),
                      const SizedBox(width: 8),
                      Expanded(child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Configure'))),
                    ]),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Integrations Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                    Text('System Integrations', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Manage external system connections and APIs', style: TextStyle(color: Colors.grey)),
                  ]),
                  const SizedBox(height: 12),
                  Column(
                    children: widget.settings.integrations.entries.map((e) {
                      final key = e.key;
                      final info = e.value;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                        child: Row(
                          children: [
                            Container(width: 10, height: 10, decoration: BoxDecoration(color: info.status == 'connected' ? Colors.green : Colors.red, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            Expanded(
                                child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_humanize(key)),
                                      Text(info.endpoint, style: const TextStyle(color: Colors.grey)),
                                      if (info.lastSync != null) Text('Last sync: ${formatTimestamp(info.lastSync!)}', style: const TextStyle(color: Colors.grey, fontSize: 12))
                                    ])),
                            Badge(text: info.status),
                            const SizedBox(width: 8),
                            Switch(value: info.enabled, onChanged: (_) {}),
                            const SizedBox(width: 8),
                            IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.public), label: const Text('Add Integration'))),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // System information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
                      Text('System Information', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('Current system status and performance metrics', style: TextStyle(color: Colors.grey))
                    ]),
                    const SizedBox(height: 12),
                    Wrap(spacing: 12, runSpacing: 12, children: [
                      _infoTile('System Health', Icons.check_circle, 'Operational'),
                      _infoTile('Active Users', Icons.person, '${mockUsers.where((u) => u.status == 'active').length} online'),
                      _infoTile('Database Status', Icons.storage, 'Connected'),
                      _infoTile('Storage Usage', Icons.sd_storage, '2.3 GB / 10 GB'),
                      _infoTile('Uptime', Icons.schedule, '99.9% (30 days)'),
                      _infoTile('Version', Icons.info, 'v2.1.0'),
                    ]),
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  // Small helpers & sub-widgets
  String _initials(String name) {
    final parts = name.split(' ');
    return parts.map((p) => p.isNotEmpty ? p[0] : '').join().toUpperCase();
  }

  Widget _statusBadge(String status) {
    Color bg;
    Color fg;
    switch (status) {
      case 'active':
        bg = Colors.green.shade50;
        fg = Colors.green.shade800;
        break;
      case 'inactive':
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
        break;
      case 'suspended':
        bg = Colors.red.shade50;
        fg = Colors.red.shade800;
        break;
      default:
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade800;
    }
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: TextStyle(color: fg, fontSize: 12)));
  }

  Widget _switchRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Switch(value: value, onChanged: onChanged)]),
    );
  }

  Widget _labelRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(color: Colors.grey))]),
    );
  }

  Widget _readonlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(color: Colors.grey))]),
    );
  }

  String _humanize(String key) {
    // Insert spaces before capitals, simple approach
    return key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}').trim();
  }

  Widget _statusPill(Color bg, IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: bg, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: bg)),
          Text(subtitle, style: TextStyle(color: bg.withValues(alpha: 0.8)))
        ])
      ]),
    );
  }

  Widget _infoTile(String title, IconData icon, String value) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.shade50),
      child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600)), const SizedBox(height: 4), Text(value, style: const TextStyle(color: Colors.grey))])
          ]),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatsCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color))
            ])
          ]),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Widget child;

  const _SettingCard({required this.title, required this.description, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(icon), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
            const SizedBox(height: 4),
            Text(description, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            child,
          ]),
        ),
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final String text;
  final Color? color;

  const Badge({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Colors.grey.shade200;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }
}