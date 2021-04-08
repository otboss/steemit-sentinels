import 'package:flutter/material.dart';
import 'package:steemit_sentinels/firebase.dart';
import 'package:steemit_sentinels/screens/networks.dart';
import 'package:steemit_sentinels/screens/splash.dart';
import 'package:toast/toast.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import './db.dart';
import './screens/webview.dart';
import './screens/home.dart';
import './screens/introduction.dart';
import './screens/signin.dart';
import './screens/members.dart';
import './screens/mycontent.dart';
import './screens/contribute.dart';
import './screens/qrscanner.dart';
import './screens/success_signup.dart';

void main() => runApp(
      new RestartWidget(
        child: MyApp(),
      ),
    );

/*GLOBAL VARIABLES*/

final String currentVersion = "1.0.1";

Dio dio = new Dio(Options(connectTimeout: 5000, receiveTimeout: 5000));

final FirebaseDBInterface firebaseInterface = FirebaseDBInterface();

final int inactiveMemberTimeframe = 180000;
final int maxMembersOfNetwork = 1000;
final int maxNumberOfNewPosts = 50;


DatabaseManager databaseManager = DatabaseManager();

Map<String, String> getPostDetails(String url) {
  try {
    String author = url.split("/@")[1].split("/")[0];
    String title;
    String cleanTitle(String text) {
      List<String> textArr = text.toLowerCase().split("-").join(" ").split("");
      try {
        textArr[0] = textArr[0].toUpperCase();
        for (var x = 0; x < textArr.length; x++) {
          if (textArr[x] == " ") {
            try {
              textArr[x + 1] = textArr[x + 1].toUpperCase();
            } catch (err) {
              continue;
            }
          }
        }
        return textArr.join("");
      } catch (e) {
        return text;
      }
    }

    if (url.indexOf("/@" + author + "/") > -1) {
      //POST IS VALID
      int titleStartIndex =
          url.indexOf("/@" + author + "/") + ("/@" + author + "/").length;
      title = url.substring(titleStartIndex);
      title = cleanTitle(title);
      Map<String, String> result = {
        "author": author,
        "title": title,
        "url": url
      };
      return result;
    } else {
      return null;
    }
  } catch (err) {
    print(err);
    return null;
  }
}

Future<bool> isConnected() async {
  try {
    await dio.get("http://example.com/");
    return true;
  } catch (err) {
    return false;
  }
}

enum MembershipStatus { active, inactive }

enum ContentStatus { pending, complete, error }

ThemeData themeData = new ThemeData(
    primaryColor: Color.fromRGBO(55, 193, 116, 1), backgroundColor: Colors.blue
    //primarySwatch: Colors.red[400]
    //primarySwatch: Colors.teal
    );

Color themeColor = Color.fromRGBO(55, 193, 116, 1);
Color themeColorButtons = Color.fromRGBO(49, 171, 103, 1);
Color appBarTextColor = Colors.white;
Color cardColor = Colors.white;
Color errorColor = Color.fromRGBO(245, 100, 100, 1);
Color materialGreen = Colors.teal[400];

bool isMemberActive(int timestamp) {
  if (DateTime.now().millisecondsSinceEpoch - timestamp <
      inactiveMemberTimeframe) return true;
  return false;
}

Future<bool> showCustomProcessDialog(String text, BuildContext context,
    {bool dissmissable, TextAlign alignment}) async {
  if (dissmissable == null) dissmissable = false;
  if (alignment == null) alignment = TextAlign.left;
  Widget customDialog = AlertDialog(
    title: Text(
      text,
      textAlign: alignment,
    ),
    content: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
        child: Column(
          children: <Widget>[
            CircularProgressIndicator(
              backgroundColor: themeColor,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ],
        ),
      ),
    ),
    actions: <Widget>[],
  );
  showDialog(
      context: context, child: customDialog, barrierDismissible: dissmissable);
  return true;
}

Future<void> showAlert(String title, String body, BuildContext context) {
  Widget alert = AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: ListBody(
          children: <Widget>[
            Text(body),
          ],
        ),
      ),
    ),
    actions: <Widget>[
      FlatButton(
        child: Text("OK", style: TextStyle(color: materialGreen)),
        onPressed: () {
          Navigator.pop(context);
        },
      )
    ],
  );
  showDialog(context: context, child: alert);
}

Future<void> showPrompt(String title, BuildContext context,
    TextEditingController controller, Future<dynamic> callback()) {
  Widget alert = AlertDialog(
      title: Text(
        title,
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListBody(
            children: <Widget>[
              Theme(
                data: ThemeData(cursorColor: materialGreen),
                child: TextField(
                  obscureText: false,
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: materialGreen),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: materialGreen, width: 2.0),
                      ),
                      //labelText: "(eg.) https://steemit.com/blog/@username/blog-title",
                      border: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.red)),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: materialGreen, fontSize: 16),
                      errorText: null),
                  style: TextStyle(color: materialGreen, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK", style: TextStyle(color: materialGreen)),
          onPressed: () {
            Navigator.pop(context);
            //START NEW SEARCH
            callback();
          },
        )
      ],);
  showDialog(context: context, barrierDismissible: true, child: alert);
  Completer<Null> completer = Completer();
  completer.complete();
  return completer.future;
}

Future<void> showAccountSettings(String title, BuildContext context,
    TextEditingController controller, Future<dynamic> callback()) {
  Widget alert = AlertDialog(
      title: Text(
        title,
      ),
      content: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: ListBody(
            children: <Widget>[
              Theme(
                data: ThemeData(cursorColor: materialGreen),
                child: TextField(
                  obscureText: false,
                  controller: controller,
                  autofocus: true,
                  decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: materialGreen),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: materialGreen, width: 2.0),
                      ),
                      //labelText: "(eg.) https://steemit.com/blog/@username/blog-title",
                      border: new UnderlineInputBorder(
                          borderSide: new BorderSide(color: Colors.red)),
                      labelStyle: Theme.of(context)
                          .textTheme
                          .caption
                          .copyWith(color: materialGreen, fontSize: 16),
                      errorText: null),
                  style: TextStyle(color: materialGreen, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("OK", style: TextStyle(color: materialGreen)),
          onPressed: () {
            Navigator.pop(context);
            //START NEW SEARCH
            callback();
          },
        )
      ],);
  showDialog(context: context, barrierDismissible: true, child: alert);
  Completer<Null> completer = Completer();
  completer.complete();
  return completer.future;
}

Future<bool> toastMessageBottomShort(String message) async {
  Toast.show(message, duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
  return true;
}

class UserCredentials {
  String username;
  String password;
  UserCredentials({String username, String password}) {
    this.username = username;
    this.password = password;
  }
  void setUsername(String username) {
    this.username = username;
  }

  void setPassword(String password) {
    this.password = password;
  }
}
/*END OF GLOBAL VARIABLES*/

Future<bool> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: false);
    return true;
  } else {
    return false;
    //throw 'Could not launch $url';
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MaterialApp app = MaterialApp(
      title: 'Steemit Sentinels',
      color: appBarTextColor,
      theme: themeData,
      home: Splash(),
      routes: <String, WidgetBuilder>{
        "/home": (BuildContext context) => new Home(),
        "/intro": (BuildContext context) => new Introduction(),
        "/login": (BuildContext context) => new SignIn(),
        "/scanner": (BuildContext context) => new QRViewExample(),
        "/success": (BuildContext context) => new SuccessfullyRegistered(),
        "/members": (BuildContext context) => new Members(),
        "/contribute": (BuildContext context) => new Contribute(),
        "/mycontent": (BuildContext context) => new MyContent(),
        "/webview": (BuildContext context) => new WebviewTest(),
        "/networks": (BuildContext context) => new NetworkList(),
      },
    );

    return app;
  }
}

class RestartWidget extends StatefulWidget {
  final Widget child;

  RestartWidget({this.child});

  static restartApp(BuildContext context) {
    final _RestartWidgetState state =
        context.ancestorStateOfType(const TypeMatcher<_RestartWidgetState>());
    state.restartApp();
  }

  @override
  _RestartWidgetState createState() => new _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();

  void restartApp() {
    this.setState(() {
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      key: key,
      child: widget.child,
    );
  }
}
