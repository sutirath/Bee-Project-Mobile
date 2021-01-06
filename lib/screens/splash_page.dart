import 'package:beekeeper/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
        gradientBackground: LinearGradient(
          begin: Alignment(0.0024331232385113033, 0.9261285889377584),
          end: Alignment(-0.0024330458050484394, -0.9261286627480714),
          stops: [0.0, 0.30151262879371643, 0.6488975286483765, 1.0],
          colors: [
            Color.fromARGB(255, 126, 221, 204),
            Color.fromARGB(151, 175, 223, 215),
            Color.fromARGB(234, 255, 227, 201),
            Color.fromARGB(255, 247, 150, 60)
          ],
        ),
        seconds: 3,
        navigateAfterSeconds: Home(),
        title: Text(
          'BeeKeeper',
          style: TextStyle(
              fontSize: 30.0,
              color: Colors.orange.shade600,
              fontWeight: FontWeight.bold,
              fontFamily: "RussoOne"),
        ),
        image: Image.asset('images/logo.png'),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: TextStyle(color: Colors.deepPurple),
        photoSize: 100.0,
        loaderColor: Colors.pinkAccent);
  }
}
