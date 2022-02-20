import 'dart:convert';
import 'package:epicture/globals.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/photo.dart';

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  ScrollController controller;
  bool _loading;
  var headers = {'Authorization': 'Bearer ${user["access_token"]}'};

  var _page = 1;
  var _pageDisplayed = 1;
  List<String> data = [];
  List<String> dataReduced = [];

  Future<void> loadPhotos() async {
    await fetchPhotos();
    print(data.length);
    setState(() {
      _loading = false;
      if (data.length > 0) {
        try {
          dataReduced = data.sublist(0, 10);
        } catch (RangeError) {
          dataReduced = data;
        }
      }
    });
  }

  Future<void> fetchPhotos() async {
    print("Start fetch");

    var request = http.MultipartRequest('GET',
        Uri.parse('https://api.imgur.com/3/gallery/hot/viral/day/$_page'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      _page++;
      dynamic Object = jsonDecode(await response.stream.bytesToString());
      List<dynamic> list = [];
      Object.forEach((k, v) => {if (k == "data") list.add(v)});
      list.forEach((element) {
        element.forEach((e) => {
              if (e["images"] != null)
                {
                  if (path.extension(e["images"][0]["link"]) == ".jpg" ||
                      path.extension(e["images"][0]["link"]) == ".png" ||
                      path.extension(e["images"][0]["link"]) == ".jpeg")
                    data.add(e["images"][0]["id"] +
                        separator +
                        e["images"][0]["link"] +
                        separator +
                        e["title"] +
                        separator +
                        e["images"][0]["favorite"].toString()),
                }
            });
      });
    } else {
      print(response.reasonPhrase);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = new ScrollController()..addListener(_scrollListener);
    _loading = true;
    loadPhotos();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    print(controller.position.extentAfter);
    if (controller.position.extentAfter == 0) {
      setState(() {
        if (dataReduced.length < data.length) {
          _pageDisplayed++;
          try {
            dataReduced = data.sublist(0, _pageDisplayed * 10);
          } catch (RangeError) {
            dataReduced = data;
          }
        } else {
          _page++;
          fetchPhotos();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      if (_loading)
        return CircularProgressIndicator();
      else
        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Error",
                style: TextStyle(color: Colors.redAccent, fontSize: 30)),
            ElevatedButton(
                onPressed: () {
                  _loading = true;
                  _pageDisplayed = 1;
                  loadPhotos();
                },
                child: Text("Retry"))
          ],
        ));
    } else {
      return Column(
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.only(top: 40.0),
            child: Center(
              child: Text("Epicture",
                  style: TextStyle(fontSize: 40, color: Colors.blueGrey[100])),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                    top: BorderSide(width: 1, color: Colors.blueGrey[100])),
              ),
              height: MediaQuery.of(context).size.height - 166,
              child: new ListView.builder(
                controller: controller,
                itemBuilder: (context, index) {
                  return new Photo(data: dataReduced[index]);
                },
                itemCount: dataReduced.length,
              ),
            ),
          )
        ],
      );
    }
  }
}
