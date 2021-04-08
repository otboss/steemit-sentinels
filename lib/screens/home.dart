import 'dart:async';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:local_notifications/local_notifications.dart';
import 'package:firebase_admob/firebase_admob.dart';
import '../main.dart';
import '../handler.dart';
import 'package:flutter/scheduler.dart';

class Home extends StatefulWidget {
  LoadHome createState() => new LoadHome();
}

class MemberDetails {
  String username;
  MembershipStatus status;
  MemberDetails(String username, MembershipStatus status) {
    this.username = username;
    this.status = status;
  }
}

ScrollController queueScrollController = new ScrollController();
int queueFetchindex = 0;

Color accountOptionsColor = Colors.grey[350];
Color accountOptionsBorderColor = Color.fromRGBO(240, 240, 240, 1);
Color syncArrowColor = Color.fromRGBO(255, 232, 10, 1);
var reloader = DateTime.now().millisecondsSinceEpoch;
const appId = "ca-app-pub-6322263789727988~2080678137";
const adUnitId = "ca-app-pub-6322263789727988/8606558031";
const rewardAdUnitId = "ca-app-pub-6322263789727988/2927934918";

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>['flutterio', 'beautiful apps'],
  contentUrl: 'https://flutter.io',
  childDirected: false,
  testDevices: <String>[
    "3EC875173F10A1A0A8A54CAB2B5839D7"
  ], // Android emulators are considered test devices
);

Future<bool> showAd() {
  BottomAppBar(
    elevation: 0,
    color: Colors.grey[200],
    child: Container(
      height: 50,
      child: Text(""),
    ),
  );
}

FutureBuilder setPaddingForAd;

BannerAd myBanner = BannerAd(
  adUnitId: adUnitId,
  size: AdSize.smartBanner,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("BannerAd event is $event");
    setPaddingForAd = FutureBuilder<MobileAdEvent>(
      future: Future.value(event),
      builder: (BuildContext context, AsyncSnapshot<MobileAdEvent> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
            return BottomAppBar(
              elevation: 0,
              color: Colors.grey[200],
              child: Container(
                height: 0,
                child: Text(""),
              ),
            );
            break;
          case ConnectionState.waiting:
            return BottomAppBar(
              elevation: 0,
              color: Colors.grey[200],
              child: Container(
                height: 0,
                child: Text(""),
              ),
            );
            break;
          case ConnectionState.done:
            if (snapshot.hasError) {
              return BottomAppBar(
                elevation: 0,
                color: Colors.grey[200],
                child: Container(
                  height: 0,
                  child: Text(""),
                ),
              );
            } else {
              print("THE RESPONSE FOR THE BOTTOM BANNER AD IS: ");
              print(snapshot.data.toString());
              print("THE RESPONSE FOR THE BOTTOM BANNER AD IS: ");
              print(snapshot.data.toString());
              print("THE RESPONSE FOR THE BOTTOM BANNER AD IS: ");
              print(snapshot.data.toString());
              print("THE RESPONSE FOR THE BOTTOM BANNER AD IS: ");
              print(snapshot.data.toString());
              if (snapshot.data == MobileAdEvent.loaded) {
                return BottomAppBar(
                  elevation: 0,
                  color: Colors.grey[200],
                  child: Container(
                    height: 50,
                    child: Text(""),
                  ),
                );
              } else {
                return BottomAppBar(
                  elevation: 0,
                  color: Colors.grey[200],
                  child: Container(
                    height: 0,
                    child: Text(""),
                  ),
                );
              }
            }
        } // unreachable
      },
    );
  },
);

/*
InterstitialAd myInterstitial = InterstitialAd(
  // Replace the testAdUnitId with an ad unit id from the AdMob dash.
  // https://developers.google.com/admob/android/test-ads
  // https://developers.google.com/admob/ios/test-ads
  adUnitId: InterstitialAd.testAdUnitId,
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    print("InterstitialAd event is $event");
  },
);

MobileAdEvent adStatus;*/

ScrollController messagesScrollController = new ScrollController();
int messagesFetchindex = 0;

ScrollController accountScrollController = new ScrollController();
int accountFetchindex = 0;

String currentUserImageURL = "";

Future<bool> _launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url, forceWebView: false);
    return true;
  } else {
    return false;
    //throw 'Could not launch $url';
  }
}

class NetworkSharedContent {
  String title;
  String author;
  String url;
  ContentStatus status;
  Widget statusIndicator;
  Widget card;
  AnimationController animationController;

  NetworkSharedContent(
    String title,
    String author,
    String url,
    animationController,
    ContentStatus status,
  ) {
    this.title = title;
    this.author = author;
    this.url = url;
    this.status = status;
    this.animationController = animationController;
    if (status == ContentStatus.complete) {
      this.statusIndicator = this.statusIndicator = Icon(
        Icons.done,
        color: themeColor,
        size: 30,
      );
    } else {
      this.statusIndicator = AnimatedBuilder(
        animation: animationController,
        child: new Container(
          height: 30,
          width: 30,
          child: Icon(
            Icons.sync,
            color: syncArrowColor,
            size: 30,
          ),
        ),
        builder: (BuildContext context, Widget _widget) {
          return new Transform.rotate(
            angle: animationController.value * -6.3,
            child: _widget,
          );
        },
      );
    }

    this.card = Card(
      color: cardColor,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _launchURL(this.url);
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
                      )),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            this.title,
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            this.author,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: this.statusIndicator,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void setStatus(status) {
    switch (status) {
      case ContentStatus.pending:
        this.statusIndicator = AnimatedBuilder(
          animation: animationController,
          child: new Container(
            height: 30,
            width: 30,
            child: Icon(
              Icons.sync,
              color: syncArrowColor,
              size: 30,
            ),
          ),
          builder: (BuildContext context, Widget _widget) {
            return new Transform.rotate(
              angle: animationController.value * -6.3,
              child: _widget,
            );
          },
        );
        break;
      case ContentStatus.complete:
        this.statusIndicator = Icon(
          Icons.done,
          color: themeColor,
          size: 30,
        );
        break;
      case ContentStatus.error:
        this.statusIndicator = Icon(
          Icons.sync_problem,
          color: errorColor,
          size: 30,
        );
        break;
    }
    this.card = Card(
      color: cardColor,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _launchURL(this.url);
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
                      )),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            this.title,
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            this.author,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 15),
                    child: this.statusIndicator,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    this.status = status;
  }
}

class MembershipInfo {
  String username;
  MembershipStatus status;
  Widget indicator;
  Widget card;

  MembershipInfo(String username, MembershipStatus status) {
    this.username = username;
    this.status = status;
    switch (this.status) {
      case MembershipStatus.active:
        this.indicator = Icon(
          Icons.person,
          color: themeColor,
        );
        break;
      case MembershipStatus.inactive:
        this.indicator = Icon(
          Icons.person_outline,
          color: themeColor,
        );
        break;
    }
    card = Card(
      color: cardColor,
      child: SizedBox(
        width: double.infinity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _launchURL("https://steemit.com/@" + username);
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                    child: this.indicator,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            this.username,
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[500]),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
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
    );
  }

  MembershipStatus getStatus() {
    return this.status;
  }

  String getUsername() {
    return this.username;
  }
}

class LoadHome extends State<Home> with TickerProviderStateMixin {
  TextEditingController newSharedContentController = TextEditingController();

  Color searchIconColor = appBarTextColor;
  bool searchActive = false;

  TextEditingController filterDialogController = TextEditingController();

  AnimationController animationController;

  int totalMembers = 0;
  bool appConnectedToServerSinceLaunch = false;
  List<Widget> pendingPostsCardsWidgetArray = [];
  List<Widget> likedPostsCardsWidgetArray = [];
  List<Widget> activeMembersCardsWidgetArray = [];
  List<Widget> inactiveMembersCardsWidgetArray = [];
  Map<String, dynamic> sharedPostsCards = {};
  Map<String, dynamic> membersCards = {};

  String getFilter() {
    String filter;
    try {
      if (filterDialogController.text != null)
        filter = filterDialogController.text;
      else
        filter = "";
    } catch (err) {
      return "";
    }
    return filter;
  }

  Future<int> displayInitialLikedPostsCards() async {
    List initialLikedPosts = await databaseManager.getLikedPosts("", []);
    int totalLikedPosts = await databaseManager.getTotalLikedPosts();
    if (initialLikedPosts.length == 0) return totalLikedPosts;
    List sharedPostsCardsArr = sharedPostsCards.keys.toList();
    List<Card> results = [];
    for (var x = 0; x < sharedPostsCardsArr.length; x++) {
      NetworkSharedContent obj =
          sharedPostsCards[sharedPostsCardsArr[x]]["object"];
      if (obj.status == ContentStatus.complete) {
        results.add(obj.card);
      }
    }
    if (results.length == 0) {
      //INITIAL RUN
      likedPostsCardsWidgetArray = [];
      for (var x = 0; x < initialLikedPosts.length; x++) {
        Map details = getPostDetails(initialLikedPosts[x]["url"]);
        var titleToLowerCase = details["title"].toLowerCase();
        var filterToLowerCase = getFilter().toLowerCase();
        if (titleToLowerCase.indexOf(filterToLowerCase) == -1) continue;
        NetworkSharedContent obj = NetworkSharedContent(
            details["title"],
            details["author"],
            details["url"],
            animationController,
            ContentStatus.complete);
        likedPostsCardsWidgetArray.add(obj.card);
        sharedPostsCards[details["url"]] = {"object": obj, "card": obj.card};
      }
      return totalLikedPosts;
    }
    return totalLikedPosts;
  }

  Future<List<Widget>> displayInitialActiveMembers() async {
    if (await isConnected()) {
      try {
        Map newMembers = await firebaseInterface.getMembers();
        List newMembersUsernames = newMembers.keys.toList();
        for (var x = 0; x < newMembersUsernames.length; x++) {
          try {
            if (isMemberActive(
                newMembers[newMembersUsernames[x]]["lastActive"]))
              await databaseManager.saveMember(
                  newMembersUsernames[x], MembershipStatus.active);
            else
              await databaseManager.saveMember(
                  newMembersUsernames[x], MembershipStatus.inactive);
          } catch (err) {
            print("ERROR OCCURRED DURING THE DISPLAYING PROCESS");
            print("ERROR OCCURRED DURING THE DISPLAYING PROCESS");
            print("ERROR OCCURRED DURING THE DISPLAYING PROCESS");
            print(err);
          }
        }
      } catch (err) {
        //NETWORK ERROR
      }
    }
    List members = await databaseManager.getMembers("", []);
    for (var x = 0; x < members.length; x++) {
      var filterToLowerCase = getFilter().toLowerCase();
      var usernameToLoweCase = members[x]["username"].toLowerCase();
      if (usernameToLoweCase.indexOf(filterToLowerCase) == -1) continue;
      MembershipInfo obj;
      if (MembershipStatus.active.toString() == members[x]["status"])
        obj = MembershipInfo(members[x]["username"], MembershipStatus.active);
      else
        continue;
      if (membersCards[obj.username] != null) continue;
      activeMembersCardsWidgetArray.add(obj.card);
      membersCards[obj.username] = {"object": obj, "card": obj.card};
    }
    return activeMembersCardsWidgetArray;
  }

  Future<List<Widget>> displayInitialInactiveMembers() async {
    if (await isConnected()) {
      try {
        Map newMembers = await firebaseInterface.getMembers();
        List newMembersUsernames = newMembers.keys.toList();
        for (var x = 0; x < newMembersUsernames.length; x++) {
          try {
            if (isMemberActive(
                newMembers[newMembersUsernames[x]]["lastActive"]))
              await databaseManager.saveMember(
                  newMembersUsernames[x], MembershipStatus.active);
            else
              await databaseManager.saveMember(
                  newMembersUsernames[x], MembershipStatus.inactive);
          } catch (err) {
            print(err);
          }
        }
      } catch (err) {
        //NETWORK ERROR
      }
    }
    List members = await databaseManager.getMembers("", []);
    for (var x = 0; x < members.length; x++) {
      var filterToLowerCase = getFilter().toLowerCase();
      var usernameToLoweCase = members[x]["username"].toLowerCase();
      if (usernameToLoweCase.indexOf(filterToLowerCase) == -1) continue;
      MembershipInfo obj;
      if (MembershipStatus.inactive.toString() == members[x]["status"])
        obj = MembershipInfo(members[x]["username"], MembershipStatus.inactive);
      else
        continue;
      if (membersCards[obj.username] != null) continue;
      inactiveMembersCardsWidgetArray.add(obj.card);
      membersCards[obj.username] = {"object": obj, "card": obj.card};
    }
    return inactiveMembersCardsWidgetArray;
  }

  Future<bool> getMoreLikedPostsCards() async {
    List<String> urls = [];
    List<String> keys = sharedPostsCards.keys.toList();
    for (var x = 0; x < keys.length; x++) {
      var obj = sharedPostsCards[keys[x]]["object"];
      if (obj.status == ContentStatus.complete) {
        urls.add(keys[x]);
      }
    }
    if (urls.length > 0) {
      List<Card> results = [];
      List newLikedPosts =
          await databaseManager.getLikedPosts(getFilter(), urls);
      for (var x = 0; x < newLikedPosts.length; x++) {
        var url = newLikedPosts[x]["url"];
        Map details = getPostDetails(url);
        NetworkSharedContent obj = NetworkSharedContent(
            details["title"],
            details["author"],
            details["url"],
            animationController,
            ContentStatus.complete);
        results.add(obj.card);
      }
      setState(() {
        likedPostsCardsWidgetArray = likedPostsCardsWidgetArray + results;
      });
    }
  }

  Future<int> getTotalMembers() async {
    int count = await databaseManager.getMembersCount();
    totalMembers = count;
    return count;
  }

  Future<bool> preparePendingContent(List newPosts) async {
    if (pendingPostsCardsWidgetArray.length >= maxNumberOfNewPosts)
      return false;
    print("A TOTAL OF " + newPosts.length.toString() + " UNLIKED POSTS");
    print("A TOTAL OF " + newPosts.length.toString() + " UNLIKED POSTS");
    print("A TOTAL OF " + newPosts.length.toString() + " UNLIKED POSTS");
    print("LIKING NEW POSTS");
    print("LIKING NEW POSTS");
    print(newPosts);
    for (var x = 0; x < newPosts.length; x++) {
      print("PREPARING POST : " + x.toString() + "/7");
      if (getPostDetails(newPosts[x]) == null) continue;
      print("PREPARING POST : " + x.toString() + "/7");
      try {
        Map<String, String> details = getPostDetails(newPosts[x]);
        NetworkSharedContent newPostCard = NetworkSharedContent(
            details["title"],
            details["author"],
            details["url"],
            animationController,
            ContentStatus.pending);
        if (sharedPostsCards[details["url"]] == null)
          pendingPostsCardsWidgetArray.add(newPostCard.card);
        sharedPostsCards[details["url"]] = {
          "object": newPostCard,
          "card": newPostCard.card
        };
      } catch (err) {
        print(err);
        print(err);
        print(err);
        print(err);
        continue;
      }
    }
    return true;
  }

  Future<void> loadPendingContent() async {
    if (await initialAppRunForPostsGetAppCrash() == true) {
      await writeInitialFileForPostsGetAppCrash();
      RestartWidget.restartApp(context);
    }
    await LocalNotifications.createNotification(
      title: "Steemit Sentinels",
      content: "Watching for new posts..",
      id: 0,
      androidSettings: new AndroidSettings(
          priority: AndroidNotificationPriority.HIGH, isOngoing: true),
    );
    bool currentUserConnected = false;
    while (true) {
      try {
        List newPosts = await firebaseInterface.getNewPosts();
        if (currentUserConnected == false) {
          refreshMembers();
          currentUserConnected = true;
        }
        print("THE NEW POSTS ARE: ");
        print(newPosts);
        print("THE NEW POSTS ARE: ");
        print(newPosts);
        for (var x = newPosts.length - 1; x > -1; x--) {
          if (getPostDetails(newPosts[x]) == null) newPosts.removeAt(x);
        }
        await preparePendingContent(newPosts);
        try {
          await Future.delayed(Duration(seconds: 3));
          setState(() {
            reloader = DateTime.now().millisecondsSinceEpoch;
            pendingPostsCardsWidgetArray = pendingPostsCardsWidgetArray;
          });
        } catch (err) {
          print("ERROR WHILE SETTING STATE");
          print(err);
          print(err);
          print(err);
        }
        print("SEGMENT 1 COMPLETE");
        print("SEGMENT 1 COMPLETE");
        for (var x = 0; x < newPosts.length; x++) {
          try {
            Map<String, String> details = getPostDetails(newPosts[x]);
            print("NOW LIKING POST " + details["url"]);
            print("NOW LIKING POST " + details["url"]);
            print("NOW LIKING POST " + details["url"]);
            print("NOW LIKING POST " + details["url"]);
            print("NOW LIKING POST " + details["url"]);
            int success = await likePost(details["url"]);
            while (success == 2) {
              print("CONNETION ERROR");
              print("UNABLE TO LIKE POST");
              print("RETRYING IN 4s..");
              Future.delayed(Duration(seconds: 4));
              success = await likePost(details["url"]);
            }
            if (success == -1) {
              //REBUILD PENDING POSTS WIDGET ARRAY
              print("INVALID POST DETECTED");
              print("INVALID POST DETECTED");
              print("INVALID POST DETECTED");
              print("INVALID POST DETECTED");
              print("INVALID POST DETECTED");
              sharedPostsCards[details["url"]]["object"]
                  .setStatus(ContentStatus.error);
              List sharedPostsCardsKeys = sharedPostsCards.keys.toList();
              pendingPostsCardsWidgetArray = [];
              for (var x = 0; x < sharedPostsCardsKeys.length; x++) {
                if (sharedPostsCards[sharedPostsCardsKeys[x]]["object"]
                        .status ==
                    ContentStatus.pending)
                  pendingPostsCardsWidgetArray.add(
                      sharedPostsCards[sharedPostsCardsKeys[x]]["object"].card);
              }
              String network = await getCurrentNetwork();
              await databaseManager.savePost(
                  details["url"], network, ContentStatus.error);
            } else if (success == 0) {
              sharedPostsCards[details["url"]]["object"]
                  .setStatus(ContentStatus.error);
              //REBUILD PENDING POSTS WIDGET ARRAY
              List sharedPostsCardsKeys = sharedPostsCards.keys.toList();
              pendingPostsCardsWidgetArray = [];
              for (var x = 0; x < sharedPostsCardsKeys.length; x++) {
                if (sharedPostsCards[sharedPostsCardsKeys[x]]["object"]
                        .status ==
                    ContentStatus.pending)
                  pendingPostsCardsWidgetArray.add(
                      sharedPostsCards[sharedPostsCardsKeys[x]]["object"].card);
              }
              String network = await getCurrentNetwork();
              await databaseManager.savePost(
                  details["url"], network, ContentStatus.error);
            } else {
              print("POST " + details["url"] + " LIKED SUCCESSFULLY");
              print("POST " + details["url"] + " LIKED SUCCESSFULLY");
              print("POST " + details["url"] + " LIKED SUCCESSFULLY");
              print("POST " + details["url"] + " LIKED SUCCESSFULLY");
              print("POST " + details["url"] + " LIKED SUCCESSFULLY");
              sharedPostsCards[details["url"]]["object"]
                  .setStatus(ContentStatus.complete);
              String network = await getCurrentNetwork();
              await databaseManager.savePost(
                  details["url"], network, ContentStatus.complete);
              //REBUILD PENDING POSTS WIDGET ARRAY
              List sharedPostsCardsKeys = sharedPostsCards.keys.toList();
              pendingPostsCardsWidgetArray = [];
              for (var x = 0; x < sharedPostsCardsKeys.length; x++) {
                if (sharedPostsCards[sharedPostsCardsKeys[x]]["object"]
                        .status ==
                    ContentStatus.pending)
                  pendingPostsCardsWidgetArray.add(
                      sharedPostsCards[sharedPostsCardsKeys[x]]["object"].card);
              }
              Card completeCard = NetworkSharedContent(
                      details["title"],
                      details["author"],
                      details["url"],
                      animationController,
                      ContentStatus.complete)
                  .card;
              likedPostsCardsWidgetArray.add(completeCard);
            }
          } catch (err) {
            print(err);
            print(err);
            print(err);
            print(err);
          }
          setState(() {
            reloader = DateTime.now().millisecondsSinceEpoch; //x+20;
            pendingPostsCardsWidgetArray = pendingPostsCardsWidgetArray;
            likedPostsCardsWidgetArray = likedPostsCardsWidgetArray;
          });
          await flutterWebviewPlugin.close();
          print("WEBVIEW CLOSED!");
          print("WEBVIEW CLOSED!");
          print("WEBVIEW CLOSED!");
          firebaseInterface.updateLastActive();
          Future.delayed(Duration(seconds: 4));
        }
      } catch (err) {
        print("ERROR ON home.dart: ");
        print(err);
        print("ERROR ON home.dart: " + err.toString());
        print("ERROR ON home.dart: " + err.toString());
        print("ERROR ON home.dart: " + err.toString());
        print("ERROR ON home.dart: " + err.toString());
        //exit(0);
      }
      Future.delayed(Duration(seconds: 15));
    }
  }

  Future<bool> loadUpvotedContent() async {
    //OPEN SQLITE DATABASE AND DISPLAY CONTENTS ON SCREEN
    List<Map<String, dynamic>> likedPosts = await databaseManager.getLikedPosts(
        getFilter(), sharedPostsCards.keys.toList());
    List<Widget> result = [];
    for (var x = 0; x < likedPosts.length; x++) {
      if (sharedPostsCards[likedPosts[x]["url"]] == null) {
        Map<String, String> postInfo = getPostDetails(likedPosts[x]["url"]);
        NetworkSharedContent content = NetworkSharedContent(
            postInfo["title"],
            postInfo["author"],
            postInfo["url"],
            animationController,
            ContentStatus.complete);
        sharedPostsCards[likedPosts[x]["url"]] = {
          "object": content,
          "card": content.card
        };
        result.add(content.card);
      }
    }
    likedPostsCardsWidgetArray += result;
    return true;
  }

  //USES GLOBAL OBJECT 'membersCards'
  Future<bool> loadMembers() async {
    try {
      //LOADS RESULTS OFFLINE
      List<Map<String, dynamic>> savedMembers = await databaseManager
          .getMembers(getFilter(), membersCards.keys.toList());
      for (var x = 0; x < savedMembers.length; x++) {
        MembershipStatus status = MembershipStatus.inactive;
        if (savedMembers[x]["status"] == MembershipStatus.active.toString())
          status = MembershipStatus.active;
        MembershipInfo info = MembershipInfo(
          savedMembers[x]["username"],
          status,
        );
        membersCards[savedMembers[x]["username"]] = {
          "object": info,
          "card": info.card
        };
      }
      activeMembersCardsWidgetArray = [];
      inactiveMembersCardsWidgetArray = [];
      List savedMembersKeys = membersCards.keys.toList();
      List<Widget> activeMembersCards = [];
      List<Widget> inactiveMembersCards = [];
      for (var x = 0; x < savedMembersKeys.length; x++) {
        if (membersCards[savedMembersKeys[x]]["object"].status ==
            MembershipStatus.active)
          activeMembersCards.add(membersCards[savedMembersKeys[x]]["card"]);
        else
          inactiveMembersCards.add(membersCards[savedMembersKeys[x]]["card"]);
      }
      activeMembersCardsWidgetArray = activeMembersCards;
      inactiveMembersCardsWidgetArray = inactiveMembersCards;
    } catch (err) {
      print(err);
    }
    return true;
  }

  Future<bool> refreshMembers() async {
    if (await isConnected()) {
      try {
        //LOAD FIREBASE RESULTS FIRST
        Map members = await firebaseInterface.getMembers();
        List usernames = members.keys.toList();
        for (var x = 0; x < usernames.length; x++) {
          MembershipStatus status = MembershipStatus.inactive;
          try {
            if (isMemberActive(members[usernames[x]]["lastActive"]))
              status = MembershipStatus.active;
          } catch (err) {
            status = MembershipStatus.inactive;
          }
          await databaseManager.saveMember(usernames[x], status);
        }
      } catch (err) {
        //NETWORK UNAVALIABLE
      }
    } else {
      toastMessageBottomShort("Network Error");
    }

    try {
      //LOADS RESULTS OFFLINE
      List<Map<String, dynamic>> savedMembers =
          await databaseManager.getMembers(getFilter(), []);
      membersCards = {};
      for (var x = 0; x < savedMembers.length; x++) {
        MembershipStatus status = MembershipStatus.inactive;
        if (savedMembers[x]["status"] == MembershipStatus.active.toString())
          status = MembershipStatus.active;
        MembershipInfo info = MembershipInfo(
          savedMembers[x]["username"],
          status,
        );
        membersCards[savedMembers[x]["username"]] = {
          "object": info,
          "card": info.card
        };
      }
      activeMembersCardsWidgetArray = [];
      inactiveMembersCardsWidgetArray = [];
      List savedMembersKeys = membersCards.keys.toList();
      List<Widget> activeMembersCards = [];
      List<Widget> inactiveMembersCards = [];
      for (var x = 0; x < savedMembersKeys.length; x++) {
        if (membersCards[savedMembersKeys[x]]["object"].status ==
            MembershipStatus.active)
          activeMembersCards.add(membersCards[savedMembersKeys[x]]["card"]);
        else
          inactiveMembersCards.add(membersCards[savedMembersKeys[x]]["card"]);
      }
      activeMembersCardsWidgetArray = activeMembersCards;
      inactiveMembersCardsWidgetArray = inactiveMembersCards;
    } catch (err) {
      print(err);
    }
    return true;
  }

  void globalFilter(bool mode) {
    setState(() {
      if (!mode) {
        filterDialogController.text = "";
        searchIconColor = appBarTextColor;
        searchActive = false;
      } else {
        searchIconColor = errorColor;
        searchActive = true;
        activeMembersCardsWidgetArray = [];
        inactiveMembersCardsWidgetArray = [];
        likedPostsCardsWidgetArray = [];
        sharedPostsCards = {};
        membersCards = {};
      }
    });
  }

  int membersBottomNavigationBarIndex = 0;

  Widget searchIcon = Icon(Icons.search, size: 22, color: appBarTextColor);
  String currentUser = "";
  String currentNetwork = "";

  Future<String> getAccountInformation() async {
    try {
      String user = await getCurrentUser();
      String network = await getCurrentNetwork();
      return user + "\n" + network;
    } catch (err) {
      return null;
    }
  }

  String activeMemberCountIndicator = "0";
  String inactiveMemberCountIndicator = "0";

  /*
  Future<bool> updateMembersCountIndicators() async{
    int totalActive = await databaseManager.getTotalActiveMembers();
    int totalInactive = await databaseManager.getTotalInactiveMembers();
    activeMemberCountIndicator = totalActive.toString();
    inactiveMemberCountIndicator = totalInactive.toString();
    return true;
  }*/

  @override
  void initState() {
    Future<void> showConnectionError() async {
      try {
        await firebaseInterface.getMembers();
        if (await isConnected() == false)
          toastMessageBottomShort("Network Unavaliable");
      } catch (err) {
        //NETWORK ERROR
        toastMessageBottomShort("Network Unavaliable");
      }
    }

    showConnectionError();
    loadPendingContent();

    try {
      myBanner
        ..load()
        ..show(
          anchorOffset: 0.0,
          anchorType: AnchorType.bottom,
        ).then((res) {
          setState(() {
            reloader = DateTime.now().millisecondsSinceEpoch;
            setPaddingForAd = setPaddingForAd;
          });
        });
    } catch (err) {
      print("ERROR WHILE DISPLAYING AD");
      print(err);
    }
    RewardedVideoAd.instance.listener = (RewardedVideoAdEvent event,
        {String rewardType, int rewardAmount}) async {
      if (event == RewardedVideoAdEvent.rewarded) {
        int status =
            await firebaseInterface.newPost(newSharedContentController.text);
        if (status == 1) toastMessageBottomShort("Shared Successfully");
        if (status == 0) toastMessageBottomShort("Error Occurred");
        if (status == -1) toastMessageBottomShort("Already Shared");
        if (status == -2) toastMessageBottomShort("Connection Error");
      }
    };

    SchedulerBinding.instance
        .addPostFrameCallback((_) => firebaseInterface.getLatestVersion().then(
              (latestBuild) async {
                if (currentVersion != latestBuild) {
                  Widget alert = AlertDialog(
                    title: Text("Update App"),
                    content: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: ListBody(
                          children: <Widget>[
                            Text(
                                "A new version is available. Please update to continue using this app"),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child:
                            Text("OK", style: TextStyle(color: materialGreen)),
                        onPressed: () {
                          exit(0);
                        },
                      )
                    ],
                  );
                  showDialog(
                      context: context,
                      child: alert,
                      barrierDismissible: false);
                  await Future.delayed(Duration(seconds: 15));
                  exit(0);
                }
              },
            ));

    super.initState();
  }

  Widget build(BuildContext context) {
    dio.onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };

    Widget listviewPlaceholder = Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Text(
            "Nothing to Show Here",
            style: TextStyle(
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );

    FutureBuilder loadAccountInformation = FutureBuilder<String>(
      future: getAccountInformation(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
            break;
          case ConnectionState.waiting:
            return Column(
              children: <Widget>[
                CircularProgressIndicator(
                  backgroundColor: themeColor,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              ],
            );
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                children: <Widget>[
                  /*
                          Center(
                            child:                           Container(
                            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                            child: Container(
                                width: 70,
                                height: 70,
                                decoration: new BoxDecoration(
                                    border: new Border.all(
                                        color: appBarTextColor)),
                                child: Image.network(currentUserImageURL),          
                              ),
                            )
                          ),*/
                  Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 3, 0, 5),
                      child: Text(
                        snapshot.data.split("\n")[0],
                        style: TextStyle(color: appBarTextColor, fontSize: 18),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Text(
                        snapshot.data.split("\n")[1],
                        style: TextStyle(color: appBarTextColor, fontSize: 16),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ],
              );
            }
        } // unreachable
      },
    );

    FutureBuilder showInitialPosts = FutureBuilder<int>(
      future: displayInitialLikedPostsCards(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              children: likedPostsCardsWidgetArray,
            );
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (likedPostsCardsWidgetArray.length == 0) {
              return listviewPlaceholder;
            }
            if (snapshot.data > likedPostsCardsWidgetArray.length) {
              return Column(
                children: likedPostsCardsWidgetArray +
                    [
                      RaisedButton(
                        color: themeColor,
                        onPressed: () async {
                          await loadUpvotedContent();
                          setState(() {
                            reloader = DateTime.now().millisecondsSinceEpoch;
                          });
                        },
                        child: Text(
                          "Load More",
                          style: TextStyle(color: appBarTextColor),
                        ),
                      )
                    ],
              );
            }
            return Column(
              children: likedPostsCardsWidgetArray,
            );
        }
      },
    );

    FutureBuilder showInitialActiveMembers = FutureBuilder<List<Widget>>(
      future:
          displayInitialActiveMembers(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              children: activeMembersCardsWidgetArray,
            );
          //return Text('Awaiting result...');
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (activeMembersCardsWidgetArray.length == 0) {
              return listviewPlaceholder;
            }
            if (snapshot.data.length > activeMembersCardsWidgetArray.length) {
              return Column(
                children: snapshot.data +
                    [
                      RaisedButton(
                        color: themeColor,
                        onPressed: () async {
                          await loadMembers();
                          setState(() {
                            reloader = DateTime.now().millisecondsSinceEpoch;
                          });
                        },
                        child: Text(
                          "Load More",
                          style: TextStyle(color: appBarTextColor),
                        ),
                      )
                    ],
              );
            }
            return Column(
              children: snapshot.data,
            );
        }
      },
    );

    FutureBuilder showInitialInactiveMembers = FutureBuilder<List<Widget>>(
      future:
          displayInitialInactiveMembers(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Text('Press button to start.');
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Column(
              children: inactiveMembersCardsWidgetArray,
            );
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            if (inactiveMembersCardsWidgetArray.length == 0) {
              return listviewPlaceholder;
            }
            if (snapshot.data.length > inactiveMembersCardsWidgetArray.length) {
              return Column(
                children: snapshot.data +
                    [
                      RaisedButton(
                        color: themeColor,
                        onPressed: () async {
                          await loadMembers();
                          setState(() {
                            reloader = DateTime.now().millisecondsSinceEpoch;
                          });
                        },
                        child: Text(
                          "Load More",
                          style: TextStyle(color: appBarTextColor),
                        ),
                      )
                    ],
              );
            }
            return Column(
              children: snapshot.data,
            );
        }
      },
    );

    FutureBuilder showActiveMembersIndicator = FutureBuilder<int>(
      future: databaseManager.getTotalActiveMembers(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text(
              activeMemberCountIndicator + ' Active',
              style: TextStyle(color: themeColor),
            );
            break;
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            activeMemberCountIndicator = snapshot.data.toString();
            return Text(
              activeMemberCountIndicator + ' Active',
              style: TextStyle(color: themeColor),
            );
        }
      },
    );

    FutureBuilder showInactiveMembersIndicator = FutureBuilder<int>(
      future: databaseManager.getTotalInactiveMembers(),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            break;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Text(
              inactiveMemberCountIndicator + ' Inactive',
              style: TextStyle(color: themeColor),
            );
            break;
          case ConnectionState.done:
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            inactiveMemberCountIndicator = snapshot.data.toString();
            return Text(
              inactiveMemberCountIndicator + ' Inactive',
              style: TextStyle(color: themeColor),
            );
        }
      },
    );

    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 3),
    );

    animationController.repeat();

    queueScrollController.addListener(() {
      if (queueScrollController.position.pixels ==
          queueScrollController.position.maxScrollExtent) {
        //SEND ANOTHER REQUEST
        toastMessageBottomShort("End of List");
      }
    });

    List<Widget> membersBottomNavigationBarContents = [
      //ACTIVE MEMBERS VIEW
      Container(
        color: Colors.transparent,
        child: RefreshIndicator(
          onRefresh: () async {
            await refreshMembers();
          },
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 70),
                child: showInitialActiveMembers,
              )
            ],
          ),
        ),
      ),
      //INACTIVE MEMBERS VIEW
      Container(
        child: RefreshIndicator(
          onRefresh: () async {
            await refreshMembers();
          },
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 70),
                child: showInitialInactiveMembers,
              )
            ],
          ),
        ),
      ),
      //FRIENDS VIEW
      /*
      Container(
        child: ListView(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5, 10, 5, 70),
              child: Column(
                children: friendsCardsWidgetArray,
              ),
            )
          ],
        ),
      ),*/
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 1,
          title: Text("Steemit Sentinels",
              style: TextStyle(color: appBarTextColor)),
          actions: <Widget>[
            Container(
              width: 40,
              padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (searchActive) {
                          globalFilter(false);
                        } else {
                          showPrompt("Search", context, filterDialogController,
                              () async {
                            if (filterDialogController.text.length > 0)
                              globalFilter(true);
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.fromLTRB(2, 2, 0, 2),
                        child: Icon(
                          Icons.search,
                          size: 22,
                          color: searchIconColor,
                        ),
                      ),
                    ),
                  ),
                  /*
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/addfriend');
                          },
                          child: Container(
                            child: new Icon(Icons.person_add,
                                size: 22, color: appBarTextColor),
                          ),
                        ),
                      ),*/
                ],
              ),
            )
          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(
                child: Text(
                  "Shared Posts",
                  style: TextStyle(
                    color: appBarTextColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Members",
                  style: TextStyle(
                    color: appBarTextColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Account",
                  style: TextStyle(color: appBarTextColor),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Scaffold(
                body: new RefreshIndicator(
                  onRefresh: () async {
                    //await loadUpvotedContent();
                    List newPosts = [];
                    if (await isConnected())
                      newPosts = await firebaseInterface.getNewPosts();
                    else
                      toastMessageBottomShort("Network Error");
                    bool status = await preparePendingContent(newPosts);
                    if (status == false) toastMessageBottomShort("Queue Full");
                    setState(() {
                      pendingPostsCardsWidgetArray =
                          pendingPostsCardsWidgetArray;
                      likedPostsCardsWidgetArray = likedPostsCardsWidgetArray;
                    });
                  },
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(5, 10, 5, 70),
                    children: [
                      //PENDING POSTS COLUMN
                      Column(
                        children: pendingPostsCardsWidgetArray,
                      ),
                      //LIKED POSTS COLUMN
                      showInitialPosts,
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  label: Text(
                    "Add",
                    style: TextStyle(color: appBarTextColor),
                  ),
                  icon: Icon(Icons.add),
                  backgroundColor: themeColor,
                  onPressed: () {
                    showPrompt("Enter URL", context, newSharedContentController,
                        () async {
                      try {
                        toastMessageBottomShort("Sharing..");
                        String currentUser = await getCurrentUser();
                        String url = newSharedContentController.text;
                        Map details = getPostDetails(url);
                        if (details["author"] != currentUser)
                          showAlert("Unable to Share",
                              "You can only share your own posts", context);
                        else {
                          try {
                            print("LOADING VIDEO");
                            await RewardedVideoAd.instance.load(
                                adUnitId: rewardAdUnitId,
                                targetingInfo: targetingInfo);
                            await RewardedVideoAd.instance.show();
                          } catch (err) {
                            print("ERROR WHILE SHOWING REWARD VIDEO AD");
                            print(err);
                            print("ERROR WHILE SHOWING REWARD VIDEO AD");
                            print(err);
                            print("ERROR WHILE SHOWING REWARD VIDEO AD");
                            print(err);
                            int status = await firebaseInterface
                                .newPost(newSharedContentController.text);
                            if (status == 1)
                              toastMessageBottomShort("Shared Successfully");
                            if (status == 0)
                              toastMessageBottomShort("Error Occurred");
                            if (status == -1)
                              toastMessageBottomShort("Already Shared");
                            if (status == -2)
                              toastMessageBottomShort("Connection Error");
                            newSharedContentController.text = "";
                          }
                        }
                      } catch (err) {
                        toastMessageBottomShort("Error Occurred");
                        newSharedContentController.text = "";
                      }
                    });
                    //POPUP DIALOG REQUESTING SHARE URL
                  },
                ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.endFloat),
            Container(
              child: Scaffold(
                body: membersBottomNavigationBarContents[
                    membersBottomNavigationBarIndex],
                bottomNavigationBar: BottomNavigationBar(
                  onTap: (index) {
                    setState(() {
                      membersBottomNavigationBarIndex = index;
                    });
                  },
                  currentIndex: membersBottomNavigationBarIndex,
                  items: [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person, color: themeColor),
                      title: showActiveMembersIndicator,
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline, color: themeColor),
                      title: showInactiveMembersIndicator,
                    ),
                    /*
                  BottomNavigationBarItem(
                      icon: Icon(
                        Icons.favorite_border,
                        color: themeColor,
                      ),
                      title:
                          Text('Friends', style: TextStyle(color: themeColor)))*/
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.grey[100],
              child: ListView(
                children: <Widget>[
                  Container(
                    color: themeColor,
                    height: 110,
                    padding: EdgeInsets.fromLTRB(0, 30, 0, 30),
                    child: loadAccountInformation,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  ),
                  /*
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    color: appBarTextColor,
                    child: Material(
                      color: appBarTextColor,
                      child: InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: new BoxDecoration(
                            border: new Border(
                              top: BorderSide(
                                color: accountOptionsBorderColor,
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: accountOptionsBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Icon(
                                        Icons.payment,
                                        color: themeColorButtons,
                                      ),
                                    ),
                                    Text(
                                      "Top Up",
                                      style: TextStyle(
                                          color: themeColorButtons,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: accountOptionsColor,
                                  size: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),*/
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    color: appBarTextColor,
                    child: Material(
                      color: appBarTextColor,
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/mycontent');
                        },
                        child: Container(
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: BorderSide(
                                color: accountOptionsBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child:
                                          Icon(Icons.event, color: themeColor),
                                    ),
                                    Text(
                                      "My Content",
                                      style: TextStyle(
                                          color: themeColorButtons,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: accountOptionsColor,
                                  size: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    color: appBarTextColor,
                    child: Material(
                      color: appBarTextColor,
                      child: InkWell(
                        onTap: () async {
                          //await showAlert("Contribute", "Benefited greatly from this service? It is completely free! but unfortunately costs to be maintained. Thanks to small contributions from users like you it is kept afloat", context);
                          Navigator.pushNamed(context, '/contribute');
                        },
                        child: Container(
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: BorderSide(
                                color: accountOptionsBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Icon(
                                        Icons.card_giftcard,
                                        color: themeColor,
                                      ),
                                    ),
                                    Text(
                                      "Contribute",
                                      style: TextStyle(
                                        color: themeColorButtons,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: accountOptionsColor,
                                  size: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    color: appBarTextColor,
                    child: Material(
                      color: appBarTextColor,
                      child: InkWell(
                        onTap: () async {
                          _launchURL(
                              "https://github.com/steemitsentinels/steemitsentinels.github.io/issues");
                        },
                        child: Container(
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: BorderSide(
                                color: accountOptionsBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Icon(
                                        Icons.error_outline,
                                        color: themeColor,
                                      ),
                                    ),
                                    Text(
                                      "Report Issue",
                                      style: TextStyle(
                                        color: themeColorButtons,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: accountOptionsColor,
                                  size: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    color: appBarTextColor,
                    child: Material(
                      color: appBarTextColor,
                      child: InkWell(
                        onTap: () async {
                          showCustomProcessDialog("Signing Out..", context);
                          bool successfullySignedOut = await logout(context);
                          Navigator.pop(context);
                          if (successfullySignedOut)
                            Navigator.pushReplacementNamed(context, "/login");
                          else
                            showAlert(
                                "Network Error", "Could not sign out", context);
                        },
                        child: Container(
                          decoration: new BoxDecoration(
                            border: new Border(
                              bottom: BorderSide(
                                color: accountOptionsBorderColor,
                                width: 1.0,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.fromLTRB(0, 10, 0, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(13, 0, 0, 0),
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
                                      child: Icon(
                                        Icons.exit_to_app,
                                        color: themeColorButtons,
                                      ),
                                    ),
                                    Text(
                                      "Sign Out",
                                      style: TextStyle(
                                          color: themeColorButtons,
                                          fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: accountOptionsColor,
                                  size: 17,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  )
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: setPaddingForAd,
      ),
    );
  }
}
