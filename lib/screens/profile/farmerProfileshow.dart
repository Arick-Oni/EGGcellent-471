import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Responsive_helper.dart';

class FarmerProfilePage extends StatelessWidget {
  const FarmerProfilePage({super.key});

  /// Fetch farmer profile data from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> _getFarmerProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw Exception("User not logged in");

    final doc =
    await FirebaseFirestore.instance.collection('farmers').doc(uid).get();

    if (!doc.exists) throw Exception("Farmer profile not found");

    return doc;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          "Farmer Profile",
          style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent[400]),
        ),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _getFarmerProfile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text(
                "No profile data found",
                style: TextStyle(
                    fontSize: isDesktop ? 18 : 14, color: Colors.white70),
              ),
            );
          }

          final data = snapshot.data!.data()!;
          final avatarRadius = isDesktop ? 80.0 : 60.0;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? screenWidth * 0.3 : screenWidth * 0.05,
                vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40 : 20,
                      vertical: isDesktop ? 30 : 20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade800,
                        Colors.grey.shade900,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(57, 44, 44, 44),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: avatarRadius,
                        backgroundImage:
                        const AssetImage("assets/images/profile.png"),
                      ),
                      SizedBox(height: avatarRadius * 0.3),
                      Text(
                        data["name"] ?? "No Name",
                        style: TextStyle(
                            fontSize: isDesktop ? 26 : 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent[400]),
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 10,),
                // Only show name, email, joined on
                _buildDetailTile(context, "Name", data["name"]),
                _buildDetailTile(context, "Email", data["email"]),
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
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Card(
      margin: EdgeInsets.symmetric(
          vertical: isDesktop ? 10 : 6, horizontal: isDesktop ? 10 : 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
      color: Colors.grey.shade900,
      shadowColor: Colors.cyanAccent.withOpacity(0.6),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 20 : 15, vertical: isDesktop ? 15 : 10),
        leading: Icon(Icons.check_circle,
            size: isDesktop ? 18 : 14, color: Colors.cyanAccent[400]),
        title: Text(title,
            style: TextStyle(
              fontSize: isDesktop ? 16 : 14,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            )),
        subtitle: Text(value ?? "Not provided",
            style: TextStyle(
              fontSize: isDesktop ? 14 : 12,
              color: Colors.white60,
            )),
      ),
    );
  }
}
