import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poultry_app/utils/constants.dart';
import 'package:poultry_app/widgets/generalappbar.dart';
import '../../Responsive_helper.dart';

class TodayRatePage extends StatefulWidget {
  const TodayRatePage({super.key});

  @override
  State<TodayRatePage> createState() => _TodayRatePageState();
}

class _TodayRatePageState extends State<TodayRatePage> {
  final List<String> states = [
    "Dhaka",
    "Chittagong",
    "Rajshahi",
    "Khulna",
    "Sylhet",
    "Rangpur",
    "Mymensingh",
    "Barisal",
  ];

  String selectedState = "Dhaka";
  Map<String, dynamic> rates = {};

  @override
  void initState() {
    super.initState();
    fetchRates();
  }

  Future<void> fetchRates() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('todays_rate')
          .doc(selectedState)
          .get();

      if (snapshot.exists) {
        setState(() {
          rates = snapshot.data()!;
        });
      }
    } catch (e) {
      print("Error fetching rates: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = Colors.grey[900];
    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: const GeneralAppBar(title: "Today's Rates"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ResponsiveHelper.responsiveLayout(
          context: context,
          mobile: _buildBody(),
          tablet: _buildBody(),
          desktop: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          "Select State",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButton<String>(
            value: selectedState,
            dropdownColor: Colors.grey[850],
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            isExpanded: true,
            underline: const SizedBox(),
            style: TextStyle(color: Colors.white, fontSize: 14),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedState = value;
                  rates = {};
                });
                fetchRates();
              }
            },
            items: states
                .map((state) => DropdownMenuItem<String>(
              value: state,
              child: Text(state),
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 25),
        Expanded(
          child: rates.isEmpty
              ? Center(
            child: CircularProgressIndicator(),
          )
              : _buildRatesTable(),
        ),
      ],
    );
  }

  Widget _buildRatesTable() {
    final categoryNames = rates.keys.toList();
    return Column(
      children: [
        // Header Row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  "Category",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Today's Rate",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  "Yesterday's Rate",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // List of rates
        Expanded(
          child: ListView.builder(
            itemCount: categoryNames.length,
            itemBuilder: (context, index) {
              final cat = categoryNames[index];
              final today = rates[cat]?['today'] ?? "--";
              final yesterday = rates[cat]?['yesterday'] ?? "--";

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.grey[850]!, Colors.grey[800]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        cat,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "$today Tk/kg",
                        style: const TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "$yesterday Tk/kg",
                        style: const TextStyle(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
