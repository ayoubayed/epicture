import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:like_button/like_button.dart';

import '../utils/addToFavorite.dart';

import '../globals.dart';

class Photo extends StatelessWidget {
  final String data;

  Photo({@required this.data});

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    return await addToFavorites(data.split(separator)[0]) ? !isLiked : isLiked;
  }

  @override
  Widget build(BuildContext context) {
    var splitData = data.split(separator);
    return Container(
      decoration: BoxDecoration(
        border:
            Border(top: BorderSide(width: 0.1, color: Colors.blueGrey[100])),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Text(
              splitData[2],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, color: Colors.blueGrey[50]),
            ),
          ),
          SizedBox(height: 10),
          Stack(children: [
            Center(
              child: CircularProgressIndicator(),
              heightFactor: 5,
            ),
            FadeInImage.memoryNetwork(
              placeholder: kTransparentImage,
              image: splitData[1],
              fit: BoxFit.fitWidth,
              width: double.infinity,
            ),
          ]),
          Row(children: [
            Spacer(),
            LikeButton(
              size: 50,
              circleColor:
                  CircleColor(start: Colors.pink, end: Colors.pink[100]),
              bubblesColor: BubblesColor(
                dotPrimaryColor: Colors.pinkAccent[400],
                dotSecondaryColor: Colors.pink[400],
              ),
              likeBuilder: (bool isLiked) {
                return Icon(
                  Icons.favorite,
                  color: isLiked ? Colors.pinkAccent : Colors.blueGrey[100],
                  size: 50,
                );
              },
              onTap: onLikeButtonTapped,
              isLiked: splitData[3] == "true",
            )
          ]),
        ],
      ),
      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
    );
  }
}
