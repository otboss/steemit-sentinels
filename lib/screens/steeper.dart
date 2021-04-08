import 'package:flutter/material.dart';
import '../main.dart';

class StepperDemo extends StatefulWidget {
  LoadStepperDemo createState() => new LoadStepperDemo();
}

class LoadStepperDemo extends State<StepperDemo> {
  int currentStep = 0;
  Widget build(BuildContext context) {
    List<Step> signInSteps() {
      List<Step> steps = [
        Step(
            title: Text(
              "Sign In",
              style: TextStyle(color: appBarTextColor),
            ),
            content: Container(
              child: Column(
                children: <Widget>[
                  TextField(
                      decoration:
                          new InputDecoration.collapsed(hintText: "Username")),
                  TextField(
                      decoration:
                          new InputDecoration.collapsed(hintText: "Password")),
                ],
              ),
            ),
            isActive: this.currentStep >= 0),
        Step(
            title: Text(
              "Sentinel Network",
              style: TextStyle(color: appBarTextColor),
            ),
            content: Container(
              child: Column(
                children: <Widget>[
                  Text(
                    "The network allows its members to automatically upvote any post that is shared to it",
                    style: TextStyle(color: appBarTextColor),
                  ),
                  RaisedButton(
                      child: Text("Create Network"),
                      color: Colors.green,
                      textColor: appBarTextColor,
                      onPressed: () {
                        //ASK USER FOR NETWORK NAME
                      }),
                  RaisedButton(
                      child: Text("Join Network"),
                      color: Colors.green,
                      textColor: appBarTextColor,
                      onPressed: () {
                        //OPEN QR CODE SCANNER
                      })
                ],
              ),
            ),
            isActive: this.currentStep >= 1),
        Step(
            title: Text(
              "Membership Activation",
              style: TextStyle(color: appBarTextColor),
            ),
            content: Container(
              child: Column(
                children: <Widget>[
                  RaisedButton(
                      child: Text("Proceed"),
                      onPressed: () {
                        //OPEN PAYPAL
                      })
                ],
              ),
            ),
            isActive: this.currentStep >= 2)
      ];
      return steps;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("STEEPER DEMO", style: TextStyle(color: appBarTextColor)),
      ),
      body: Stepper(
        steps: signInSteps(),
      ),
    );
  }
}
