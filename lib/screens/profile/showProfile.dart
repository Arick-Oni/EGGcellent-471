import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'editprofile.dart'; // your EditProfilePage
import '../../Responsive_helper.dart';

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({super.key});

  Future<DocumentSnapshot<Map<String, dynamic>>> _getUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }
    return FirebaseFirestore.instance.collection("buyers").doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarRadius = ResponsiveHelper.isDesktop(context) ? 70.0 : 50.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text("Profile",
            style: TextStyle(
                fontSize: ResponsiveHelper.isDesktop(context) ? 22 : 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onBackground)),
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: theme.colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No profile data found",
                style: TextStyle(
                  fontSize: ResponsiveHelper.isDesktop(context) ? 18 : 14,
                  color: theme.colorScheme.onBackground,
                ),
              ),
            );
          }

          final data = snapshot.data!.data()!;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.isDesktop(context) ? 40 : 20,
                      vertical: ResponsiveHelper.isDesktop(context) ? 30 : 20),
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade700,
                        Colors.grey.shade900
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage: const AssetImage("assets/images/profile.png"),
                      ),
                      SizedBox(height: avatarRadius * 0.3),
                      Text(
                        data["name"] ?? "No Name",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.isDesktop(context) ? 24 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        data["email"] ?? "No Email",
                        style: TextStyle(
                          fontSize: ResponsiveHelper.isDesktop(context) ? 16 : 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Details
                _buildDetailTile(context, "Phone", data["phone"]),
                _buildDetailTile(context, "Country", data["country"]),
                _buildDetailTile(context, "State", data["state"]),
                _buildDetailTile(
                  context,
                  "Joined On",
                  data["createdAt"] != null
                      ? (data["createdAt"] as Timestamp).toDate().toString()
                      : "Not Available",
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailTile(BuildContext context, String title, String? value) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Card(
      margin: EdgeInsets.symmetric(
          vertical: isDesktop ? 10 : 6, horizontal: screenWidth * 0.01),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 7,
      color: Colors.grey.shade900,
      shadowColor: Colors.cyanAccent,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 15, vertical: isDesktop ? 15 : 10),
        leading: Icon(Icons.circle,
            size: isDesktop ? 16 : 12, color: theme.colorScheme.primary),
        title: Text(title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            )),
        subtitle: Text(value ?? "Not provided",
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            )),
      ),
    );
  }
}
