import 'package:epicture/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ProfileWidget extends StatelessWidget {
  final String infos;

  ProfileWidget({@required this.infos});

  @override
  Widget build(BuildContext context) {
    List<String> infosList = infos.split(separator);
    if (infosList[2] == "") infosList[2] = "Empty bio";
    return (Container(
      child: Column(
        children: [
          FadeInImage.memoryNetwork(
            placeholder: kTransparentImage,
            image: infosList[3],
            fit: BoxFit.fitWidth,
            width: 100,
          ),
          SizedBox(height: 10),
          Text(infosList[2],
              style: TextStyle(
                color: Colors.blueGrey[100],
                fontSize: 20,
              )),
        ],
      ),
    ));
  }
}
