import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/newAuth/buyer_check_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Responsive_helper.dart';
import 'package:poultry_app/widgets/navigation.dart';
import 'package:poultry_app/widgets/dialogbox.dart';

class BuyerCreateProfile extends StatefulWidget {
  const BuyerCreateProfile({super.key});

  @override
  State<BuyerCreateProfile> createState() => _BuyerCreateProfileState();
}

class _BuyerCreateProfileState extends State<BuyerCreateProfile> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _villageController = TextEditingController();

  bool _isLoading = false;

  Future<void> _saveBuyerProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCred.user;

      await FirebaseFirestore.instance.collection("buyers").doc(user?.uid).set({
        "name": _nameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "country": _countryController.text.trim(),
        "state": _stateController.text.trim(),
        "city": _cityController.text.trim(),
        "village": _villageController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
        "uid": user?.uid,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool("buyerProfileCreated", true);

      showDialog(
        context: context,
        builder: (context) => ShowDialogBox(
          message: "Profile Created!",
          subMessage: "Your buyer profile has been created successfully.",
        ),
      );

      Timer(
        const Duration(seconds: 2),
            () {
          Navigator.pop(context);
          NextScreenReplace(context, const BuyerLogin());
        },
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Authentication error")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool requiredField = true,
    bool obscureText = false,
    TextInputType inputType = TextInputType.text,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        title: Text(
          "Create Buyer Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).colorScheme.onBackground,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: ResponsiveHelper.paddingSymmetric(horizontal: 15, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveHelper.isDesktop(context) ? 500 : double.infinity,
            ),
            child: Card(
              color: Colors.grey.shade900,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 8,
              shadowColor: Colors.cyanAccent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        "Buyer Registration",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.isDesktop(context) ? 26 : 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(controller: _nameController, label: "Name"),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _emailController,
                          label: "Email",
                          inputType: TextInputType.emailAddress),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _passwordController,
                          label: "Password",
                          obscureText: true),
                      const SizedBox(height: 15),
                      _buildTextField(
                          controller: _phoneController,
                          label: "Phone",
                          inputType: TextInputType.phone),
                      const SizedBox(height: 15),
                      _buildTextField(controller: _countryController, label: "Country"),
                      const SizedBox(height: 15),
                      _buildTextField(controller: _stateController, label: "State"),
                      const SizedBox(height: 15),
                      _buildTextField(controller: _cityController, label: "City"),
                      const SizedBox(height: 15),
                      _buildTextField(controller: _villageController, label: "Village"),
                      const SizedBox(height: 25),
                      _isLoading
                          ? const CircularProgressIndicator()
                          : _buildGradientButton(text: "Register", onTap: _saveBuyerProfile),
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
