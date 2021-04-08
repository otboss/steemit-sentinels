import 'dart:io';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import '../handler.dart';


class AddFriend extends StatefulWidget {
  AddFriendState createState() => AddFriendState();
}

class AddFriendState extends State<AddFriend> with AfterLayoutMixin<AddFriend>{
  String joinKey = "";
  QrImage joinQR = QrImage(
    size: 0,
  );
  String description = "";

  Future<void> generateJoinQr() async {
    await showCustomProcessDialog("Generating QR Code", context,
        dissmissable: true, alignment: TextAlign.center);
    try {
      String currentUser = await getCurrentUser();
      String serverDomain = "";
      Response response = await dio.post(serverDomain + "newjoinkey",
          data: {"usr": currentUser});
      String joinKey = response.data;
      setState(() {
        joinQR = QrImage(
          data: joinKey,
          size: 200,
        );
        description = "Have your friend scan the QR Code shown to add them";
      });
      toastMessageBottomShort("Ready");
    } catch (e) {
      Navigator.pop(context);
      setState(() {
        description = "Could not generate QR Code";
      });     
      print(e); 
      toastMessageBottomShort("Connection error");
    }
  }

  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback=(X509Certificate cert, String host, int port){
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
          "Add Friend",
          style: TextStyle(color: appBarTextColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline, color: appBarTextColor,),
            onPressed: (){
              showAlert("Free Membership", "Your account can qualify for free membership by having two or more active friends", context);
            },
          )
        ],
      ),
      body: Center(
        child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            children: [
              Center(
                child: joinQR
              ),
              Center(
                child: Container(
                  width: 250,
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Text(description, textAlign: TextAlign.center,),
                ),
              ),
            ]),
      ),
    );
  }
  void afterFirstLayout(BuildContext context) {
    generateJoinQr();
  }
}
