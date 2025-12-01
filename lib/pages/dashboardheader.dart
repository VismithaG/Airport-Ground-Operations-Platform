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

    // Calculate initials
    final initials = (user["name"] ?? "User")
        .split(' ')
        .where((n) => n.isNotEmpty)
        .take(2)
        .map((n) => n[0])
        .join()
        .toUpperCase();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // -------- Left: Logo and Title --------
              Row(
                children: [
                  // Logo Placeholder
                  Image.network(
                     // Using a placeholder that looks like the airline logo or a fallback icon
                     'https://upload.wikimedia.org/wikipedia/en/thumb/9/9b/SriLankan_Airlines_Logo.svg/1200px-SriLankan_Airlines_Logo.svg.png',
                     width: 40,
                     errorBuilder: (context, error, stackTrace) => Container(
                       width: 40, height: 40,
                       decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(8)),
                       child: const Icon(Icons.flight_takeoff, color: Colors.white),
                     ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Service Department",
                        style: TextStyle(
                          color: Color(0xFFB71C1C), // Deep Red
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

              // -------- Right: User Avatar --------
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red.shade100,
                child: Text(
                  initials,
                  style: TextStyle(color: Colors.red.shade900, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}