import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:after_layout/after_layout.dart';
import '../main.dart';
import 'dart:io';
import 'dart:async';
import '../handler.dart';
import '../firebase.dart';

class SignIn extends StatefulWidget {
  SignInState createState() => new SignInState();
}

class JoinNetworkQueryResponse {
  bool exists;
  String networkName;
  JoinNetworkQueryResponse({String networkName, bool exists}) {
    this.exists = exists;
    this.networkName = networkName;
  }
}

TextEditingController networkField = TextEditingController();
int currentScreen = 1;

class SignInState extends State<SignIn> with AfterLayoutMixin<SignIn> {
  void selectNetworkNameDialog() {
    var networkNameController = TextEditingController();
    Widget networkNameDialog = AlertDialog(
      title: Text('Name Your Network'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Theme(
              data: ThemeData(cursorColor: materialGreen),
              child: TextField(
                obscureText: false,
                controller: networkNameController,
                autofocus: true,
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: materialGreen),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: materialGreen, width: 2.0),
                    ),
                    //labelText: placeholder,
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(color: Colors.red),
                    ),
                    labelStyle: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(color: materialGreen, fontSize: 16),
                    errorText: null),
                style: TextStyle(color: materialGreen, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(
            'OK',
            style: TextStyle(color: materialGreen),
          ),
          onPressed: () {
            Navigator.pop(context);
            String newNetworkName = networkNameController.text;
          },
        ),
      ],
    );
    showDialog(
        context: context, child: networkNameDialog, barrierDismissible: true);
  }

  Widget themedTextField(
      String placeholder, TextEditingController controller, bool secure) {
    return Theme(
      data: ThemeData(cursorColor: Colors.white),
      child: TextField(
        obscureText: secure,
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
            labelText: placeholder,
            border: new UnderlineInputBorder(
              borderSide: new BorderSide(color: Colors.red),
            ),
            labelStyle: Theme.of(context)
                .textTheme
                .caption
                .copyWith(color: Colors.white, fontSize: 16),
            errorText: null),
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  var signInUsername = TextEditingController();
  var signInPassword = TextEditingController();

  void disposeSignInCredentials() {
    // Clean up the controller when the Widget is disposed
    signInUsername.dispose();
    signInPassword.dispose();
    super.dispose();
  }

  Widget stepDescriptionText(String text) {
    return Text(
      text,
      style: TextStyle(color: appBarTextColor, fontSize: 18),
    );
  }

  String currentNetworkToJoin = "";
  Widget currentStepContent;
  Widget currentStepDescription;

  String networkToJoin = "";
  Color disabledColor = Color.fromRGBO(220, 220, 220, 1);
  Color signInAppbarTextColor;
  Color networkAppbarTextColor;
  Color membershipAppbarTextColor;
  Widget signInContents;
  Widget networkContents;
  Widget allDoneContents;
  bool initialRun = true;

  Future<void> changeSection(int section) async {
    switch (section) {
      case 1:
        currentStepDescription = stepDescriptionText("Sign In");
        currentStepContent = signInContents;
        signInAppbarTextColor = appBarTextColor;
        networkAppbarTextColor = disabledColor;
        membershipAppbarTextColor = disabledColor;
        break;
      case 2:
        currentStepDescription = stepDescriptionText("Network");
        currentStepContent = networkContents;
        signInAppbarTextColor = appBarTextColor;
        networkAppbarTextColor = appBarTextColor;
        membershipAppbarTextColor = disabledColor;
        break;
      case 3:
        currentStepDescription = stepDescriptionText("Membership");
        currentNetworkToJoin = networkToJoin;
        currentStepContent = allDoneContents;
        signInAppbarTextColor = appBarTextColor;
        networkAppbarTextColor = appBarTextColor;
        membershipAppbarTextColor = appBarTextColor;
        break;
      default:
        currentStepDescription = stepDescriptionText("Sign In");
        currentStepContent = signInContents;
        signInAppbarTextColor = appBarTextColor;
        networkAppbarTextColor = disabledColor;
        membershipAppbarTextColor = disabledColor;
        break;
    }
  }

  Future<String> screenDeterminer() async {
    String user = await getCurrentUser();
    if (user != null) return "0";
    user = await getCurrentUserFromWebview();
    if (user != null) return "2";
    return "1";
  }

  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    //NAVIGATE TO HOME IF LOGGED IN
    getCurrentUser().then((user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "/home");
      }
    });

    signInContents = Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Form(
        child: Column(
          children: <Widget>[
            Container(
              width: 270,
              padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: RaisedButton(
                child: const Text('Sign In'),
                textColor: Colors.white,
                color: themeColorButtons,
                elevation: 0.0,
                splashColor: Colors.greenAccent,
                onPressed: () async {
                  Navigator.pushNamed(context, "/webview");
                },
              ),
            )
          ],
        ),
      ),
    );

    networkContents = Container(
      child: Form(
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                child: themedTextField("Network Name", networkField, false),
                width: 270,
              ),
            ),
            Center(
              child: Container(
                width: 270,
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: RaisedButton(
                  child: const Text('Next'),
                  textColor: Colors.white,
                  color: themeColorButtons,
                  elevation: 0.0,
                  splashColor: Colors.greenAccent,
                  onPressed: () async {
                    if (networkField.text.length == 0) {
                      toastMessageBottomShort("Enter a network");
                    } else {
                      showCustomProcessDialog("Please Wait..", context);
                      String username = await getCurrentUserFromWebview();
                      String network = networkField.text;
                      User user = User(username, network);
                      bool result = await firebaseInterface.addNewMember(user);
                      if (result) {
                        bool writeSuccess =
                            await setUserOfflineDetails(username, network);
                        if (writeSuccess)
                          RestartWidget.restartApp(context);
                          //Navigator.pushReplacementNamed(context, "/home");
                        else {
                          toastMessageBottomShort("Error Occurred");
                          Navigator.pop(context);
                        }
                      } else {
                        toastMessageBottomShort("Error Occurred");
                        Navigator.pop(context);
                      }
                    }
                  },
                ),
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                child: Text(
                  "or",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 270,
                child: RaisedButton(
                  child: const Text('Choose From List'),
                  textColor: Colors.white,
                  color: themeColorButtons,
                  elevation: 0.0,
                  splashColor: Colors.greenAccent,
                  onPressed: () async {
                    Navigator.pushNamed(context, '/networks');
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );

    allDoneContents = Container(
      child: Form(
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Text(
                currentNetworkToJoin,
                style: TextStyle(color: appBarTextColor, fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(30, 0, 30, 15),
              child: Text(
                "To create your account you will be required to pay a low fee of \$1, which includes 30 days of sharing privelages. This fee will help to protect your network from non-human and other fradulent activity, and help maintain the Steemit Sentinels infrastructure.",
                style: TextStyle(color: appBarTextColor, fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ),
            RaisedButton(
              child: const Text(
                'Start Membership',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              textColor: Color.fromRGBO(90, 117, 148, 1),
              color: Color.fromRGBO(255, 216, 125, 1),
              elevation: 0.0,
              onPressed: () {
                /*
              getCurrentUser().then((user){
                membership(user.username, context, false);
              }).catchError((onError){
                setState(() {
                  currentScreen = 1;
                });
              });*/
              },
            )
          ],
        ),
      ),
    );

    changeSection(currentScreen);

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.fromLTRB(0, 30, 0, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "Steemit Sentinels",
                style: TextStyle(color: appBarTextColor),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
      body: Scaffold(
        resizeToAvoidBottomPadding: false,
        backgroundColor: themeColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 17),
                child: Row(
                  children: <Widget>[
                    Padding(
                      child: Icon(
                        Icons.account_circle,
                        color: appBarTextColor,
                        size: 17,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    ),
                    Text(
                      "Sign In",
                      style: TextStyle(
                        color: signInAppbarTextColor,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Padding(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: networkAppbarTextColor,
                  size: 16,
                ),
                padding: EdgeInsets.fromLTRB(5, 0, 0, 17),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 17),
                child: Row(
                  children: <Widget>[
                    Padding(
                      child: Icon(
                        Icons.people,
                        color: networkAppbarTextColor,
                        size: 17,
                      ),
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    ),
                    Text(
                      "Network",
                      style: TextStyle(
                        color: networkAppbarTextColor,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Padding(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: membershipAppbarTextColor,
                  size: 16,
                ),
                padding: EdgeInsets.fromLTRB(5, 0, 0, 17),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 0, 17),
                child: Row(
                  children: <Widget>[
                    Padding(
                      child: Icon(Icons.check,
                          color: membershipAppbarTextColor, size: 17),
                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                    ),
                    Text("All Done",
                        style: TextStyle(
                            color: membershipAppbarTextColor, fontSize: 15),
                        textAlign: TextAlign.right),
                  ],
                ),
              ),
            ],
          ),
          elevation: 0,
        ),
        body: Scaffold(
          backgroundColor: themeColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsets.fromLTRB(10, 5, 0, 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[currentStepDescription],
              ),
            ),
            elevation: 0,
          ),
          body: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 100),
              children: <Widget>[currentStepContent],
            ),
          ),
        ) /*,
          bottomNavigationBar: BottomAppBar(
            elevation: 0,
            color: themeColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.fromLTRB(10, 0, 0, 15),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.arrow_back_ios,
                          color: appBarTextColor, size: 18),
                      Text("Previous",
                          style:
                              TextStyle(color: appBarTextColor, fontSize: 18),
                          textAlign: TextAlign.right),
                    ],
                  ),
                ),
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 10, 20),
                    child: Row(
                      children: <Widget>[
                        Text("Next",
                            style:
                                TextStyle(color: appBarTextColor, fontSize: 18),
                            textAlign: TextAlign.right),
                        Icon(Icons.arrow_forward_ios,
                            color: appBarTextColor, size: 18)
                      ],
                    ),)
              ],
            ),
          )*/
            ,
      ),
    );
  }

  void afterFirstLayout(BuildContext context) {
    
  }
}
