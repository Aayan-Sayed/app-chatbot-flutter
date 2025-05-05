import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import
import 'screens/splash_screen.dart';
import 'firebase_options.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(); // Add this line to load .env file
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ShaktiAIApp());  // Changed from ChatterAIApp
}

class ShaktiAIApp extends StatelessWidget {  // Changed from ChatterAIApp
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShaktiAI',  // Changed from ChatterAI
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
