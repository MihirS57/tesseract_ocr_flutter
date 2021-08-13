import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:file_picker/file_picker.dart';

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
  var fileLocation;
  String fetchedText = "";
  bool imgLoaded = false;
  Image image = Image.asset('');
  Image bawimg = Image.asset('');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
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
                        imgLoaded = true;
                        //setState(() {});
                        /* fetchedText =
                            await FlutterTesseractOcr.extractText(fileLocation);
                        var box =
                            await FlutterTesseractOcr.extractHocr(fileLocation);
                        print("Tesseract: " + fetchedText);
                        print("Box: " + box);
                        setState(() {}); */
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
                height: 100,
              ),
              Text('Your text: $fetchedText'),
              RaisedButton(
                onPressed: () {},
                child: Text('B&W it'),
              ),
              imgLoaded ? image : Container()
            ],
          ),
        ));
  }
}
