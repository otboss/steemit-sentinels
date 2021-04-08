import 'package:flutter/material.dart';
import 'package:flutter_walkthrough/flutter_walkthrough.dart';
import 'package:flutter_walkthrough/walkthrough.dart';


class Introduction extends StatelessWidget {
  
  /*here we have a list of walkthroughs which we want to have, 
  each walkthrough have a title,content and an icon.
  */
  final List<Walkthrough> list = [
    Walkthrough(
      title: "Post",
      content: "Post good content on Steemit",
      imageIcon: Icons.local_post_office,
    ),
    Walkthrough(
      title: "Share",
      content: "Share link via Steemit Sentinels",
      imageIcon: Icons.share,
    ),
    Walkthrough(
      title: "Done",
      content: "Network Automatically Upvotes",
      imageIcon: Icons.language,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    //here we need to pass the list and the route for the next page to be opened after this.
    return new IntroScreen(
      list,
      new MaterialPageRoute(builder: (context) => new Introduction()),
    );
  }
}

