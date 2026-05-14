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
  })
  onLogin;

  const LoginPage({
    super.key,
    required this.onLogin,
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

                      // Desktop/tablet: two-column layout. Mobile: stacked column.
                      if (isLargeScreen) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left branding column
                            Expanded(
                              flex: 1,
                              child: _buildLeftPanel(context, company),
                            ),
                            const SizedBox(width: 40),
                            // Right login column
                            Expanded(
                              flex: 1,
                              child: _buildRightPanel(context, company),
                            ),
                          ],
                        );
                      } else {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMobileHeader(context, company),
                              const SizedBox(height: 24),
                              _buildRightPanel(context, company),
                            ],
                          ),
                        );
                      }
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
                      colors: [Color(0xAA7F1D1D), Colors.transparent],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(
                    "Professional airport ground services",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(
    BuildContext context,
    Map<String, dynamic> company,
  ) {
    return Column(
      children: [
        const SizedBox(height: 32),
        // Airplane icon in rounded red container
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.flight,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          company['name'] ?? '',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          company['tagline'] ?? '',
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BuildContext context, Map<String, dynamic> company) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoginForm(onLogin: onLogin),
      ],
    );
  }
}
