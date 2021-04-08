import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import '../main.dart';
import './signin.dart';

var qrText = "";
var qrScanCallback;

void main() => runApp(MaterialApp(home: QRViewExample()));

class QRViewExample extends StatefulWidget {
  const QRViewExample({
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: FlatButton(
          child: Icon(
            Icons.arrow_back,
            color: appBarTextColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: themeColor,
        title: Row(
          children: <Widget>[
            Text(
              "Scan QR to Join Network",
              style: TextStyle(color: appBarTextColor),
            )
          ],
        ),
      ),
      body: Container(
        color: themeColor,
        child: Center(
          child: new ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20.0),
              children: [
                Stack(
                  alignment: Alignment(0, 0),
                  children: <Widget>[
                    Container(
                      width: 295,
                      height: 295,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                    ),
                    Image(image: AssetImage("assets/frame.png")),
                  ],
                )
              ]),
        ),
      ),
      /*
      floatingActionButton: FloatingActionButton.extended(
        label: Text(
          "torch",
          style: TextStyle(color: appBarTextColor),
        ),
        icon: Icon(Icons.lightbulb_outline),
        backgroundColor: themeColor,
        onPressed: () {
          if(lampOn){
            Lamp.turnOff();
            lampOn = false;
          }
          else{
            Lamp.turnOn();
            lampOn = true;
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,*/
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final channel = controller.channel;
    controller.init(qrKey);
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case "onRecognizeQR":
          //QR CODE FOUND
          dynamic arguments = call.arguments;
          setState(() {
            qrText = arguments.toString();
          });
          Navigator.pop(context);
          
          //CALLBACK FUNCTION SHOULD BE SET TO A FUTURE
          qrScanCallback();
      }
    });
  }
}
