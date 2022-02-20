import 'dart:convert';
import 'package:epicture/globals.dart';
import 'package:path/path.dart' as path;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/photo.dart';

class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> with WidgetsBindingObserver {
  ScrollController controller;
  bool _loading;
  var headers = {'Authorization': 'Bearer ${user["access_token"]}'};

  var _page = 1;
  var _pageDisplayed = 1;
  List<String> data = [];
  List<String> dataReduced = [];

  Future<void> loadPhotos(String search) async {
    setState(() {
      _loading = true;
      data = [];
      dataReduced = [];
    });
    await fetchPhotos(search);
    print(data.length);
    setState(() {
      _loading = false;
      if (data.length > 0) dataReduced = data.sublist(0, 10);
    });
  }

  Future<void> fetchPhotos(String search) async {
    print("Start fetch");

    var request = http.MultipartRequest(
        'GET', Uri.parse('https://api.imgur.com/3/gallery/search/?q=$search'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      _pageDisplayed++;
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
        _page++;
        dataReduced = data.sublist(0, _page * 10);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 135,
          padding: const EdgeInsets.only(top: 40.0, left: 20.0, right: 20.0),
          child: Center(
              child: Column(
            children: [
              Text("Search",
                  style: TextStyle(color: Colors.blueGrey[100], fontSize: 40)),
              TextField(
                style: TextStyle(
                  color: Colors.blueGrey[100],
                ),
                decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    border: InputBorder.none,
                    hintText: 'Search',
                    hintStyle: TextStyle(color: Colors.blueGrey[200])),
                onSubmitted: (String search) {
                  loadPhotos(search);
                },
              ),
            ],
          )),
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
            height: MediaQuery.of(context).size.height - 201,
            child: new ListView.builder(
              controller: controller,
              itemBuilder: (context, index) {
                if (_loading)
                  return CircularProgressIndicator();
                else
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
