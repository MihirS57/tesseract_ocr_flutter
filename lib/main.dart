import 'dart:io' as File;
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:file_picker/file_picker.dart';
import 'package:opencv/opencv.dart';
import 'package:opencv/core/core.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tesseract OCR Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Tesseract OCR Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var fileLocation, fileLocationRoot;
  String fetchedText = "";
  bool imgLoaded = false, resultImgLoaded = false;
  dynamic res;
  File.File file = File.File('');
  Image image = Image.asset('');
  Image bawimg = Image.asset('');

  loadImage(String loc) {
    imgLoaded = true;
    resultImgLoaded = false;
    fetchedText = "";
    file = File.File(loc);
    image = Image.file(file);
    setState(() {});
  }

  loadBAWImg(String loc) async {
    if (file.path != '' && imgLoaded) {
      res = await ImgProc.threshold(
          await file.readAsBytes(), 80, 255, ImgProc.threshBinary);
      //bawimg = Image.memory(res);
      String newLoc = "$fileLocationRoot/${(DateTime.now().toString())}.jpg";
      File.File(newLoc).writeAsBytes(res);
      print(newLoc);
      fileLocation = newLoc;
      bawimg = Image.file(File.File(newLoc));
      resultImgLoaded = true;
      print('B&w done');
      setState(() {});
    }
  }

  obtainText() async {
    fetchedText = await FlutterTesseractOcr.extractText(fileLocation);
    var box = await FlutterTesseractOcr.extractHocr(fileLocation);
    print("Tesseract: " + fetchedText);
    print("Box: " + box);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    RaisedButton(
                      onPressed: () async {
                        FilePickerResult? file = await FilePicker.platform
                            .pickFiles(type: FileType.image);
                        if (file != null) {
                          fileLocation = file.paths[0];
                          fileLocationRoot = fileLocation.toString().substring(
                              0, fileLocation.toString().lastIndexOf('/'));
                          print(fileLocation);
                          print(fileLocationRoot);
                          imgLoaded = true;
                          loadImage(fileLocation);
                          setState(() {});
                          /*  */
                        }
                      },
                      child: Text('Select File'),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Flexible(
                        child: Text(
                      'File: $fileLocation',
                      overflow: TextOverflow.fade,
                    )),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  onPressed: () {
                    obtainText();
                  },
                  child: Flexible(
                      child: Text(
                    'Obtain Text',
                    overflow: TextOverflow.fade,
                  )),
                ),
                Text('Your text: $fetchedText'),
                RaisedButton(
                  onPressed: () {
                    loadBAWImg(fileLocation);
                  },
                  child: Text('Black & White it'),
                ),
                imgLoaded ? image : Container(),
                resultImgLoaded ? bawimg : Container(),
              ],
            ),
          ),
        ));
  }
}
