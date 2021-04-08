import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:steemit_sentinels/screens/signin.dart';
import 'dart:io';
import './main.dart';

class Handler extends StatefulWidget {
  LoadHandler createState() => new LoadHandler();
}

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();
  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  return File(path + '/crdts.txt');
}

Future<bool> writeInitialFile() async {
  String path = await _localPath;
  File(path + '/init.txt').writeAsString("");
  return true;
}

Future<bool> initialAppRun() async {
  String path = await _localPath;
  try {
    File file = File(path + '/init.txt');
    String contents = await file.readAsString();
    return false;
  } catch (err) {
    await writeInitialFile();
    return true;
  }
}

Future<bool> writeInitialFileForPostsGetAppCrash() async {
  String path = await _localPath;
  File(path + '/init2.txt').writeAsString("");
  return true;
}

Future<bool> initialAppRunForPostsGetAppCrash() async {
  String path = await _localPath;
  try {
    File file = File(path + '/init2.txt');
    String contents = await file.readAsString();
    return false;
  } catch (err) {
    await writeInitialFile();
    return true;
  }
}


Future<bool> setUserOfflineDetails(String username, String network) async {
  try {
    return await databaseManager.setCurrentUser(username, network);
  } catch (err) {
    print(err);
    print(err);
    return false;
  }
}


Future<String> getCurrentUserFromWebview() async {
  print("RUNNNING");
  launchUrlInWebview(signInPage, true);
  await waitForPageToLoad(signInPage);
  String username = await flutterWebviewPlugin.evalJavascript(
      "document.getElementsByClassName('VerticalMenu')[0].getElementsByTagName('li')[0].innerHTML;");
  print(username.split('"').join(""));
  print(username.split('"').join(""));
  print(username.split('"').join(""));
  if (username.toString() == "null") return null;
  return username.split('"').join("");
}

Future<String> getCurrentUser() async {
  Map currentUserInfo = await databaseManager.getCurrentUser();
  if (currentUserInfo == null)
    return null;
  else
    return currentUserInfo["username"];
}

Future<String> getCurrentNetwork() async {
  Map currentUserInfo = await databaseManager.getCurrentUser();
  if (currentUserInfo == null)
    return null;
  else
    return currentUserInfo["network"];
}

Future<bool> steemitSignOut() async {
  try {
    launchUrlInWebview(signInPage, true);
    await waitForPageToLoad(signInPage);
    await flutterWebviewPlugin.evalJavascript(
        "document.getElementsByClassName('VerticalMenu')[0].getElementsByTagName('li')[document.getElementsByClassName('VerticalMenu')[0].getElementsByTagName('li').length - 1].getElementsByTagName('a')[0].click();");
    if (await getCurrentUserFromWebview() == null) return true;
    return false;
  } catch (err) {
    print(err);
    return false;
  }
}

Future<bool> updateOfflineNetwork(String network) async {
  try {
    String user = await getCurrentUser();
    await setUserOfflineDetails(user, network);
    return true;
  } catch (err) {
    return false;
  }
}

Future<Map<String, String>> getUserPosts() async {
  try {
    await flutterWebviewPlugin.close();
  } catch (err) {
    print(err);
  }
  String user = await getCurrentUser();
  await flutterWebviewPlugin.launch("https://steemit.com/@" + user,
      hidden: true);
  await flutterWebviewPlugin.evalJavascript(
      "var results = {}; for(var x = 0; x < document.getElementsByClassName('articles__h2 entry-title').length; x++){ var element = document.getElementsByClassName('articles__h2 entry-title')[x].getElementsByTagName('a')[0]; results[element.href] = element.innerHTML.substring(element.innerHTML.indexOf('-->')+3, element.innerHTML.indexOf('<!-- /react-text -->')) }");
  String postsObject =
      await flutterWebviewPlugin.evalJavascript("JSON.stringify(results)");
  Map<String, String> result = json.decode(postsObject);
  return result;
}

Future<bool> isLoggedIn() async {
  if (await getCurrentUser() == null) return false;
  return true;
}

Future<String> getUserProfilePicture(username) async {
  String url = "https://steemitimages.com/u/" + username + "/avatar";
  Response response = await dio.get(url);
  return (response.data);
}

Future<bool> logout(BuildContext context) async {
  currentScreen = 1;
  if(await isConnected() == false)
    return false;
  await steemitSignOut();
  await databaseManager.removeCurrentUser();
  return true;
}

Future<bool> webviewLogout() async {
  await flutterWebviewPlugin.evalJavascript(
      "document.getElementsByClassName('VerticalMenu')[0].getElementsByTagName('a')[document.getElementsByClassName('VerticalMenu')[0].getElementsByTagName('a').length -1].click();");
  return true;
}

Future<bool> launchUrlInWebview(String url, bool hidden) async {
  try {
    await flutterWebviewPlugin.launch(url, hidden: hidden);
  } catch (err) {
    String currentLocation =
        await flutterWebviewPlugin.evalJavascript("window.location.href");
    currentLocation = currentLocation.split('"').join("");
    if (currentLocation != url) await flutterWebviewPlugin.reloadUrl(url);
  }
  return true;
}

final flutterWebviewPlugin = new FlutterWebviewPlugin();
final String signInPage = "https://steemit.com/login.html";
final String welcomePage = "https://steemit.com/welcome";

Future<bool> isPageCompletedLoading(desiredUrl) async {
  String status =
      await flutterWebviewPlugin.evalJavascript("document.readyState");
  String url =
      await flutterWebviewPlugin.evalJavascript("window.location.href");
  if (desiredUrl != null) {
    if ((status.indexOf("complete") >= 0 ||
            status.indexOf("interactive") >= 0) &&
        url == '"' + desiredUrl + '"') return true;
    return false;
  } else {
    if (status.indexOf("complete") >= 0 || status.indexOf("interactive") >= 0)
      return true;
    return false;
  }
}

Future<void> waitForPageToLoad(url) async {
  while (await isPageCompletedLoading(url) == false) {
    //HANG UNTIL PAGE IS FINISHED LOADING
    print("STATUS: " +
        await flutterWebviewPlugin.evalJavascript("document.readyState"));
    await Future.delayed(Duration(seconds: 2));
  }
}

Future<int> likePost(String url) async {
  //STATUS MESSAGES:
  // -1 INVALID POST
  // 0 FAILED TO LIKE POST
  // 1 POST LIKED SUCCESSFULLY
  // 2 CONNECTION ERROR
  try {
    if (await isConnected() == false) return 2;
    String user = await getCurrentUser();
    if (user.toString() != "null") {
      await launchUrlInWebview(url, true);
      await waitForPageToLoad(url);
      String currentUser = await flutterWebviewPlugin.evalJavascript(
          "document.getElementsByClassName('VerticalMenu')[0].getElementsByTagName('li')[0].innerHTML;");
      if (currentUser.toString() == "null") {
        await databaseManager.removeCurrentUser();
        return 0;
      }
      if (await isConnected() == false) return 2;
      var buttonExists = await flutterWebviewPlugin
          .evalJavascript("document.getElementById('upvote_button');");
      if (buttonExists.toString() == "null") //INVALID POST
        return -1;
      if (await isConnected() == false) return 2;
      String status = await flutterWebviewPlugin
          .evalJavascript("document.getElementById('upvote_button').title;");
      int tries = 0;
      while (status != '"Remove Vote"') {
        await flutterWebviewPlugin.evalJavascript(
            "document.getElementById('upvote_button').click();");
        await Future.delayed(Duration(seconds: 10));
        status = await flutterWebviewPlugin
            .evalJavascript("document.getElementById('upvote_button').title;");
        if (await isConnected() == false) return 2;
        tries++;
        if (tries >= 5) {
          return 0;
        }
      }
      return 1;
    } else {
      return 0;
    }
  } catch (err) {
    print("ERROR on handler.dart: " + err);
    print("ERROR on handler.dart: " + err);
    print("ERROR on handler.dart: " + err);
    print("ERROR on handler.dart: " + err);
    print("ERROR on handler.dart: " + err);
    print("ERROR on handler.dart: " + err);
    return 0;
  }
}

String stripTextQuoteFromConsoleOutput(String text) {
  text = text.split("'").join("");
  text.split('"').join("");
  return text;
}

class LoadHandler extends State<Handler> {
  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    return new Scaffold();
  }
}
