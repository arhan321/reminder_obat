import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_medicine_screen.dart';
import 'reminder_screen.dart';
import 'profile_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kesehatan Pribadi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/addMedicine': (context) => const AddMedicineScreen(),
        '/reminder': (context) => const ReminderScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
