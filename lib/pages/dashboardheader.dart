import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onLogout;
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

    final initials = user["name"]!
        .split(' ')
        .where((n) => n.isNotEmpty)
        .map((n) => n[0])
        .take(2)
        .join()
        .toUpperCase();

    return Material(
      color: Colors.white,
      elevation: 2,
      child: Container(
        height: preferredSize.height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.red.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // -------- Left: Logo and Title --------
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.shade600,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.flight, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Service Department",
                      style: TextStyle(
                        color: Color(0xFF7F1D1D),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Ground Operations Portal",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),

            // -------- Right: User Menu --------
            Row(
              children: [
                // User Info (hidden on mobile - can adapt responsive)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user["name"]!,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    Text(
                      user["role"]!,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                // Avatar and dropdown menu
                PopupMenuButton<String>(
                  tooltip: "User menu",
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  offset: const Offset(0, 45),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      enabled: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user["name"]!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 2),
                          Text(user["email"]!,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: "profile",
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.person, size: 18),
                        title: Text("Profile", style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const PopupMenuItem(
                      value: "settings",
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.settings, size: 18),
                        title: Text("Settings", style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    PopupMenuItem(
                      value: "logout",
                      onTap: onLogout,
                      child: const ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.logout, size: 18, color: Colors.red),
                        title: Text("Log out",
                            style:
                                TextStyle(fontSize: 13, color: Colors.redAccent)),
                      ),
                    ),
                  ],
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      initials,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
