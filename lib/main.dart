import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'View/login_page.dart';
import 'View/register_page.dart';
import 'View/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Reviews',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false, 
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}