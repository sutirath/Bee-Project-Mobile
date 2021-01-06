import 'dart:typed_data';

import 'package:beekeeper/screens/resultPredict.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io' as io;
import "dart:convert";
import 'package:audioplayers/audioplayers.dart';
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:qrscan/qrscan.dart' as scanner;

class SearchById extends StatefulWidget {
  final LocalFileSystem localFileSystem;
  final String valueFromHome;

  SearchById({Key key, localFileSystem, this.valueFromHome})
      : this.localFileSystem = localFileSystem ?? LocalFileSystem(),
        super(key: key);

  @override
  _SearchByIdState createState() => _SearchByIdState();
}

class _SearchByIdState extends State<SearchById> {
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;

  @override
  void initState() {
    super.initState();
    readData();
    _init();
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
//        io.Directory appDocDirectory = await getApplicationDocumentsDirectory();
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }

        // can add extension like ".mp4" ".wav" ".m4a" ".aac"
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();

        // .wav <---> AudioFormat.WAV
        // .mp4 .m4a .aac <---> AudioFormat.AAC
        // AudioFormat is optional, if given value, will overwrite path extension when there is conflicts.
        _recorder = FlutterAudioRecorder(customPath,
            audioFormat: AudioFormat.WAV, sampleRate: 48000);

        await _recorder.initialized;
        // after initialization
        var current = await _recorder.current(channel: 2);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print("this is error");
      print(e);
    }
  }

  _start() async {
    showRecDialog(context);
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_current.duration.toString() == "0:00:10.000000") {
          t.cancel();
          _stop();
          Navigator.of(context).pop();
        }
        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _resume() async {
    await _recorder.resume();
    setState(() {});
  }

  _pause() async {
    await _recorder.pause();
    setState(() {});
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    File file = widget.localFileSystem.file(result.path);
    print("File length: ${await file.length()}");
    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
  }

  Widget _buildText(RecordingStatus status) {
    var text = "";
    switch (_currentStatus) {
      case RecordingStatus.Initialized:
        {
          text = 'เริ่ม';
          break;
        }
      case RecordingStatus.Recording:
        {
          text = 'หยุด';
          break;
        }
      case RecordingStatus.Paused:
        {
          text = 'ต่อ';
          break;
        }
      case RecordingStatus.Stopped:
        {
          text = 'ทำนาย';
          break;
        }
      default:
        break;
    }
    return Text(
      text,
      style: GoogleFonts.roboto(
        textStyle: TextStyle(
            color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  void onPlayAudio() async {
    AudioPlayer audioPlayer = AudioPlayer();
    await audioPlayer.play(_current.path, isLocal: true);
  }

  Future<void> deleteFile() async {
    try {
      io.File file = new io.File(_current.path);
      await file.delete();
    } catch (e) {
      return 0;
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: const Color(0xFFA3D2CA),
      content: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7),
              child: Text(
                "กำลังทำนายผล",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              )),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showRecDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      backgroundColor: const Color(0xFFA3D2CA),
      content: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          Container(
              margin: EdgeInsets.only(left: 7),
              child: Text(
                "กำลังบันทึกเสียง",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              )),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void myalert(String title, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: ListTile(
              leading: Icon(
                Icons.add_alert,
                color: Colors.green,
              ),
              title: Text(
                title,
                style: TextStyle(color: Colors.green),
              ),
            ),
            content: Text(message.substring(1, 27)),
            actions: [
              FlatButton(
                onPressed: () {
                  _init();
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              )
            ],
          );
        });
  }

  Future<void> predict() async {
    showLoaderDialog(context);
    print(_current.path);
    var request =
        http.MultipartRequest('POST', Uri.parse('http://18.188.59.1/files/'));
    request.files.add(await http.MultipartFile.fromPath('file', _current.path));

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      // myalert("Result", await response.stream.bytesToString());
      deleteFile();
      final respStr = await response.stream.bytesToString();
      Map<String, dynamic> userMap = jsonDecode(respStr);
      var homeRounte = new MaterialPageRoute(
        builder: (BuildContext contex) => ResulePredict(
          text: userMap,
          boxId: boxid,
        ),
      );
      Navigator.of(context).push(homeRounte);
    } else {
      print(response.reasonPhrase);
    }
  }

  String date, spc, boxid;

  Future<void> readData() async {
    await FirebaseFirestore.instance
        .collection('BeeBox')
        .where('Name', isEqualTo: widget.valueFromHome)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  date = doc['Created'];
                  spc = doc['Species'];
                  boxid = doc.id;
                });
              })
            });
  }

  Future<void> readByPicture(String name) async {
    await FirebaseFirestore.instance
        .collection('BeeBox')
        .where('Name', isEqualTo: name)
        .get()
        .then((QuerySnapshot querySnapshot) => {
              querySnapshot.docs.forEach((doc) {
                setState(() {
                  date = doc['Created'];
                  spc = doc['Species'];
                  boxid = doc.id;
                });
              })
            });
  }

  Widget showSPC() {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.dna,
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
            spc ?? 'กำลังโหลด',
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

  Widget showCreated() {
    return Padding(
      padding: const EdgeInsets.only(left: 50),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.calendar,
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
            date ?? 'กำลังโหลด',
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.valueFromHome}",
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
                height: 30.0,
              ),
              showCreated(),
              SizedBox(
                height: 30.0,
              ),
              showSPC(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showtime() {
    return Padding(
      padding: const EdgeInsets.only(left: 80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.clock,
            color: Colors.black,
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
            "${_current?.duration.toString().substring(0, 10)}" ?? 'กำลังโหลด',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget showStatus() {
    return Padding(
      padding: const EdgeInsets.only(left: 80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            FontAwesomeIcons.microphone,
            color: Colors.black,
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
            "${_currentStatus.toString().substring(16)}" ?? 'กำลังโหลด',
            style: GoogleFonts.roboto(
              textStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget showRec() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color(0xFF5EAAA8),
        ),
        width: MediaQuery.of(context).size.width * 0.6,
        height: 250,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "สถานะการอัดเสียง",
                    style: GoogleFonts.roboto(
                      textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              showtime(),
              SizedBox(
                height: 30.0,
              ),
              showStatus(),
            ],
          ),
        ),
      ),
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
          readByPicture(documentSnapshot.data()['Name']);
        });
      } else {
        print('Document does not exist on the database');
      }
    });
  }

  Future scanPhoto() async {
    // ignore: deprecated_member_use
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    Uint8List bytes = file.readAsBytesSync();
    String barcode = await scanner.scanBytes(bytes);
    readByPicture(barcode);
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
          child: _buildText(_currentStatus),
          onPressed: () {
            switch (_currentStatus) {
              case RecordingStatus.Initialized:
                {
                  _start();
                  break;
                }
              case RecordingStatus.Recording:
                {
                  _pause();
                  break;
                }
              case RecordingStatus.Paused:
                {
                  _resume();
                  break;
                }
              case RecordingStatus.Stopped:
                {
                  predict();
                  break;
                }
              default:
                break;
            }
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
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 40.0,
                ),
                onPressed: () {
                  scanQR();
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
      // body: new Text("${widget.valueFromHome}"),
      body: ListView(
        children: [
          showData(),
          showRec(),
        ],
      ),
    );
  }
}
