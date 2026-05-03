import 'package:flutter/material.dart';
import 'pages/loginpage.dart';
import 'pages/dashboard.dart';
import 'pages/adminpanel.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:cloud_firestore/cloud_firestore.dart';
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
    final String cleanEmail = email.trim().toLowerCase();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = e.message ?? 'Unknown error';
        if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
          msg = 'Invalid credentials for this account.';
        } else if (e.code == 'operation-not-allowed') {
          msg = 'Email/Password Authentication is not enabled in your Firebase Console!';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $msg')));
      }
      return;
    } catch (e) {
      debugPrint('Login error: $e');
      return;
    }

    String displayName = "System User";
    String roleName = "Service Technician";
    String designationName = "";

    try {
      final userRecord = FirebaseAuth.instance.currentUser;
      if (userRecord != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userRecord.uid).get();
        if (userDoc.exists) {
          final data = userDoc.data()!;
          displayName = data['fullName'] ?? displayName;
          roleName = data['userType'] ?? roleName;
          designationName = data['designation'] ?? designationName;
          
          // Map "Admin" from firestore explicitly to Administrator due to routing logic below
          if (roleName.toLowerCase() == 'admin' || roleName.toLowerCase() == 'administrator') {
             roleName = 'Administrator';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching user profile from Firestore: $e');
    }

    final user = UserInfo(
      name: displayName,
      role: roleName,
      email: cleanEmail,
      designation: designationName,
    );

    if (!mounted) return;

    if (user.role == 'Administrator') {
      debugPrint('Main: routing to AdminPanelPage for ${user.email}');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminPanelPage(
            currentUser: {"name": user.name, "role": user.role, "email": user.email, "designation": user.designation},
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
    final user = UserInfo(name: "Approval Demo", role: "Supervisor", email: "supervisor@demo", designation: "Demo Supervisor");
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
    final user = UserInfo(name: "Admin Demo", role: "Administrator", email: "admin@demo", designation: "Demo Admin");
    // Demo admin should open Admin Panel
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPanelPage(
          currentUser: {"name": user.name, "role": user.role, "email": user.email, "designation": user.designation},
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