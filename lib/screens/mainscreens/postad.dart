import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/custombutton.dart';
import 'package:poultry_app/widgets/customdropdown.dart';
import 'package:poultry_app/widgets/customtextfield.dart';
import 'package:poultry_app/widgets/dialogbox.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import '../../Responsive_helper.dart';
import '../../newAuth/add_post_model.dart';
import '../Inventory tracker/inventoryService.dart';

class PostAdPage extends StatefulWidget {
  const PostAdPage({super.key});

  @override
  State<PostAdPage> createState() => _PostAdPageState();
}

class _PostAdPageState extends State<PostAdPage> {
  List<String> list = ["Broiler", "Deshi", "Eggs", "Hatching Eggs", "Chicks", "Ducks"];
  String? selectedCategory;

  final _inventoryService = FarmerInventoryService();

  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final contactController = TextEditingController();
  final cityController = TextEditingController();
  final regionController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    contactController.dispose();
    cityController.dispose();
    regionController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _postAd() async {
    if (selectedCategory == null ||
        nameController.text.isEmpty ||
        quantityController.text.isEmpty ||
        contactController.text.isEmpty ||
        cityController.text.isEmpty ||
        regionController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => ShowDialogBox(message: "Please fill all fields."),
      );
      return;
    }

    final ad = AdModel(
      userId: FirebaseAuth.instance.currentUser!.uid,
      type: selectedCategory!,
      name: nameController.text,
      quantity: int.tryParse(quantityController.text) ?? 0,  // ✅ save as int
      price: double.tryParse(priceController.text) ?? 0.0,   // ✅ save as number
      contactNumber: contactController.text,
      city: cityController.text,
      region: regionController.text,
      description: descriptionController.text,
    );


    await FirebaseFirestore.instance.collection('collectionofall').add(ad.toMap());

    showDialog(
      context: context,
      builder: (_) => const ShowDialogBox(message: "Ad Posted!!"),
    );

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final qty = int.tryParse(quantityController.text) ?? 0;
    if (qty > 0) {
      await _inventoryService.addProduct(userId, selectedCategory!, qty);
    }

    setState(() {
      selectedCategory = null;
      nameController.clear();
      quantityController.clear();
      contactController.clear();
      cityController.clear();
      regionController.clear();
      descriptionController.clear();
      priceController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Colors.grey[900];
    final cardColor = Colors.grey[850];
    final textColor = Colors.white70;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: GeneralAppBar(title: "Post Your Ad"),
      ),
      body: ResponsiveHelper.responsiveLayout(
        context: context,
        mobile: _buildForm(context, isDesktop: false),
        tablet: _buildForm(context, isDesktop: false),
        desktop: _buildForm(context, isDesktop: true),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {bool isDesktop = false}) {
    final horizontalPadding = isDesktop ? 120.0 : 15.0;
    final widthFactor = isDesktop ? 0.6 : 1.0;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 25),
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * widthFactor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Upload Image Section
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: DottedBorder(
                    borderType: BorderType.RRect,
                    dashPattern: const [8, 5],
                    strokeWidth: 2,
                    color: Colors.grey[500]!,
                    radius: const Radius.circular(15),
                    child: SizedBox(
                      width: double.infinity,
                      height: isDesktop ? 180 : 140,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.file_upload_outlined, size: isDesktop ? 60 : 50, color: Colors.grey[500]),
                          const SizedBox(height: 10),
                          Text(
                            "Upload image",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isDesktop ? 16 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // Dropdown
              CustomDropdown(
                list: list,
                height: 58,
                hint: "Type",
                onChanged: (value) => setState(() => selectedCategory = value),
              ),
              const SizedBox(height: 15),

              // TextFields
              CustomTextField(controller: nameController, hintText: "Name"),
              const SizedBox(height: 15),
              CustomTextField(controller: quantityController, hintText: "Quantity"),
              const SizedBox(height: 15),
              CustomTextField(controller: priceController, hintText: "Price (per unit)"),
              const SizedBox(height: 15),
              CustomTextField(controller: contactController, hintText: "Contact Number"),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: CustomTextField(controller: cityController, hintText: "City")),
                  const SizedBox(width: 20),
                  Expanded(child: CustomTextField(controller: regionController, hintText: "Region")),
                ],
              ),
              const SizedBox(height: 15),
              CustomTextField(controller: descriptionController, hintText: "Description"),
              const SizedBox(height: 25),

              // Post Button
              CustomButton(
                text: "Post",
                onClick: _postAd,
                width: double.infinity,
                height: 55,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
