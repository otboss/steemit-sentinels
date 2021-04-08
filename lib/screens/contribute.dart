import 'dart:async';
import 'dart:io';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import '../handler.dart';
import './signin.dart';
import '../firebase.dart';

class Contribute extends StatefulWidget {
  ContributeState createState() => ContributeState();
}

Future<bool> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: false);
    return true;
  } else {
    return false;
    //throw 'Could not launch $url';
  }
}

class ContributeState extends State<Contribute>
    with AfterLayoutMixin<Contribute> {
  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: appBarTextColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Contribute",
          style: TextStyle(color: appBarTextColor),
        ),
        actions: <Widget>[],
      ),
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
    );
  }

  void afterFirstLayout(BuildContext context) async {
    //LOAD SOME NETWORKS HERE USING FUTURE BUILDER
    try {} catch (err) {}
    //List networks = await firebaseInterface.getNetworks(filter: filter);
  }
}
