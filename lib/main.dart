import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:html/parser.dart' as html_parser;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Image Classification using ResNet50'),
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
  File? _image;
  final picker = ImagePicker();
  String _prediction = '';
  String _percentage = '';
  String _error = '';

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future uploadImage(File imageFile) async {
    try {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var uri = Uri.parse("https://img-classification-using-flask-lgcs2dkt6a-uc.a.run.app/");

      var request = http.MultipartRequest("POST", uri);
      var multipartFile = http.MultipartFile('photo', stream, length,
          filename: path.basename(imageFile.path));

      request.files.add(multipartFile);
      var response = await request.send();

      var responseData = await http.Response.fromStream(response);

      print('Response Status: ${responseData.statusCode}');
      print('Response Headers: ${responseData.headers}');
      print('Response Body: ${responseData.body}');

      if (responseData.statusCode == 200) {
        var document = html_parser.parse(responseData.body);
        var prediction = document
            .querySelector('.result')
            ?.text
            ?.split('The prediction is: ')[1]
            ?.split('With probability: ')[0]
            ?.trim();
        var percentage = document
            .querySelector('.result')
            ?.text
            ?.split('With probability: ')[1]
            ?.trim();

        setState(() {
          _prediction = prediction ?? 'Prediction not found';
          _percentage = percentage ?? 'Percentage not found';
          _error = '';
        });
      } else {
        setState(() {
          _error = 'Server error: ${responseData.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error uploading image: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 4.0),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: _image == null
                    ? Center(
                        child: Text(
                          'No image selected',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.black,
                          ),
                        ),
                      )
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: getImage,
                    child: Text('Pick Image'),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        return Color.fromARGB(255, 0, 170, 255);
                      }),
                      shape: WidgetStateProperty.resolveWith<
                          OutlinedBorder>((states) {
                        return RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        );
                      }),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_image != null) {
                        uploadImage(_image!);
                      }
                    },
                    child: Text('Predict Image'),
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.resolveWith<Color>((states) {
                        return Color.fromARGB(255, 0, 170, 255);
                      }),
                      shape: WidgetStateProperty.resolveWith<
                          OutlinedBorder>((states) {
                        return RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                _error.isNotEmpty
                    ? 'Error: $_error'
                    : _prediction.isEmpty
                        ? ''
                        : 'Prediction: $_prediction\nConfidence: $_percentage',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
