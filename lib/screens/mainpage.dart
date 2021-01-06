import 'dart:io';
import 'dart:typed_data';

import 'package:beekeeper/screens/home.dart';
import 'package:beekeeper/screens/searchByID.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:beekeeper/models/news_modes.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:beekeeper/screens/newDetail.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Home()),
        ModalRoute.withName('/'));
  }

  @override
  void initState() {
    super.initState();
    readAllData();
    getFarmByCurrent();
  }

  List<NewsModels> newsModels = List();

  Widget showImage(int index) {
    return Container(
        // child: Image.network(newsModels[index].img),
        child: Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Image.network(
          newsModels[index].img,
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            newsModels[index].title,
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0),
            ),
          ),
        )
      ],
    ));
  }

  Widget showDetail(int index) {
    String string = newsModels[index].detail;
    if (string.length > 100) {
      string = string.substring(0, 99);
      string = '$string ...';
    }

    return Text(
      string,
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget showCard(int index) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showImage(index),
            Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: showDetail(index)),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                FlatButton(
                  textColor: const Color(0xFF6200EE),
                  onPressed: () {
                    var homeRounte = new MaterialPageRoute(
                      builder: (BuildContext contex) => NewDetail(
                        valueFromHome: newsModels[index].title,
                      ),
                    );
                    Navigator.of(context).push(homeRounte);
                  },
                  child: const Text('อ่านต่อ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> readAllData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference collectionReference = firestore.collection("News");
    List<DocumentSnapshot> snapshots;
    // ignore: await_only_futures
    await collectionReference.snapshots().listen((response) {
      snapshots = [];
      snapshots = response.docs;
      for (var snap in snapshots) {
        NewsModels newsModel = NewsModels.fromMap(snap.data());
        setState(() {
          newsModels.add(newsModel);
        });
      }
    });
  }

  Map result ;
  Future<void> getFarmByCurrent() async {
   await  _auth.currentUser.getIdTokenResult().then((idTokenResult) => {
      result =  idTokenResult.claims,
      print(result['Farm']),
    });
  }

  Future<void> searchByid() async {
    await FirebaseFirestore.instance
        .collection('BeeBox')
        .where('Name', isEqualTo: textEditController.text)
        .where('Idfarm', isEqualTo: result['Farm'])
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                var homeRounte = new MaterialPageRoute(
                  builder: (BuildContext contex) => SearchById(
                    valueFromHome: doc["Name"],
                  ),
                );
                Navigator.of(context).push(homeRounte);
              })
            });
  }

  var textEditController = new TextEditingController();

  void showAlertDialog() {
    // set up the buttons
    Widget continueButton = RaisedButton(
      color: Colors.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text("ค้นหา"),
      onPressed: () {
        if (textEditController.text.length > 0) {
          searchByid();
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            duration: const Duration(seconds: 4),
            content: Text("คุณยังไม่ได้ใส่ ID",
                style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red,
          ));
        }
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: const Color(0xFFA3D2CA),
      title: Center(
        child: Text(
          "ค้นหาจาก ID กล่อง",
          style: GoogleFonts.roboto(
            textStyle:
                TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      content: TextField(
        controller: textEditController,
        decoration: new InputDecoration(
            border: new OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                const Radius.circular(30.0),
              ),
            ),
            filled: true,
            hintStyle: new TextStyle(color: Colors.grey[800]),
            // hintText: "ใส่รหัสของกล่องผึ้ง",
            fillColor: Colors.white70),
      ),
      actions: [
        continueButton,
        SizedBox(
          width: 90.0,
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

  void signOutDialog(BuildContext contexts) {
    // set up the buttons
    Widget noButton = RaisedButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text("ไม่"),
      onPressed: () {
        Navigator.of(contexts).pop();
      },
    );

    Widget okButton = RaisedButton(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ),
      child: Text("ใช่"),
      onPressed: () {
        signOut(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: const Color(0xFFF8963D),
      title: Center(
        child: Text(
          "ต้องการออกจากระบบหรือไม่",
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
      context: contexts,
      builder: (BuildContext contexts) {
        return alert;
      },
    );
  }

  Future<void> getBox(String boxId) async {
    await FirebaseFirestore.instance
        .collection('BeeBox')
        .doc(boxId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document data: ${documentSnapshot.data()['Name']}');
        setState(() {
          var homeRounte = new MaterialPageRoute(
            builder: (BuildContext contex) => SearchById(
              valueFromHome: documentSnapshot.data()['Name'],
            ),
          );
          Navigator.of(context).push(homeRounte);
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      getBox(barcodeScanRes);
    });
  }

  Future scanPhoto() async {
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    Uint8List bytes = file.readAsBytesSync();
    String barcode = await scanner.scanBytes(bytes);
    getBox(barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "สวัสดี " + _auth.currentUser.displayName,
          style: GoogleFonts.roboto(
            textStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              color: Colors.white,
              onPressed: () {
                signOutDialog(context);
              })
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        width: 70.0,
        height: 70.0,
        child: FloatingActionButton(
          child: const Icon(
            Icons.qr_code_scanner,
            color: Colors.white,
            size: 35.0,
          ),
          onPressed: () {
            scanQR();
          },
        ),
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
                  Icons.search,
                  color: Colors.white,
                  size: 40.0,
                ),
                onPressed: () {
                  showAlertDialog();
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
                onPressed: () {
                  scanPhoto();
                },
              )
            ],
          ),
        ),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: newsModels.length,
          itemBuilder: (BuildContext buildContext, int index) {
            return showCard(index);
          },
        ),
      ),
    );
  }
}
