import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

import 'camera.dart';
import 'bndbox.dart';
import 'models.dart';

bool isDetecting = false;

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
      case yolo:
        res = await Tflite.loadModel(
          model: "assets/yolov2_tiny.tflite",
          labels: "assets/yolov2_tiny.txt",
        );
        break;

      case mobilenet:
        res = await Tflite.loadModel(
          model: "assets/plushie.tflite",
          labels: "assets/retrained_labels.txt",
        );
        break;

      case posenet:
        res = await Tflite.loadModel(
            model: "assets/posenet_mv1_075_float_from_checkpoints.tflite");
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
    Size screen = MediaQuery.of(context).size;
    return Scaffold(
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Container(
                    decoration: new BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.all(Radius.circular(15.0))),
                    padding: EdgeInsets.only(top: 20),
                    height: 100,
                    width: 300,
                    // color: Colors.grey[800],
                    child: Center(
                      child: BndBox(
                          _recognitions == null ? [] : _recognitions,
                          math.max(_imageHeight, _imageWidth),
                          math.min(_imageHeight, _imageWidth),
                          screen.height,
                          screen.width,
                          _model),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
