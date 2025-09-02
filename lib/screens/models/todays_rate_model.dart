
import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for category rate
class CategoryRate {
  final int today;
  final int yesterday;

  CategoryRate({required this.today, required this.yesterday});

  Map<String, dynamic> toMap() {
    return {
      'today': today,
      'yesterday': yesterday,
    };
  }
}

/// Model for division rates
class DivisionRates {
  final String division;
  final Map<String, CategoryRate> categories;

  DivisionRates({required this.division, required this.categories});

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    categories.forEach((key, value) {
      map[key] = value.toMap();
    });
    return map;
  }
}

/// List of divisions and their default category rates
final List<DivisionRates> divisions = [
  DivisionRates(
    division: 'Dhaka',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 190, yesterday: 185),
      'Deshi_Chicken': CategoryRate(today: 480, yesterday: 470),
      'Egg': CategoryRate(today: 12, yesterday: 11),
      'One_Day_Chicks_Broiler': CategoryRate(today: 55, yesterday: 54),
      'One_Day_Chicks_Deshi': CategoryRate(today: 80, yesterday: 78),
      'Hatching_Egg': CategoryRate(today: 25, yesterday: 23),
    },
  ),
  DivisionRates(
    division: 'Chittagong',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 185, yesterday: 180),
      'Deshi_Chicken': CategoryRate(today: 470, yesterday: 460),
      'Egg': CategoryRate(today: 11, yesterday: 10),
      'One_Day_Chicks_Broiler': CategoryRate(today: 54, yesterday: 53),
      'One_Day_Chicks_Deshi': CategoryRate(today: 78, yesterday: 75),
      'Hatching_Egg': CategoryRate(today: 23, yesterday: 22),
    },
  ),
  DivisionRates(
    division: 'Rajshahi',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 188, yesterday: 183),
      'Deshi_Chicken': CategoryRate(today: 460, yesterday: 455),
      'Egg': CategoryRate(today: 12, yesterday: 11),
      'One_Day_Chicks_Broiler': CategoryRate(today: 52, yesterday: 50),
      'One_Day_Chicks_Deshi': CategoryRate(today: 77, yesterday: 75),
      'Hatching_Egg': CategoryRate(today: 22, yesterday: 21),
    },
  ),
  DivisionRates(
    division: 'Khulna',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 187, yesterday: 182),
      'Deshi_Chicken': CategoryRate(today: 455, yesterday: 450),
      'Egg': CategoryRate(today: 12, yesterday: 11),
      'One_Day_Chicks_Broiler': CategoryRate(today: 51, yesterday: 50),
      'One_Day_Chicks_Deshi': CategoryRate(today: 76, yesterday: 74),
      'Hatching_Egg': CategoryRate(today: 21, yesterday: 20),
    },
  ),
  DivisionRates(
    division: 'Sylhet',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 189, yesterday: 184),
      'Deshi_Chicken': CategoryRate(today: 465, yesterday: 460),
      'Egg': CategoryRate(today: 13, yesterday: 12),
      'One_Day_Chicks_Broiler': CategoryRate(today: 53, yesterday: 52),
      'One_Day_Chicks_Deshi': CategoryRate(today: 78, yesterday: 76),
      'Hatching_Egg': CategoryRate(today: 23, yesterday: 22),
    },
  ),
  DivisionRates(
    division: 'Rangpur',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 186, yesterday: 181),
      'Deshi_Chicken': CategoryRate(today: 458, yesterday: 453),
      'Egg': CategoryRate(today: 12, yesterday: 11),
      'One_Day_Chicks_Broiler': CategoryRate(today: 52, yesterday: 50),
      'One_Day_Chicks_Deshi': CategoryRate(today: 77, yesterday: 75),
      'Hatching_Egg': CategoryRate(today: 22, yesterday: 21),
    },
  ),
  DivisionRates(
    division: 'Mymensingh',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 188, yesterday: 183),
      'Deshi_Chicken': CategoryRate(today: 462, yesterday: 457),
      'Egg': CategoryRate(today: 12, yesterday: 11),
      'One_Day_Chicks_Broiler': CategoryRate(today: 53, yesterday: 52),
      'One_Day_Chicks_Deshi': CategoryRate(today: 78, yesterday: 76),
      'Hatching_Egg': CategoryRate(today: 23, yesterday: 22),
    },
  ),
  DivisionRates(
    division: 'Barisal',
    categories: {
      'Broiler_Chicken': CategoryRate(today: 185, yesterday: 180),
      'Deshi_Chicken': CategoryRate(today: 455, yesterday: 450),
      'Egg': CategoryRate(today: 11, yesterday: 10),
      'One_Day_Chicks_Broiler': CategoryRate(today: 51, yesterday: 50),
      'One_Day_Chicks_Deshi': CategoryRate(today: 76, yesterday: 74),
      'Hatching_Egg': CategoryRate(today: 21, yesterday: 20),
    },
  ),
];

/// Insert all default rates into Firestore
Future<void> insertDefaultRates() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  for (var division in divisions) {
    await firestore
        .collection('todays_rate')
        .doc(division.division)
        .set(division.toMap());
    print("Inserted ${division.division}");
  }

  print("All default rates inserted successfully!");
}
