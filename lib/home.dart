import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
//import 'dart:math' as math;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'camera.dart';
//import 'bndbox.dart';
import 'models.dart';

import 'package:toast/toast.dart';

bool isDetecting = false;
bool wantsdata = false;

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  @override
  void initState() {
    super.initState();
  }

  loadModel() async {
    String res;
    switch (_model) {
      case mobilenet:
        res = await Tflite.loadModel(
          model: "assets/plushie.tflite",
          labels: "assets/retrained_labels.txt",
        );
        break;

      default:
        res = await Tflite.loadModel(
          model: "assets/plushie.tflite",
          labels: "assets/ssd_mobilenet.txt",
        );
    }
    print(res);
  }

  onSelect(model) {
    setState(() {
      _model = model;
    });
    loadModel();
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Size screen = MediaQuery.of(context).size;
    void settingModalBottomSheet(context) {
      if (_recognitions[0]["index"] == 0)
        showModalBottomSheet(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          enableDrag: true,
          context: context,
          builder: (BuildContext bc) {
            return Container(
              decoration: new BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              padding: EdgeInsets.only(top: 20),
              height: 100,
              width: 300,
              // color: Colors.grey[800],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: Text(
                    "This is a Android plushie. I am " +
                        (_recognitions[0]["confidence"] * 100)
                            .toStringAsFixed(2) +
                        "% sure",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.lightBlueAccent,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      else {
        showModalBottomSheet(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
          ),
          enableDrag: true,
          context: context,
          builder: (BuildContext bc) {
            return Container(
              decoration: new BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              padding: EdgeInsets.only(top: 20),
              height: 100,
              width: 300,
              // color: Colors.grey[800],
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                  child: Text(
                    "This is a not Android plushie. I am " +
                        (_recognitions[0]["confidence"] * 100)
                            .toStringAsFixed(2) +
                        "% sure",
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }
    }

    void showtoast() {
      if (_recognitions[0]["index"] == 0)
        Toast.show("Found Android plushie", context,
            textColor: Colors.tealAccent,
            backgroundColor: Colors.grey[800],
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.TOP);
      else {
        Toast.show("Did not find a Android plushie", context,
            textColor: Colors.red,
            backgroundColor: Colors.grey[800],
            duration: Toast.LENGTH_SHORT,
            gravity: Toast.TOP);
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[800],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.grey[800],
        title: Text(
          "PlushieMate",
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: _model == ""
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    child: const Text("Start Detecting"),
                    onPressed: () => onSelect(mobilenet),
                  ),
                ],
              ),
            )
          : Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Camera(
                  widget.cameras,
                  _model,
                  setRecognitions,
                ),
                Center(
                  child: Container(
                    height: 1000,
                    width: 500,
                    child: MaterialButton(
                      onPressed: () {
                        print(_recognitions);
                        print(_recognitions[0]["confidence"]);
                        setState(() {
                          wantsdata = true;
                          // _recognitions;
                          // _recognitions[0]["confidence"];
                        });

                        showtoast();
                        settingModalBottomSheet(context);
                      },
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    color: Colors.transparent,
                    child: SpinKitDoubleBounce(
                      color: Colors.white,
                      size: 25.0,
                    ),
                  ),
                ),

                Opacity(
                  opacity: 0.5,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 150),
                    child: Container(
                      height: 50,
                      width: 150,
                      decoration: new BoxDecoration(
                        color: Colors.grey[700],
                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Icon(Icons.search),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 10, 8),
                            child: Text(
                              "Dectecting",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
// uncomment if u wanna see live daata.
                // BndBox(
                //     _recognitions == null ? [] : _recognitions,
                //     math.max(_imageHeight, _imageWidth),
                //     math.min(_imageHeight, _imageWidth),
                //     100,
                //     200,
                //     _model),
              ],
            ),
    );
  }
}
