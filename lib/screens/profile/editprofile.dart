import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/dialogbox.dart';
import '../../Responsive_helper.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc =
      await FirebaseFirestore.instance.collection("buyers").doc(uid).get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data["name"] ?? "";
        _emailController.text = data["email"] ?? "";
        _phoneController.text = data["phone"] ?? "";
        _countryController.text = data["country"] ?? "";
        _stateController.text = data["state"] ?? "";
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await FirebaseFirestore.instance.collection("buyers").doc(uid).update({
        "name": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text,
        "country": _countryController.text,
        "state": _stateController.text,
      });
    }

    showDialog(
      context: context,
      builder: (context) => ShowDialogBox(
        message: "Profile Updated!",
        subMessage: "Your profile has been edited successfully.",
      ),
    ).then((_) {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = width(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text("Edit Profile",
            style: TextStyle(
              fontSize: isDesktop ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            )),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? screenWidth * 0.2 : 20, vertical: 20),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: EdgeInsets.all(isDesktop ? 30 : 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.cyanAccent,
                      blurRadius: 10,
                      offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: isDesktop ? 60 : 50,
                    backgroundImage:
                    const AssetImage("assets/images/profile.png"),
                  ),
                  SizedBox(height: isDesktop ? 20 : 15),
                  Text(
                    _nameController.text.isEmpty
                        ? "Your Name"
                        : _nameController.text,
                    style: TextStyle(
                        fontSize: isDesktop ? 22 : 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface),
                  ),
                  SizedBox(height: 5),
                  Text(
                    _emailController.text.isEmpty
                        ? "Email Address"
                        : _emailController.text,
                    style: TextStyle(
                        fontSize: isDesktop ? 16 : 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
            SizedBox(height: isDesktop ? 30 : 20),

            // Input Fields Card
            Container(
              padding: EdgeInsets.all(isDesktop ? 30 : 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.cyanAccent,
                      blurRadius: 8,
                      offset: const Offset(0, 3)),
                ],
              ),
              child: Column(
                children: [
                  buildTextField(_nameController, "Name", theme, isDesktop),
                  SizedBox(height: 15),
                  buildTextField(_emailController, "Email", theme, isDesktop,
                      inputType: TextInputType.emailAddress),
                  SizedBox(height: 15),
                  buildTextField(_phoneController, "Phone", theme, isDesktop,
                      inputType: TextInputType.phone),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                          child: buildTextField(
                              _countryController, "Country", theme, isDesktop)),
                      SizedBox(width: 15),
                      Expanded(
                          child: buildTextField(
                              _stateController, "State", theme, isDesktop)),
                    ],
                  ),
                  SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primaryContainer,
                        ],
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent, // important for gradient
                        shadowColor: Colors.transparent, // remove default shadow
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _saveProfile,
                      child: Text(
                        "Save",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  )

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, String hint,
      ThemeData theme, bool isDesktop,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      style: TextStyle(
        color: theme.colorScheme.onSurface,
        fontSize: isDesktop ? 16 : 14,
      ),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.background,
        contentPadding: EdgeInsets.symmetric(
            vertical: isDesktop ? 18 : 14, horizontal: 15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}
