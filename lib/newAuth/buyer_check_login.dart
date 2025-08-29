import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poultry_app/screens/bottomnav.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Responsive_helper.dart';
import 'buyer_create_prof.dart';

class BuyerLogin extends StatefulWidget {
  const BuyerLogin({super.key});

  @override
  State<BuyerLogin> createState() => _BuyerLoginState();
}

class _BuyerLoginState extends State<BuyerLogin> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _loginBuyer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("isbuyerLogin", true);

      NextScreenReplace(context, const BottomNavigation());
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login failed")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
    required bool requiredField,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: inputType,
      style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: label == "Password"
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Theme.of(context).colorScheme.onBackground,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
      ),
      validator: (value) {
        if (requiredField && (value == null || value.isEmpty)) {
          return "$label is required";
        }
        return null;
      },
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 55,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlueAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.paddingSymmetric(horizontal: 15, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context) ? 450 : double.infinity,
            ),
            child: Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 8,
              shadowColor: Colors.cyanAccent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Buyer Login",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.isDesktop(context) ? 28 : 22,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 25),
                      _buildTextField(
                        controller: _emailController,
                        label: "Email",
                        inputType: TextInputType.emailAddress,
                        requiredField: true,
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: _obscurePassword,
                        requiredField: true,
                      ),
                      const SizedBox(height: 25),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : _buildGradientButton(text: "Login", onTap: _loginBuyer),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              NextScreen(context, const BuyerCreateProfile());
                            },
                            child: const Text(
                              "Create Profile",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
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
        ),
      ),
    );
  }
}
