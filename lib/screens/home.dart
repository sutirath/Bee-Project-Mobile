import 'package:beekeeper/screens/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //Variable

  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    checkAuth(context);
  }

  Widget showAppname() {
    return Text("Beekeeper",
        style: TextStyle(
            fontSize: 30.0,
            color: Colors.orange.shade600,
            fontWeight: FontWeight.bold,
            fontFamily: "RussoOne"));
  }

  Widget showLogo() {
    return Container(
      width: 120.0,
      height: 120.0,
      child: Image.asset("images/logo.png"),
    );
  }

  Widget loginButton() {
    return RaisedButton(
      color: Colors.orange,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: BorderSide(color: Colors.red)),
      child: Text(
        "Login",
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
      ),
      onPressed: () {
        print("Click Login");
        // MaterialPageRoute materialPageRoute =
        //     MaterialPageRoute(builder: (BuildContext context) => MainPage());
        // Navigator.of(context).push(materialPageRoute);
        signIn();
      },
    );
  }

  Widget showButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 150.0,
          height: 50.0,
          child: loginButton(),
        ),
      ],
    );
  }

  Widget email() {
    return Container(
      width: 250.0,
      child: TextField(
        decoration: InputDecoration(labelText: 'Email'),
        keyboardType: TextInputType.emailAddress,
        controller: emailController,
      ),
    );
  }

  bool _showPassword = false;
  Widget _buildPasswordTextField() {
    return Container(
      width: 250.0,
      child: TextField(
        controller: passwordController,
        obscureText: !this._showPassword,
        decoration: InputDecoration(
          labelText: 'password',
          suffixIcon: IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: this._showPassword ? Colors.blue : Colors.grey,
            ),
            onPressed: () {
              setState(() => this._showPassword = !this._showPassword);
            },
          ),
        ),
      ),
    );
  }

  signIn() {
    _auth
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((user) {
      print("signed in");
      checkAuth(context);
    }).catchError((error) {
      print(error);
      scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text(error.message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    });
  }

  //method
  Future checkAuth(BuildContext context) async {
    // ignore: await_only_futures
    String user = await _auth.currentUser.uid;
    if (user != null) {
       Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
          gradient: LinearGradient(
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
        ),
          child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              showLogo(),
              SizedBox(
                height: 4.0,
              ),
              showAppname(),
              SizedBox(
                height: 8.0,
              ),
              email(),
              _buildPasswordTextField(),
              SizedBox(
                height: 30.0,
              ),
              showButton(),
            ]),
          ),
        ),
      ),
    );
  }
}
