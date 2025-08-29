import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../Responsive_helper.dart';
import '../../utils/constants.dart';
import '../../widgets/generalappbar.dart';
import 'edit_add_screen.dart';

class MyAds extends StatefulWidget {
  const MyAds({super.key});

  @override
  State<MyAds> createState() => _MyAdsState();
}

class _MyAdsState extends State<MyAds> {
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late final Stream<QuerySnapshot> adsStream;

  @override
  void initState() {
    super.initState();
    adsStream = FirebaseFirestore.instance
        .collection('collectionofall')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final horizontalPadding = isDesktop ? 100.0 : 15.0;
    final imageSize = isDesktop ? 120.0 : 95.0;

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(
          // islead: false,
          // bottom: true,
          title: "My Ads",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: adsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading ads', style: bodyText16w600(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No ads found', style: bodyText16w600(color: Colors.white)));
          }

          final docs = snapshot.data!.docs;

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: horizontalPadding),
            itemCount: docs.length,
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemBuilder: (context, index) {
              final adData = docs[index].data() as Map<String, dynamic>;
              final adId = docs[index].id;

              final title = adData['title'] ?? 'No Title';
              final status = adData['status'] ?? 'Posted';
              final imageUrl = adData['imageUrl'];
              final createdAt = adData['createdAt'] ?? '';
              String postedOn = 'Unknown Date';
              try {
                final dt = DateTime.parse(createdAt);
                postedOn = "${dt.day}/${dt.month}/${dt.year}";
              } catch (_) {}

              return InkWell(
                onTap: () {
                  // Navigate to Edit screen if needed
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => EditMyAds(adId: adId)));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isDesktop ? 20 : 15, vertical: 15),
                  height: isDesktop ? 150 : 120,
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        )
                            : Image.asset(
                          "assets/images/a1.png",
                          width: imageSize,
                          height: imageSize,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: isDesktop ? 30 : 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      fontSize: isDesktop ? 20 : 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // TODO: Add delete or mark as sold functionality
                                  },
                                  child: Container(
                                    width: isDesktop ? 90 : 77,
                                    height: isDesktop ? 30 : 25,
                                    decoration: shadowDecoration(
                                      5,
                                      0,
                                      status == "Sold" ? green : Colors.blue,
                                    ),
                                    child: Center(
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          fontSize: isDesktop ? 16 : 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              "Qty.: ${adData['quantity'] ?? 'N/A'}",
                              style: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: isDesktop ? 20 : 15),
                              child: Text(
                                "Posted On: $postedOn",
                                style: TextStyle(
                                  fontSize: isDesktop ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
