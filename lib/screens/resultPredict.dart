import 'package:beekeeper/screens/mainpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ResulePredict extends StatefulWidget {
  final Map text;
  final String boxId;
  ResulePredict({Key key, @required this.text, this.boxId}) : super(key: key);

  @override
  _ResulePredictState createState() => _ResulePredictState();
}

class _ResulePredictState extends State<ResulePredict> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _value1 = nameList[0];
    getFarmByCurrent();
  }

  Widget showResult() {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.poll,
            color: Colors.white,
            size: 30.0,
          ),
          SizedBox(
            width: 15.0,
          ),
          Text(
            ':',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Text(
            "${widget.text['class']}" ?? 'กำลังโหลด',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget showAcuracy() {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.checkCircle,
            color: Colors.white,
            size: 30.0,
          ),
          SizedBox(
            width: 15.0,
          ),
          Text(
            ':',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ),
          SizedBox(
            width: 15.0,
          ),
          Text(
            "${widget.text['acc'].toString().substring(0, 5)}" ?? 'กำลังโหลด',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ),
        ],
      ),
    );
  }

 Map result ;
  Future<void> getFarmByCurrent() async {
   await  _auth.currentUser.getIdTokenResult().then((idTokenResult) => {
      result =  idTokenResult.claims,
      print(result['Farm']),
    });
  }

  Future<void> addData() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formatted = formatter.format(now);

    final DateTime time = DateTime.now();
    final DateFormat formate = DateFormat('H:m:s');
    final String format = formate.format(time);

    CollectionReference users =
        FirebaseFirestore.instance.collection('History');
    return await users
        .add({
          'Class': widget.text['class'],
          'Accuracy': widget.text['acc'].toString().substring(0, 5),
          'User': _auth.currentUser.uid,
          'Farm': result['Farm'],
          'UserClass': _value1,
          'BoxId': widget.boxId,
          'date': formatted,
          'time': format
        })
        .then((value) => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => MainPage(),
              ),
              (route) => false,
            ))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Widget showData() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color(0xFF5EAAA8),
        ),
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ผลการทำนาย",
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 30.0),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40.0,
              ),
              showResult(),
              SizedBox(
                height: 30.0,
              ),
              showAcuracy(),
            ],
          ),
        ),
      ),
    );
  }

  String _value1;

  final List<String> nameList = <String>[
    "ปกติ",
    "นางพญาหาย",
    "ควันไฟ",
    "ศัตรูรบกวน",
  ];

  Widget dropDown() {
    return DropdownButton(
      hint: Text("เลือกสถานะ"),
      value: _value1,
      onChanged: (value) {
        setState(() {
          _value1 = value;
        });
      },
      items: nameList.map(
        (item) {
          return DropdownMenuItem(
            value: item,
            child: new Text(item),
          );
        },
      ).toList(),
    );
  }

  Widget showUsercheck() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color(0xFFC8DFF0),
        ),
        width: MediaQuery.of(context).size.width * 0.6,
        height: 200,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "ท่านคิดว่าเป็น",
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              dropDown(),
              SizedBox(
                height: 30.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget noButton = RaisedButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text("ไม่"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget okButton = RaisedButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text("ใช่"),
      onPressed: () {
        addData();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: const Color(0xFFF8963D),
      title: Center(
        child: Text(
          "ต้องการบันทึกข้อมูลหรือไม่",
          style: GoogleFonts.roboto(
            textStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
      actions: [
        okButton,
        SizedBox(
          width: 20,
        ),
        noButton,
        SizedBox(
          width: 40,
        ),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 70.0,
        height: 70.0,
        child: FloatingActionButton(
            backgroundColor: Color(0xFF7EDDCD),
            child: Icon(
              Icons.check,
              color: Colors.green,
            ),
            onPressed: () {
              showAlertDialog(context);
            }),
      ),
      bottomNavigationBar: SizedBox(
        height: 70.0,
        child: BottomAppBar(
          color: Colors.orange,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 40.0,
                ),
                onPressed: () {
                  // showAlertDialog();
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
              ),
              IconButton(
                icon: Icon(
                  Icons.image,
                  color: Colors.white,
                  size: 40.0,
                ),
                onPressed: () {},
              )
            ],
          ),
        ),
      ),
      // body: new Text("${widget.valueFromHome}"),
      body: ListView(
        children: [
          showData(),
          showUsercheck(),
        ],
      ),
    );
  }
}
