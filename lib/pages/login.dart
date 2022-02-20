import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;
import 'package:google_fonts/google_fonts.dart';

import '../globals.dart' as globals;

import '../navigation.dart';

final _url = 'https://api.imgur.com/oauth2/authorize?' +
    'client_id=' +
    DotEnv.env["IMGUR_CLIENT_ID"] +
    '&response_type=' +
    DotEnv.env["IMGUR_RESPONSE_TYPE"];

_launchURL() async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  static const platform = const MethodChannel('app.channel.shared.data');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUrl();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getUrl();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (globals.user["id"].isEmpty) {
      return LoginPageLayout();
    } else {
      return Navigation();
    }
  }

  getUrl() async {
    var sharedData = await platform.invokeMethod("getResponse");
    if (sharedData != null) {
      setState(() {
        globals.user["id"] = sharedData["id"];
        globals.user["username"] = sharedData["username"];
        globals.user["refresh_token"] = sharedData["refresh_token"];
        globals.user["access_token"] = sharedData["access_token"];
      });
    }
  }
}

class LoginPageLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF26282C),
        body: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 50.0),
              Image(
                image: AssetImage('assets/images/Epicture.png'),
                width: constraints.maxWidth / 3,
              ),
              SizedBox(height: 20.0),
              Text(
                'Epicture',
                style: GoogleFonts.parisienne(
                  textStyle: TextStyle(
                      fontSize: 60.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E5EE9)),
                ),
              ),
              SizedBox(height: 200.0),
              LoginButton(),
            ],
          );
        }));
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AuthButton(),
    );
  }
}

class AuthButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            autofocus: true,
            icon: const Icon(Icons.login, size: 20),
            label: Text(
              "Continue with Imgur",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: _launchURL,
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Color(0xFF33AD4E)),
              elevation: MaterialStateProperty.all<double>(10.0),
              foregroundColor:
                  MaterialStateProperty.all<Color>(Color(0xFFFFFFFF)),
            ),
          ),
        ],
      ),
    );
  }
}
