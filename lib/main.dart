import 'package:beekeeper/screens/splash_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  runApp(Myapp());
}

class Myapp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Bee Keeper',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: SplashPage());
  }
}
