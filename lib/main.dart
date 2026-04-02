import 'package:flutter/material.dart';
import 'pages/loginpage.dart';
import 'pages/dashboard.dart';
import 'pages/adminpanel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Prepares Flutter for async start
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Connects app to Firebase
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
  Future<void> _handleLogin({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        // Automatic Demo Registration: If login fails because user doesn't exist, create it!
        // (Note: 'invalid-credential' is the newest generic error for wrong pw/missing user)
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
        } on FirebaseAuthException catch (signUpError) {
          if (mounted) {
            String msg = signUpError.message ?? 'Unknown error';
            if (signUpError.code == 'weak-password') {
              msg = 'Firebase requires passwords to be at least 6 characters.';
            } else if (signUpError.code == 'email-already-in-use') {
              msg = 'Incorrect password for this account.';
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $msg')));
          }
          return;
        }
      } else {
        if (mounted) {
          String errStr = e.message ?? 'Unknown error';
          if (e.code == 'operation-not-allowed') {
            errStr = 'Email/Password Authentication is not enabled in your Firebase Console!';
          }
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $errStr')));
        }
        return;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return;
    }

    final user = UserInfo(
      name: email.contains("admin") ? "Admin User" : "John Smith",
      role: email.contains("supervisor")
          ? "Supervisor"
          : email.contains("admin")
              ? "Administrator"
              : "Service Technician",
      email: email,
    );

    if (!mounted) return;

    if (user.role == 'Administrator') {
      debugPrint('Main: routing to AdminPanelPage for ${user.email}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminPanelPage(
            currentUser: {"name": user.name, "role": user.role, "email": user.email},
            onLogout: (ctx) {
              debugPrint('Main: admin onLogout called - navigating to LoginScreen');
              Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            onLogout: (ctx) {
              debugPrint('Main: onLogout called - navigating to LoginScreen');
              Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            currentUser: user,
          ),
        ),
      );
    }
  }

  void _demoApproval() {
    final user = UserInfo(name: "Approval Demo", role: "Supervisor", email: "supervisor@demo");
    // Demo approval remains dashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(
          onLogout: (ctx) {
            debugPrint('Main: onLogout called - navigating to LoginScreen');
            Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
          currentUser: user,
        ),
      ),
    );
  }

  void _demoAdminLogin() {
    final user = UserInfo(name: "Admin Demo", role: "Administrator", email: "admin@demo");
    // Demo admin should open Admin Panel
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPanelPage(
          currentUser: {"name": user.name, "role": user.role, "email": user.email},
          onLogout: (ctx) {
            debugPrint('Main: admin onLogout called - navigating to LoginScreen');
            Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
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