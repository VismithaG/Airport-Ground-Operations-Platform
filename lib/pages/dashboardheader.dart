import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final void Function(BuildContext) onLogout;
  final Map<String, String>? currentUser;

  const DashboardHeader({
    super.key,
    required this.onLogout,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final user = currentUser ??
        {
          "name": "John Smith",
          "email": "john.smith@airport.com",
          "role": "Service Technician",
        };

    // Calculate initials
    final initials = (user["name"] ?? "User")
        .split(' ')
        .where((n) => n.isNotEmpty)
        .take(2)
        .map((n) => n[0])
        .join()
        .toUpperCase();

    return LayoutBuilder(builder: (parentContext, constraints) {
      final isCompact = constraints.maxWidth < 480;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Logo and Title (compact on small screens)
                Row(
                  children: [
                    // Logo Placeholder
                    Container(
                      width: isCompact ? 36 : 40,
                      height: isCompact ? 36 : 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.red.shade700,
                      ),
                      child: const Icon(Icons.flight_takeoff, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isCompact ? 'Service Dept' : 'Service Department',
                          style: TextStyle(
                            color: const Color(0xFF7F1D1D),
                            fontSize: isCompact ? 14 : 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (!isCompact)
                          const Text(
                            'Ground Operations Portal',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                      ],
                    ),
                  ],
                ),

                // Right: User Avatar with profile menu
                Row(
                  children: [
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'logout') {
                          debugPrint('DashboardHeader: logout selected');
                          onLogout(parentContext);
                        } else if (value == 'profile') {
                          showDialog(
                            context: parentContext,
                            builder: (ctx) => AlertDialog(
                              title: Text(user['name'] ?? 'User'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(user['email'] ?? ''),
                                  const SizedBox(height: 8),
                                  Text(user['role'] ?? ''),
                                ],
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                                TextButton(
                                  onPressed: () {
                                    debugPrint('DashboardHeader: logout from profile dialog');
                                    Navigator.of(ctx).pop();
                                    onLogout(parentContext);
                                  },
                                  child: const Text('Logout'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'profile',
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.red.shade100,
                              child: Text(initials, style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.bold)),
                            ),
                            title: Text(user['name'] ?? 'User'),
                            subtitle: Text(user['email'] ?? ''),
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: ListTile(leading: Icon(Icons.logout, color: Colors.red), title: const Text('Logout')),
                        ),
                      ],
                      child: Row(
                        children: [
                          if (!isCompact)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(user['name'] ?? 'User', style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  Text(user['role'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          CircleAvatar(
                            radius: isCompact ? 16 : 18,
                            backgroundColor: Colors.red.shade100,
                            child: Text(
                              initials,
                              style: TextStyle(color: Colors.red.shade900, fontSize: isCompact ? 12 : 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.keyboard_arrow_down, color: Colors.grey.shade600),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}