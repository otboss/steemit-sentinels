import 'package:flutter/material.dart';
import '../main.dart';
import './home.dart';

class SuccessfullyRegistered extends StatefulWidget {
  SuccessfullyRegisteredState createState() => new SuccessfullyRegisteredState();
}

class SuccessfullyRegisteredState extends State<SuccessfullyRegistered> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(254, 252, 254, 1),
      body: Container(
        child: Center(
          child: new ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: [
                Center(
                    child: Container(
                  height: 130,
                  width: 130,
                  child: Image(
                      image: AssetImage("assets/check_tick.gif"),
                      fit: BoxFit.fill),
                )),
                Container(
                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Text(
                    "Registration Successful",
                    style: TextStyle(
                        color: Color.fromRGBO(73, 174, 81, 1), fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Container(
                    width: 170,
                    child: RaisedButton(
                        child: const Text('Proceed'),
                        textColor: Colors.white,
                        color: themeColorButtons,
                        elevation: 0.0,
                        splashColor: Colors.greenAccent,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        })),
                )
              ]),
        ),
      ),
    );
  }
}
