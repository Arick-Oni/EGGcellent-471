import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Responsive_helper.dart';
import '../screens/Inventory tracker/inventoryService.dart';
import '../screens/bottomnav.dart';
import 'farmer_create_ac.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final _inventoryService = FarmerInventoryService();

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isbuyerLogin", false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login successful!')),
      );

      final uid = FirebaseAuth.instance.currentUser!.uid;
      await _inventoryService.initializeFarmerInventory(uid);

      NextScreenReplace(context, const BottomNavigation());
    } on FirebaseAuthException catch (e) {
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
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

    double iconSize = ResponsiveHelper.isDesktop(context)
        ? 80
        : 60; // Keep icon proportionate
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
            padding:
                EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 32 : 24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.yellow.withOpacity(0.3),
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
                    Icons.lock_outline,
                    size: iconSize,
                    color: Colors.yellow[700],
                  ),
                  SizedBox(height: spacing),
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[700],
                    ),
                  ),
                  SizedBox(height: spacing * 2),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    style: TextStyle(fontSize: fieldFont, color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.email, color: Colors.yellow[700]),
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
                      prefixIcon: Icon(Icons.lock, color: Colors.yellow[700]),
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

                  // Login Button
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.yellow[700])
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loginUser,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: ResponsiveHelper.heightPercentage(
                                      context, 2)),
                              backgroundColor: Colors.yellow[700],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(
                                fontSize: buttonFont,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                  SizedBox(height: spacing),

                  // Create Account Button with different color
                  Row(
                    children: [
                      Text(
                        "Don't have an account?",
                        style: TextStyle(
                          fontSize: fieldFont,
                          color: Colors.yellow[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          "Create one",
                          style: TextStyle(
                            fontSize: fieldFont,
                            color: Colors.cyanAccent[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
