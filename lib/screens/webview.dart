import 'dart:async';
import '../handler.dart';
import '../main.dart';
import "./signin.dart";
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:after_layout/after_layout.dart';

class WebviewTest extends StatefulWidget {
  WebViewTestState createState() => new WebViewTestState();
}

class WebViewTestState extends State<WebviewTest>
    with AfterLayoutMixin<WebviewTest> {
  var goBack;
  Future<void> listenForSignIn(BuildContext context) async {
    var user = "null"; //await getCurrentUserFromWebview();
    while (true) {
      try {
        user = await flutterWebviewPlugin.evalJavascript(
            "document.getElementsByClassName('VerticalMenu')[0].getElementsByTagName('li')[0].innerHTML;");
        print("AWAITING SIGN IN");
        if (user.toString() != "null") {
          break;
        }
      } catch (err) {}
      await Future.delayed(Duration(seconds: 2));
    }

    toastMessageBottomShort("Login Successful");
    await Future.delayed(Duration(seconds: 3));
    currentScreen = 2;
    Navigator.pushReplacementNamed(context, '/login');
  }

  Widget build(BuildContext context) {
    try {
      listenForSignIn(context);
    } catch (err) {
      print(err);
      print(err);
      print(err);
      print(err);
      print(err);
      print(err);
      print(err);
      print(err);
      print(err);
    }

    return WebviewScaffold(
      url: "https://steemit.com/login.html",
      appBar: new AppBar(
        iconTheme: IconThemeData(color: appBarTextColor),
        title: new Text(
          "Sign In to Steemit",
          style: TextStyle(
            color: appBarTextColor,
          ),
        ),
        actions: <Widget>[],
      ),
    );
  }

  void afterFirstLayout(BuildContext context) {}
}
