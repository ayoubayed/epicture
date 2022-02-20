import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

import 'pages/login.dart';

Future main() async {
  await DotEnv.load(fileName: ".env");
  runApp(Epicture());
}

class Epicture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var materialApp = MaterialApp(
      title: 'Epicture',
      home: LoginPage(),
    );
    return materialApp;
  }
}
