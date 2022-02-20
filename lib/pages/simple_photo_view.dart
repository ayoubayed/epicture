import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:epicture/globals.dart' as globals;
import 'dart:developer' as developer;

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File image;
  final picker = ImagePicker();
  Future<File> file;
  String status = '';
  String base64Image;
  File tmpFile;
  String error = 'Error';

  chooseImage() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.gallery);
    });
    setStatus('');
  }

  useCamera() {
    setState(() {
      file = ImagePicker.pickImage(source: ImageSource.camera);
    });
    setStatus('');
  }

  setStatus(String message) {
    setState(() {
      status = message;
    });
  }

  upload() async {
    var headers = {
      'Authorization': 'Bearer ' + globals.user["access_token"],
    };
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://api.imgur.com/3/image'));
    request.fields.addAll({
      'image': base64Image,
      'title': 'Image Imported with Epicture App',
    });

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image/Data'),
        actions: <Widget>[
          Container(
              margin: EdgeInsets.only(right: 10),
              child: FloatingActionButton(
                onPressed: () {
                  //action code for button 2
                  useCamera();
                },
                backgroundColor: Colors.deepPurpleAccent,
                child: Icon(Icons.camera_enhance),
              )), // button second

          Container(
            child: FloatingActionButton(
              onPressed: () {
                //action code for button 3
                chooseImage();
              },
              backgroundColor: Colors.deepOrangeAccent,
              child: Icon(Icons.crop_original),
            ),
          ),
        ],
      ), // but
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder<File>(
                future: file,
                builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      null != snapshot.data) {
                    tmpFile = snapshot.data;
                    base64Image = base64Encode(snapshot.data.readAsBytesSync());
                    return Container(
                      margin: EdgeInsets.all(15),
                      child: Material(
                        elevation: 3.0,
                        child: Image.file(
                          snapshot.data,
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  } else if (null != snapshot.error) {
                    return const Text(
                      'Error!',
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Container(
                      margin: EdgeInsets.all(15),
                      child: Material(
                        elevation: 3.0,
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              child: Image.asset(
                                  'assets/images/placeholder-image.png'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
              SizedBox(
                height: 70.0,
              ),
              Container(
                height: 50.0,
                width: 360.0,
                child: RaisedButton(
                  child: Text(
                    'Upload Image',
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                  color: Colors.blue,
                  onPressed: () {
                    upload();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
