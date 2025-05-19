import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' show BluetoothService;
import 'package:provider/provider.dart';
import 'package:yogamat/screens/ota_screen.dart';
import 'package:yogamat/screens/product_showcase.dart';
// import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/connection_screen.dart';
import 'screens/control_panel_screen.dart';
import 'screens/music_screen.dart';
import 'services/auth_service.dart';
import 'services/bluetooth_service.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => BluetoothServicee()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Yoga Mat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        brightness: Brightness.light,
        fontFamily: 'Poppins',
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.teal,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: HomeScreen(),
      // home: StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }
      //     if (snapshot.hasData) {
      //       return const HomeScreen();
      //     }
      //     return const LoginScreen();
      //   },
      // ),
      routes: {
        '/home': (context) => const HomeScreen(),
        '/connection': (context) => const ConnectionScreen(),
        '/control_panel': (context) => const ControlPanelScreen(),
        '/music': (context) => const MusicScreen(),
        '/products': (context) => const ProductShowcaseScreen(),
        '/ota_update': (context) => const OtaUpdateScreen(),
      },
    );
  }
}
