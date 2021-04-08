import 'package:dio/dio.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:after_layout/after_layout.dart';
import 'dart:convert';
import '../main.dart';
import '../handler.dart';
import './addfriend.dart';
import './signin.dart';



class Members extends StatefulWidget {
  MembersState createState() => MembersState();
}

int friendsToGetindex = 0;

List<Card> friendsList = [];
/*
Future<Response> getFriends() async {
  UserCredentials currentUser = await getCurrentUser();
  return await dio.post(serverDomain + "myfriends", data: {"usr": currentUser.username, "pge": friendsToGetindex});
}*/

ScrollController activeListScrollController = ScrollController();
ScrollController inactiveListScrollController = ScrollController();
ScrollController friendsListScrollController = ScrollController();

class MembersState extends State<Members> with AfterLayoutMixin<Members>{
  Widget build(BuildContext context) {  
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback=(X509Certificate cert, String host, int port){
        return true;
      };
    };     
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: themeColor,
            leading: FlatButton(
              child: Icon(
                Icons.arrow_back,
                color: appBarTextColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              "Members",
              style: TextStyle(color: appBarTextColor),
            ),
            actions: <Widget>[
              Container(
                width: 30,
                child: IconButton(
                  icon: Icon(
                    Icons.search,
                    color: appBarTextColor,
                  ),
                  onPressed: () {},
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.person_add,
                  color: appBarTextColor,
                ),
                onPressed: () {

                  Navigator.pushNamed(context, '/addfriend');
                  /*
                  Future<void> addMember(String username) async {
                    UserCredentials currentUser = await getCurrentUser();
                    Response response = await dio.post(
                        serverDomain + "newjoinkey",
                        data: {"usr": currentUser.username});
                    String joinKey = response.data;

                    
                    //USE KEY TO CREATE A QR CODE
                  }*/
                },
              )
            ],
            bottom: TabBar(
              indicatorColor: Colors.white,
              tabs: [
                Tab(
                    child: Text("Active",
                        style: TextStyle(color: appBarTextColor))),
                Tab(
                    child: Text("Inactive",
                        style: TextStyle(color: appBarTextColor))),
                Tab(
                    child: Text("Friends",
                        style: TextStyle(color: appBarTextColor)))
              ],
            )),
        body: TabBarView(
          children: <Widget>[
            ListView(
              controller: activeListScrollController,
              children: <Widget>[
                Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const ListTile(
                        leading: Icon(Icons.album),
                        title: Text('The Enchanted Nightingale'),
                        subtitle: Text(
                            'Music by Julie Gable. Lyrics by Sidney Stein.'),
                      ),
                      ButtonTheme.bar(
                        // make buttons use the appropriate styles for cards
                        child: ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: const Text('BUY TICKETS'),
                              onPressed: () {/* ... */},
                            ),
                            FlatButton(
                              child: const Text('LISTEN'),
                              onPressed: () {/* ... */},
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ListView(
              controller: inactiveListScrollController,
              children: <Widget>[],
            ),
            ListView(
              controller: friendsListScrollController,
              children: <Widget>[
                
              ],
            ),
          ],
        ),
      ),
    );
  }
  void afterFirstLayout(BuildContext context) {
    /*
    getFriends().then((friendsList){
      Map<String, dynamic> friends = jsonDecode(friendsList.data);
    });*/
  }  
}
