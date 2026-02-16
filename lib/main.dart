import 'package:flutter/material.dart';
import 'pages/loginpage.dart';
import 'pages/dashboard.dart';

void main() {
  runApp(const GroundOperationsApp());
}

class GroundOperationsApp extends StatelessWidget {
  const GroundOperationsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Airport Ground Operations',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.red),
          titleTextStyle: TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  void _handleLogin({
    required String email,
    required String password,
    required bool rememberMe,
  }) {
    final user = UserInfo(
      name: email.contains("admin") ? "Admin User" : "John Smith",
      role: email.contains("supervisor")
          ? "Supervisor"
          : email.contains("admin")
              ? "Administrator"
              : "Service Technician",
      email: email,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          onLogout: (ctx) {
            Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          currentUser: user,
        ),
      ),
    );
  }

  void _demoApproval() {
    final user = UserInfo(name: "Approval Demo", role: "Supervisor", email: "supervisor@demo");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          onLogout: (ctx) {
            Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          currentUser: user,
        ),
      ),
    );
  }

  void _demoAdminLogin() {
    final user = UserInfo(name: "Admin Demo", role: "Administrator", email: "admin@demo");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(
            onLogout: (ctx) {
              Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          currentUser: user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // LoginPage widget expects callbacks (see lib/pages/loginpage.dart)
    return LoginPage(
      onLogin: ({required String email, required String password, required bool rememberMe}) {
        _handleLogin(email: email, password: password, rememberMe: rememberMe);
      },
      onDemoApproval: _demoApproval,
      onDemoAdminLogin: _demoAdminLogin,
    );
  }
}