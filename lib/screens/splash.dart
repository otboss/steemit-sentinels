import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';
import 'package:after_layout/after_layout.dart';
import 'dart:io';
import '../main.dart';
import './signin.dart';
import '../handler.dart';
import './home.dart';
import './introduction.dart';

class Splash extends StatefulWidget {
  SplashState createState() => SplashState();
}


class SplashState extends State<Splash> with AfterLayoutMixin<Splash> {

  
  Future<int> getNextScreen() async{
    try{
      if(await initialAppRun()){
        await databaseManager.initDb();
        return 1;//INTRO
      }
      String user = await getCurrentUser();
      if (user != null) 
        return 2;//HOME
      else
        return 3;//SIGN IN      
    }
    catch(err){
      print("ERROR OCCURRED WHILE GETTING NEXT SCREEN");
      print("ERROR OCCURRED WHILE GETTING NEXT SCREEN");
      print("ERROR OCCURRED WHILE GETTING NEXT SCREEN");
      await databaseManager.initDb();
      return 1;
    }

  }


  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    FutureBuilder nextScreen = FutureBuilder<int>(
      future: getNextScreen(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
            break;
          case ConnectionState.waiting:
            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              print('Error: ${snapshot.error}');
              print('Error: ${snapshot.error}');
              print('Error: ${snapshot.error}');
              print("THE SNAPSHOT HAD AN ERROR: ");
              print("THE SNAPSHOT HAD AN ERROR: ");
              print("THE SNAPSHOT HAD AN ERROR: ");
              print(snapshot.data);
              return Introduction();
            } else {
              print(snapshot.data);
              if(snapshot.data == 1){
                return Introduction();
              }
              if(snapshot.data == 2)
                return Home();
              if(snapshot.data == 3)
                return SignIn();
            }
        }
      }, 
    );

    return SplashScreen(
      seconds: 6,
      navigateAfterSeconds: nextScreen,
      title: new Text('',
      style: new TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20.0
      ),),
      image: Image(
        image: AssetImage('assets/flat_logo.png'),
        fit: BoxFit.scaleDown,
      ),
      backgroundColor: themeColor,
      styleTextUnderTheLoader: new TextStyle(),
      photoSize: 40.0,
      onClick: ()=>print("Flutter Egypt"),
      loaderColor: Colors.white
    );
    /*
    Scaffold(
      body: Container(
        color: themeColor,
        child: Center(
          child: new ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            children: [
              Center(
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Text(
                        "Making huge gains from this service? It's completely free! but unfortunately costs to be maintained. Thanks to contributions from users like you it is kept afloat. A small contribution can carry it a far way!",
                        style: TextStyle(
                          color: appBarTextColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                    ),
                    RaisedButton(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                        child: Text('Donate'),
                      ), 
                      textColor: Color.fromRGBO(90, 117, 148, 1),
                      color: Color.fromRGBO(255, 216, 125, 1),
                      elevation: 0.0,
                      splashColor: Colors.greenAccent,
                      onPressed: () async {
                        _launchURL(
                            "https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=otsurfer6@gmail.com&lc=US&item_name=Towards%20Maintenance&no_note=0&cn=&currency_code=USD&bn=PP-DonationsBF:btn_donateCC_LG.gif:NonHosted");
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );*/
  }

  void afterFirstLayout(BuildContext context) async {
    //LOAD SOME NETWORKS HERE USING FUTURE BUILDER
    try {} catch (err) {}
    //List networks = await firebaseInterface.getNetworks(filter: filter);
  }
}
