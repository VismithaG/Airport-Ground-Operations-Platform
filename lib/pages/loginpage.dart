import 'package:flutter/material.dart';
import 'loginform.dart';

// Minimal local company data so login page doesn't depend on missing constants file.
const Map<String, dynamic> companyInfo = {
  'name': 'Airport Services',
  'tagline': 'Ground operations made simple',
  'features': ['Work orders', 'Approvals', 'Reporting'],
  'contact': {'support': 'it@airport.local'},
};

class ImageWithFallback extends StatelessWidget {
  final String src;
  final double? height;
  final BoxFit fit;

  const ImageWithFallback({
    super.key,
    required this.src,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      src,
      height: height,
      width: double.infinity,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
      ),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: height,
          color: Colors.grey.shade200,
          alignment: Alignment.center,
          child: const CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final void Function({
    required String email,
    required String password,
    required bool rememberMe,
  }) onLogin;
  final VoidCallback onDemoApproval;
  final VoidCallback onDemoAdminLogin;

  const LoginPage({
    super.key,
    required this.onLogin,
    required this.onDemoApproval,
    required this.onDemoAdminLogin,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> company = companyInfo;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9FAFB), Color(0xFFFFE5E5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Opacity(
              opacity: 0.05,
              child: Container(
                decoration: const BoxDecoration(
                  // optional: keep a pattern asset if you add it to assets later
                ),
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isLargeScreen = constraints.maxWidth > 900;

                      return GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: isLargeScreen ? 2 : 1,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        children: [
                          if (isLargeScreen)
                            _buildLeftPanel(context, company)
                          else
                            _buildMobileHeader(context, company),
                          _buildRightPanel(context, company),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftPanel(BuildContext context, Map<String, dynamic> company) {
    final features = (company['features'] as List<dynamic>?) ?? <dynamic>[];
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            company['name'] ?? '',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7F1D1D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            company['tagline'] ?? '',
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              features.length,
              (index) => Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8, bottom: 8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(features[index].toString()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                ImageWithFallback(
                  src:
                      "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?auto=format&fit=crop&w=1000&q=80",
                  height: 200,
                ),
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xAA7F1D1D),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(
                    "Professional airport ground services",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Demo Options: Test different system features",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: onDemoApproval,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text("Demo Approval Workflow"),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: onDemoAdminLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text("Demo Admin Panel"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, Map<String, dynamic> company) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          company['name'] ?? '',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7F1D1D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          company['tagline'] ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context, Map<String, dynamic> company) {
    return SingleChildScrollView(
      child: Column(
        children: [
          LoginForm(onLogin: onLogin),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              border: Border.all(color: const Color(0xFFBFDBFE)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Demo Instructions",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "• Use any email/password to login as regular user\n"
                  "• Use admin@airport.com to login as admin\n"
                  "• Include 'supervisor' in email for supervisor role\n"
                  "• Click demo buttons to test specific workflows",
                  style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "© 2025 ${company['name'] ?? ''}. All rights reserved.",
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          Text(
            "For technical support, contact IT services at ${company['contact']?['support'] ?? ''}",
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
