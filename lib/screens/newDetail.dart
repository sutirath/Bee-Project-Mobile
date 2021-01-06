import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NewDetail extends StatefulWidget {
  final String valueFromHome;

  NewDetail({Key key, this.valueFromHome}) : super(key: key);

  @override
  _NewDetailState createState() => _NewDetailState();
}

class _NewDetailState extends State<NewDetail> {
  @override
  void initState() {
    super.initState();
    readAllData();
  }

  String title, detail, img;
  Future<void> readAllData() async {
    await FirebaseFirestore.instance
        .collection('News')
        .where('title', isEqualTo: widget.valueFromHome)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                print(doc["title"]);
                setState(() {
                  title = doc["title"];
                  detail = doc["detail"];
                  img = doc["img"];
                });
              })
            });
  }

  Widget showImage() {
    return Container(
        // child: Image.network(newsModels[index].img),
        child: Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Image.network(
          img ?? 'กำลังโหลด',
          fit: BoxFit.fitWidth,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            title ?? 'กำลังโหลด',
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

  Widget showDetail() {
    return Text(
      detail ?? 'กำลังโหลด',
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
          color: Colors.black,
        ),
      ),
    );
  }

  Widget showCard() {
    return Container(
      padding: EdgeInsets.all(5.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showImage(),
            Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                child: showDetail()),
            ButtonBar(
              alignment: MainAxisAlignment.start,
              children: [
                // FlatButton(
                //   textColor: const Color(0xFF6200EE),
                //   onPressed: () {
                //     // Perform some action
                //   },
                //   child: const Text('อ่านต่อ'),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          title ?? 'กำลังโหลด',
          style: GoogleFonts.roboto(
            textStyle:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
     
      ),
      body: Container(
        child: ListView(
          children: [
            showCard(),
          ],
        ),
      ),
    );
  }
}
