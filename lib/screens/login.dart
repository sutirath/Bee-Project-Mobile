import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Widget email() {
    return TextField();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> signInWithEmail(BuildContext context,
      {@required String email, @required String password}) {
    return _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((result) {
      print("Welcome " + result.user.uid);
      // Navigator.pop(context);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(
      //       builder: (context) => MainPage(
      //             user: result.user,
      //           )),
      // );
      return true;
    }).catchError((e) {
      print(e);
      switch (e.code) {
        case "ERROR_WRONG_PASSWORD":
          print("Wrong Password! Try again.");
          break;
        case "ERROR_INVALID_EMAIL":
          print("Email is not correct!, Try again");
          break;
        case "ERROR_USER_NOT_FOUND":
          print("User not found! Register first!");
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => RegisterWithEmail()),
          // );
          break;
        case "ERROR_USER_DISABLED":
          print("User has been disabled!, Try again");
          break;
        case "ERROR_TOO_MANY_REQUESTS":
          print(
              "Sign in disabled due to too many requests from this user!, Try again");
          break;
        case "ERROR_OPERATION_NOT_ALLOWED":
          print(
              "Operation not allowed!, Please enable it in the firebase console");
          break;
        default:
          print("Unknown error");
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Login"),
      ),
      body: ListView(
        padding: EdgeInsets.all(30.0),
        children: [email()],
      ),
    );
  }
}
