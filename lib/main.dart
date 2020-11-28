import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:flutter_face_detection/flutter_face_detection.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  final picker = ImagePicker();

  void processor() async {
    String text;
    String entityId;
    double confidence;
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(_image);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    final List<ImageLabel> labels = await labeler.processImage(visionImage);

    for (ImageLabel label in labels) {
      text = label.text;
      entityId = label.entityId;
      double confidence = label.confidence;
    }
    labeler.close();

    Alert(
      context: context,
      type: AlertType.info,
      title: "Your Image Is",
      desc: text,
      buttons: [
        DialogButton(
          child: Text(
            "CLOSE",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  /*void processor() async {
    var detector = FaceDetector(width: 280, height: 396);
    var image = Image.file(_image);
    var bitmap = Bitmap.fromImage(image);

    for (var face in await detector.findFaces(bitmap)) {
      print(
          "Found a face at (${face.midPoint.x}, ${face.midPoint.y}) with confidence ${face.confidence}");
    }
  }*/

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future getImageFromFile() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Image Processor')),
      ),
      body: Center(
          child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: _image == null
                  ? Text('No image selected.')
                  : Image.file(_image),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: getImage,
                  tooltip: 'Pick Image',
                  icon: Icon(Icons.add_a_photo),
                  iconSize: 50.0,
                ),
                SizedBox(
                  width: 50,
                ),
                IconButton(
                  onPressed: getImageFromFile,
                  tooltip: 'Pick Image',
                  icon: Icon(Icons.filter),
                  iconSize: 50.0,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: processor,
              child: Container(
                child: Text(
                  'PROCESS',
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
