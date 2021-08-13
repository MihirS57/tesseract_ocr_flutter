import 'dart:io' as File;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:file_picker/file_picker.dart';
import 'package:opencv/opencv.dart';
import 'package:opencv/core/core.dart';
import 'package:flutter/services.dart' show rootBundle;

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
  bool imgLoaded = false,
      bawImgLoaded = false,
      otsuImgLoaded = false,
      ocrEngaged = false;
  dynamic res;
  File.File file = File.File('');
  Image image = Image.asset('');
  Image otsuImg = Image.asset('');
  //Image bawImg = Image.asset('');

  loadImage(String loc) {
    imgLoaded = true;
    bawImgLoaded = false;
    otsuImgLoaded = false;
    fetchedText = "";
    file = File.File(loc);
    image = Image.file(file);
    setState(() {});
  }

  /*int getLuminanceRgb(int r, int g, int b) =>
      (0.299 * r + 0.587 * g + 0.114 * b).round();

   loadBAWImg() {
    //final bytes = src.getBytes();
    var srcByteList;
    print('Loading BAW $fileLocation');
    File.File(fileLocation).readAsBytes().then((value) {
      srcByteList = Uint8List.fromList(value);
      for (var i = 0, len = srcByteList.length; i < len; i += 4) {
        final l = getLuminanceRgb(
            srcByteList[i], srcByteList[i + 1], srcByteList[i + 2]);
        srcByteList[i] = l;
        srcByteList[i + 1] = l;
        srcByteList[i + 2] = l;
      }
      String newLoc = "$fileLocationRoot/${(DateTime.now().toString())}B&W.jpg";
      File.File(newLoc).writeAsBytes(srcByteList);
      print('B&W: $newLoc');
      fileLocation = newLoc;
      bawImgLoaded = true;
      //bawImg = Image.asset(srcByteList);
      bawImg = Image.file(File.File(newLoc));
      setState(() {});
    });
  } */

  loadOTSUImg(String loc) async {
    fetchedText = "";
    ocrEngaged = false;
    if (file.path != '' && imgLoaded) {
      res = await ImgProc.threshold(
          await file.readAsBytes(), 80, 255, ImgProc.threshBinary);
      String newLoc =
          "$fileLocationRoot/${(DateTime.now().toString())}OTSU.jpg";
      File.File(newLoc).writeAsBytes(res);
      print('OTSU: $newLoc');
      fileLocation = newLoc;
      otsuImg = Image.file(File.File(newLoc));
      otsuImgLoaded = true;
      print('OTSU done');
      setState(() {});
    }
  }

  obtainText() async {
    print('OCR about to fetch');
    fetchedText = await FlutterTesseractOcr.extractText(fileLocation);
    var box = await FlutterTesseractOcr.extractHocr(fileLocation);
    if (fetchedText.isNotEmpty || fetchedText != null) {
      ocrEngaged = false;
      print('OCR Fetched');
    }
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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    ocrEngaged = true;
                    setState(() {});
                    obtainText();
                  },
                  child: Flexible(
                      child: Text(
                    'Obtain Text',
                    overflow: TextOverflow.fade,
                  )),
                ),
                ocrEngaged
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.blue,
                        ),
                      )
                    : Text('Your text: $fetchedText'),
                imgLoaded ? image : Container(),
                /* RaisedButton(
                  onPressed: () {
                    loadBAWImg();
                  },
                  child: Text('Black & White it'),
                ), */
                //bawImgLoaded ? bawImg : Container(),
                RaisedButton(
                  onPressed: () {
                    loadOTSUImg(fileLocation);
                  },
                  child: Text('OTSU'),
                ),
                otsuImgLoaded ? otsuImg : Container()
              ],
            ),
          ),
        ));
  }
}
