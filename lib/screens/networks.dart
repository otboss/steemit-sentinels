import 'dart:async';
import 'dart:io';
import '../main.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';
import './signin.dart';

class NetworkList extends StatefulWidget {
  NetworkListState createState() => NetworkListState();
}

class NetworkListState extends State<NetworkList>
    with AfterLayoutMixin<NetworkList> {
  ScrollController queueScrollController = new ScrollController();
  String filter = "";
  List<Widget> networkCards = [];
  TextEditingController queryField = TextEditingController();

  Widget generateNetworkCard(String networkName, int memberCount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Card(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                networkField.text = networkName;
              });
              Navigator.pop(context);
            },
            child: SizedBox(
              width: double.infinity,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Icon(
                        Icons.language,
                        color: themeColor,
                        size: 32,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              networkName,
                              style: TextStyle(
                                  fontSize: 18, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<List<Widget>> loadNetworks() async {
    try {
      Map<String, int> networks = await firebaseInterface.getNetworks(filter);
      List<String> nKeys = networks.keys.toList();
      networkCards = [];
      nKeys.sort();
      nKeys.forEach((network) {
          networkCards.add(
            generateNetworkCard(
              network,
              networks[network],
            ),
          );
      });
    } catch (err) {
      print(err);
      return networkCards;
    }
    return networkCards;
  }

  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    FutureBuilder networksFutureBuilder = FutureBuilder<List<Widget>>(
      future: loadNetworks(),
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text(
              'Waiting..',
              style: TextStyle(color: Colors.grey[400]),
            );
          case ConnectionState.active:
          case ConnectionState.waiting:
            //SHOW LOADING NETWORKS
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
                            "Loading Networks..",
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
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Center(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Column(
                      children: <Widget>[
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: Text(
                              "An error was encountered",
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 18),
                            ),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 7, 0, 0),
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  networkCards = [];
                                });
                              },
                              child: Text(
                                "Retry",
                                style: TextStyle(
                                  color: Colors.blue[300],
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              );
            } else {
              if (snapshot.data.length > 0) {
                return ListView(
                  padding: EdgeInsets.fromLTRB(0, 3, 0, 0),
                  controller: queueScrollController,
                  children: snapshot.data,
                );
              } else {
                return Center(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(20.0),
                    children: [
                      Column(
                        children: <Widget>[
                          Icon(
                            Icons.error_outline,
                            color: Colors.grey[400],
                            size: 50,
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(0, 7, 0, 10),
                              child: Text(
                                "No results found",
                                style: TextStyle(
                                    color: Colors.grey[400], fontSize: 18),
                              ),
                            ),
                          ),
                          Center(
                            child: FlatButton(
                              onPressed: () {
                                setState(() {
                                  networkCards = [];
                                });
                              },
                              child: Text(
                                "Retry",
                                style: TextStyle(
                                  color: Colors.blue[300],
                                ),
                              ),
                            ) ,
                          )                         
                        ],
                      ),
                    ],
                  ),
                );
              }
            }
        }
        return null; // unreachable
      },
    );

    queueScrollController.addListener(() {
      if (queueScrollController.position.pixels ==
          queueScrollController.position.maxScrollExtent) {
        //SEND ANOTHER REQUEST
        toastMessageBottomShort("End of List");
      }
    });
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
          "Choose Network",
          style: TextStyle(color: appBarTextColor),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            color: appBarTextColor,
            onPressed: () async {
              //SHOW DIALOG FOR SEARCH QUERY
              //showSearchNetworkDialog();
              showPrompt(
                "Enter Search Query",
                context,
                queryField,
                () async {
                  setState(
                    () {
                      networkCards = [];
                      filter = queryField.text;
                      queryField.text = "";
                    },
                  );
                },
              );
            },
          )
        ],
      ),
      body: networksFutureBuilder,
    );
  }

  void afterFirstLayout(BuildContext context) async {
    //LOAD SOME NETWORKS HERE USING FUTURE BUILDER
    try {} catch (err) {}
    //List networks = await firebaseInterface.getNetworks(filter: filter);
  }
}
