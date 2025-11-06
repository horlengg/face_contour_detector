// author Ly Horleng
// https://horleng.vercel.app


import 'dart:typed_data';

import 'package:face_contour_detector/face_contour_detector_platform_interface.dart';
import 'package:flutter/widgets.dart';

class FaceContourDetector {


  static Future<bool> initialize() async {
    return FaceContourDetectorPlatform.instance.initialize();
  }

  static Future<List<Rect>> detectFromImage(Uint8List imageBytes) async {
    return FaceContourDetectorPlatform.instance.detectFromImage(imageBytes);
  }

  static Future<List<Rect>> detectFromYuv({
    required Uint8List yuvBytes,
    required int width,
    required int height,
    int orientation = 0,
  }) {
    return FaceContourDetectorPlatform.instance.detectFromYuv(yuvBytes: yuvBytes,width: width,height: height);
  }

  static Future<void> destroy() async {
    return FaceContourDetectorPlatform.instance.destroy();
  }

}