import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mnist_app/src/constants.dart';
import 'package:mnist_app/src/drawing_painter.dart';
import 'package:mnist_app/src/predictor.dart';

class Home extends StatefulWidget {
  @override
  _RecognizerScreen createState() => _RecognizerScreen();
}

class _RecognizerScreen extends State<Home> {
  static var emptyPredictions = List.generate(9, (_) => 0.0);
  static var spacing = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildWaitConnect(),
      floatingActionButton: FloatingActionButton(
        onPressed: clear,
        child: Icon(
          isLoading || loadingError != null ? Icons.refresh : Icons.delete,
        ),
      ),
    );
  }

  Widget buildWaitConnect() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    if (loadingError != null) {
      return Padding(
        padding: const EdgeInsets.all(50),
        child: SingleChildScrollView(
          child: Text(
            loadingError,
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return buildHome();
  }

  Widget buildHome() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: spacing / 2),
        Padding(
          padding: EdgeInsets.all(10),
          child: Text(
            "Draw inside the box, see predictions in real-time from the server!",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: spacing),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            buildDrawingBox(),
          ],
        ),
        SizedBox(height: spacing),
        StreamBuilder(
          stream: predictor.stream,
          builder: (context, snapshot) {
            print(snapshot);
            return PredictionBar(
              predictions: snapshot.data ?? emptyPredictions,
            );
          },
        ),
      ],
    );
  }

  Widget buildDrawingBox() {
    return Container(
      decoration: new BoxDecoration(
        border: new Border.all(
          width: 3.0,
          color: Colors.blue,
        ),
      ),
      child: Builder(
        builder: (BuildContext context) {
          return GestureDetector(
            onPanUpdate: onUpdate,
            onPanStart: onUpdate,
            onPanEnd: onPaintDone,
            child: ClipRect(
              child: CustomPaint(
                size: Size(kCanvasSize, kCanvasSize),
                painter: DrawingPainter(offsetPoints: points),
              ),
            ),
          );
        },
      ),
    );
  }

  var points = <Offset>[];
  var predictor = Predictor();
  var isLoading = true;
  String loadingError;

  @override
  void initState() {
    super.initState();
    initAsyncState();
  }

  Future<void> initAsyncState() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      loadingError = null;
    });

    try {
      await predictor.connect();
    } catch (e, trace) {
      if (!mounted) return;
      setState(() {
        loadingError = '$e\n$trace';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }

    Timer.periodic(Duration(milliseconds: 250), predict);
  }

  Future<void> predict(Timer timer) async {
    if (!mounted) {
      timer.cancel();
    } else {
      await predictor.predict(points);
    }
  }

  void onUpdate(details) {
    setState(() {
      points.add(details.localPosition);
    });
  }

  void onPaintDone(_) {
    setState(() {
      points.add(null);
    });
  }

  void clear() {
    if (isLoading) {
      initAsyncState();
      return;
    }
    setState(() {
      points.clear();
    });
  }
}

class PredictionBar extends StatelessWidget {
  final List<double> predictions;
  final double height, width;

  const PredictionBar({
    Key key,
    @required this.predictions,
    this.height = 80,
    this.width = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (var i = 0; i < predictions.length; i++)
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: <Widget>[
                Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue,
                    ),
                    height: predictions[i] * height,
                  ),
                ),
                SizedBox(height: 10),
                Text(i.toString(), style: TextStyle(fontSize: 18)),
              ],
            ),
          )
      ],
    );
  }
}
