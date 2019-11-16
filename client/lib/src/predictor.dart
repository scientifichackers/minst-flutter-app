import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:ui';
import 'package:mnist_app/src/constants.dart';

class Predictor {
  WebSocket ws;
  Stream<List<double>> stream;

  Future<void> connect() async {
    ws = await WebSocket.connect(serverURL);
    stream = ws.asBroadcastStream().map((json) {
      return List<double>.from(jsonDecode(json));
    });
  }

  Future<void> predict(List<Offset> points) async {
    // We create an empty canvas 280x280 pixels
    final canvasSizeWithPadding = kCanvasSize + (2 * kCanvasInnerOffset);
    final canvasOffset = Offset(kCanvasInnerOffset, kCanvasInnerOffset);
    final recorder = PictureRecorder();

    final canvas = Canvas(
      recorder,
      Rect.fromPoints(
        Offset(0.0, 0.0),
        Offset(canvasSizeWithPadding, canvasSizeWithPadding),
      ),
    );

    // Our image is expected to have a black background and a white drawing trace,
    // quite the opposite of the visual representation of our canvas on the screen
    canvas.drawRect(
      Rect.fromLTWH(0, 0, canvasSizeWithPadding, canvasSizeWithPadding),
      kBackgroundPaint,
    );

    // Now we draw our list of points on white paint
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(
          points[i] + canvasOffset,
          points[i + 1] + canvasOffset,
          kWhitePaint,
        );
      }
    }

    // At this point our virtual canvas is ready and we can export an image from it
    final picture = recorder.endRecording();
    final rawImage = await picture.toImage(
      canvasSizeWithPadding.toInt(),
      canvasSizeWithPadding.toInt(),
    );

    var byteData = await rawImage.toByteData();
    var image = img.copyResize(
      img.Image.fromBytes(
        rawImage.width,
        rawImage.height,
        byteData.buffer.asUint8List(),
      ),
      width: 28,
      height: 28,
    );

    ws.add(image.getBytes(format: img.Format.luminance));
  }
}
