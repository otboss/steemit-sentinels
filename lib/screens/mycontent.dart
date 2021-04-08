import 'dart:io';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:after_layout/after_layout.dart';

class MyContent extends StatefulWidget {
  MyContentState createState() => MyContentState();
}

class MyContentState extends State<MyContent> with AfterLayoutMixin<MyContent> {
  ScrollController queueScrollController = new ScrollController();

  Future<bool> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false);
      return true;
    } else {
      return false;
      //throw 'Could not launch $url';
    }
  }

  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    FutureBuilder showRecentUserPosts = FutureBuilder<List>(
      future: firebaseInterface
          .getUserPosts(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20.0),
                children: [
                  Column(
                    children: <Widget>[
                      CircularProgressIndicator(
                        backgroundColor: themeColor,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.blue[300]),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                          child: Text(
                            "Loading Recent Posts..",
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 18),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            );
            break;
          //return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (snapshot.data.length == 0) {
              return Center(
                child: new ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Center(
                      child: Text(
                        "You have no recent posts",
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else {
              List<Widget> recentPostsCards = [];
              List recentPosts = snapshot.data;
              for (var x = 0; x < recentPosts.length; x++) {
                Map<String, dynamic> details =
                    getPostDetails(recentPosts[x]["url"]);
                details["network"] = recentPosts[x]["network"];
                recentPostsCards.add(
                  Card(
                    color: cardColor,
                    child: SizedBox(
                      width: double.infinity,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _launchURL(details["url"]);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                            child: Row(
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Icon(
                                    Icons.event_note,
                                    color: themeColor,
                                    size: 32,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          details["title"],
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey[500]),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        Text(
                                          details["network"],
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[500]),
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              recentPostsCards.add(
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 0),
                ),
              );
              return Container(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: ListView(
                  children: [
                    Column(
                      children: recentPostsCards,
                    ),
                  ],
                ),
              );
            }
        }
      },
    );

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
          "My Content",
          style: TextStyle(color: appBarTextColor),
        ),
      ),
      body: showRecentUserPosts,
    );
  }

  void afterFirstLayout(BuildContext context) {}
}
