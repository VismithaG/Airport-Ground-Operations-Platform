import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../firebase_options.dart';
import '../services/activity_logger.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _nicCtrl = TextEditingController();
  final _homeAddressCtrl = TextEditingController();
  final _workEmailCtrl = TextEditingController();
  final _personalEmailCtrl = TextEditingController();
  final _staffIdCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _departmentCtrl = TextEditingController();
  final _designationCtrl = TextEditingController();
  final _enrollmentDateCtrl = TextEditingController();

  String _selectedUserType = 'Average User';
  final List<String> _userTypes = ['Average User', 'Supervisor', 'Admin'];

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _dobCtrl.dispose();
    _nicCtrl.dispose();
    _homeAddressCtrl.dispose();
    _workEmailCtrl.dispose();
    _personalEmailCtrl.dispose();
    _staffIdCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _departmentCtrl.dispose();
    _designationCtrl.dispose();
    _enrollmentDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missing or invalid details. Please check the form.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    FirebaseApp? adminApp;

    try {
      // 1. Initialize a secondary Firebase App to prevent logging out the current admin
      adminApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: DefaultFirebaseOptions.currentPlatform,
      );

      final adminAuth = FirebaseAuth.instanceFor(app: adminApp);

      // 2. Create the user in Firebase Auth using the secondary app
      final UserCredential userCredential = await adminAuth.createUserWithEmailAndPassword(
        email: _workEmailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      final user = userCredential.user;

      if (user != null) {
        // 3. Call Cloud Function to assign claims
        try {
          final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('grantAuthorizedClaim');
          await callable.call({'uid': user.uid});
          debugPrint('Successfully set authorized claim for \${user.uid}');
        } catch (e) {
          debugPrint('Failed to set authorized claim: \$e');
        }

        // 4. Save additional user data in Firestore
        // We use the default Firestore instance since the Admin is still logged in there
        // and supposedly has write access to create users.
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'fullName': _fullNameCtrl.text.trim(),
          'dob': _dobCtrl.text.trim(),
          'nic': _nicCtrl.text.trim(),
          'homeAddress': _homeAddressCtrl.text.trim(),
          'workEmail': _workEmailCtrl.text.trim(),
          'personalEmail': _personalEmailCtrl.text.trim(),
          'staffId': _staffIdCtrl.text.trim(),
          'username': _usernameCtrl.text.trim(),
          'department': _departmentCtrl.text.trim(),
          'designation': _designationCtrl.text.trim(),
          'enrollmentDate': _enrollmentDateCtrl.text.trim(),
          'userType': _selectedUserType,
          'createdAt': FieldValue.serverTimestamp(),
          // Default fields for admin panel UI
          'status': 'Active',
          'lastLogin': '', 
        });

        // Log the activity
        ActivityLogger.logEvent(
          action: 'Account Created',
          user: 'Administrator', // Since only admin can reach here
          details: 'Created new ${_selectedUserType} account for ${_workEmailCtrl.text.trim()}',
          severity: 'Info',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(); // Return to Admin Panel
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = 'An error occurred during registration.';
        if (e.code == 'email-already-in-use') {
          msg = 'This account already exists. Please use a different email.';
        } else if (e.code == 'invalid-email') {
          msg = 'Invalid email address provided.';
        } else if (e.code == 'weak-password') {
          msg = 'The password provided is too weak (minimum 6 characters).';
        } else if (e.code == 'operation-not-allowed') {
          msg = 'Account creation is disabled in Firebase.';
        } else {
          msg = e.message ?? msg;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database Error: ${e.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An unexpected error occurred processing the request.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      // 4. Clean up the secondary app instance reliably even if errors crash the flow!
      try {
        if (adminApp != null) {
          await adminApp.delete();
        }
      } catch (cleanupException) {
        debugPrint('Secondary Resource Deletion Exception: $cleanupException');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Account'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('User Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildTextField('Full Name', _fullNameCtrl, required: true),
                            _buildDateField('Date of Birth', _dobCtrl, required: true),
                            _buildTextField('NIC', _nicCtrl, required: true),
                            _buildTextField('Home Address', _homeAddressCtrl, required: false),
                            
                            const SizedBox(height: 24),
                            const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildTextField('Work Email Address', _workEmailCtrl, required: true, isEmail: true),
                            _buildTextField('Personal Email Address', _personalEmailCtrl, required: false, isEmail: true),
                            
                            const SizedBox(height: 24),
                            const Text('Account Credentials', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildTextField('Staff ID', _staffIdCtrl, required: true),
                            _buildTextField('Username', _usernameCtrl, required: true),
                            _buildTextField('Password', _passwordCtrl, required: true, obscureText: true),
                            
                            const SizedBox(height: 24),
                            const Text('Employment Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 16),
                            _buildTextField('Department', _departmentCtrl, required: true),
                            _buildTextField('Designation', _designationCtrl, required: true),
                            _buildDateField('Date of Enrollment', _enrollmentDateCtrl, required: false),
                            
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: 'User Type *',
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _selectedUserType,
                              items: _userTypes.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUserType = value!;
                                });
                              },
                            ),
                            
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: _createAccount,
                                child: const Text('Add User', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool required = false, bool obscureText = false, bool isEmail = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          if (isEmail && value != null && value.trim().isNotEmpty) {
            // Very basic email validation
            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
              return 'Enter a valid email address';
            }
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, {required bool required}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _selectDate(context, controller),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return '$label is required';
          }
          return null;
        },
      ),
    );
  }
}
