import 'package:flutter/material.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
          child: Column(
            children: [
              Row(
                children: [
                  RaisedButton(
                    onPressed: () async {
                      FilePickerResult? file = await FilePicker.platform
                          .pickFiles(type: FileType.image);
                      if (file != null) {
                        fileLocation = file.paths;
                        setState(() {});
                        fetchedText =
                            await TesseractOcr.extractText(file.paths[0]);
                      }
                    },
                    child: Text('Select File'),
                  ),
                  SizedBox(
                    width: 25,
                  ),
                  Text('File: $fileLocation')
                ],
              ),
              SizedBox(
                height: 100,
              ),
              Text('Your text: $fetchedText')
            ],
          ),
        ));
  }
}
