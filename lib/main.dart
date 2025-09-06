import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:poultry_app/screens/start/splash.dart';

// Wallet / History pages (old features)
import 'package:poultry_app/payments/pages/wallet_page.dart';
import 'package:poultry_app/payments/pages/transaction_history_page.dart';
import 'package:poultry_app/payments/pages/order_history_page.dart';

// Rewards & Games pages
import 'package:poultry_app/rewards/games/spin_wheel_page.dart';
import 'package:poultry_app/rewards/games/quiz_page.dart';
import 'package:poultry_app/rewards/games/scratch_page.dart';
import 'package:poultry_app/rewards/pages/quests_page.dart';
import 'package:poultry_app/rewards/pages/leaderboard_page.dart';
import 'package:poultry_app/rewards/games/snake_game_page.dart';
import 'package:poultry_app/screens/mainscreens/games_hub_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyAclkKEMjBb2dQLYpg4OtYyM1a18OGUqUY",
            authDomain: "esp32-e0a40.firebaseapp.com",
            databaseURL:
                "https://esp32-e0a40-default-rtdb.asia-southeast1.firebasedatabase.app",
            projectId: "esp32-e0a40",
            storageBucket: "esp32-e0a40.firebasestorage.app",
            messagingSenderId: "599759290685",
            appId: "1:599759290685:web:f54df0838f46f2e9bbc554",
            measurementId: "G-V65BQGMNQ9"),
      );
    } else {
      await Firebase.initializeApp();
    }

    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }

  //await insertDefaultRates();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EGGcellent 471',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      //home: const TodayRatePage(),
      routes: {
        // legacy/payment routes
        '/wallet': (_) => const WalletPage(),
        '/transactions': (_) => const TransactionHistoryPage(),
        '/orders': (_) => const OrderHistoryPage(),
        // rewards menu destinations
        '/spin': (_) => const SpinWheelPage(),
        '/quiz': (_) => const QuizPage(),
        '/scratch': (_) => const ScratchPage(),
        '/quests': (_) => const QuestsPage(),
        '/leaderboard': (_) => const LeaderboardPage(),
        '/snake': (_) => const SnakeGamePage(),
        '/games': (_) => const GamesHubPage(),
      },
      onUnknownRoute: (_) => MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('Route not found')),
        ),
      ),
    );
  }
}
