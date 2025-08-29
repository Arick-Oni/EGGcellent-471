import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Responsive_helper.dart';
import 'farmer_log_in.dart';
 // Import the login page

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Get UID of the newly created user
      String uid = userCredential.user!.uid;

      // 3. Save user info in Firestore under 'farmers' collection
      await FirebaseFirestore.instance.collection('farmers').doc(uid).set({
        'uid': uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        // Add more fields if needed, e.g., phone, address, etc.
      });

      // 4. Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      // 5. Navigate to login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      // Catch Firestore or any other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving user data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ResponsiveHelper.widthPercentage(context, 100);
    double formWidth = ResponsiveHelper.isDesktop(context)
        ? screenWidth * 0.4
        : ResponsiveHelper.isTablet(context)
        ? screenWidth * 0.6
        : screenWidth * 0.9;

    double iconSize = ResponsiveHelper.isDesktop(context) ? 80 : 60;
    double titleFont = ResponsiveHelper.isDesktop(context) ? 36 : 28;
    double fieldFont = ResponsiveHelper.isDesktop(context) ? 18 : 16;
    double buttonFont = ResponsiveHelper.isDesktop(context) ? 20 : 18;
    double spacing = ResponsiveHelper.heightPercentage(context, 2);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: formWidth,
            padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 32 : 24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Icon(
                    Icons.person_add_alt_1,
                    size: iconSize,
                    color: Colors.cyanAccent[400],
                  ),
                  SizedBox(height: spacing),
                  Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent[400],
                    ),
                  ),
                  SizedBox(height: spacing * 2),

                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(fontSize: fieldFont, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.person, color: Colors.cyanAccent[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
                  ),
                  SizedBox(height: spacing),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(fontSize: fieldFont, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.email, color: Colors.cyanAccent[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your email' : null,
                  ),
                  SizedBox(height: spacing),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    style: TextStyle(fontSize: fieldFont, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock, color: Colors.cyanAccent[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (value) =>
                    value!.isEmpty ? 'Please enter your password' : null,
                  ),
                  SizedBox(height: spacing * 2),

                  // Create Account Button
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.cyanAccent[400])
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: ResponsiveHelper.heightPercentage(
                                context, 2)),
                        backgroundColor: Colors.cyanAccent[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: buttonFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Already have account? Login
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(
                        fontSize: fieldFont,
                        color: Colors.yellow[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

