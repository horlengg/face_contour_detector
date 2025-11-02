import 'package:face_contour_detector/models/face_box.dart';
import 'package:face_contour_detector/models/face_detector_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'face_contour_detector_platform_interface.dart';

/// An implementation of [FaceContourDetectorPlatform] that uses method channels.
class MethodChannelFaceContourDetector extends FaceContourDetectorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('face_bounding_box_detector');

  bool _isInitialized = false;

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }


  @override
  Future<bool> initialize() async {
    try {
      final bool? result = await methodChannel.invokeMethod('initialize');
      _isInitialized = result ?? false;
      return _isInitialized;
    } on PlatformException catch (e) {
      throw FaceDetectorException(
        'Failed to initialize detector: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<FaceBox>> detectFromImage(Uint8List imageBytes) async {
    if (!_isInitialized) {
      throw FaceDetectorException('Detector not initialized');
    }
    try {
      final List<dynamic>? result = await methodChannel.invokeMethod(
        'detectFromImage',
        {'imageBytes': imageBytes},
      );

      if (result == null) return [];

      return result
          .map((face) => FaceBox.fromMap(face as Map<dynamic, dynamic>))
          .toList();
    } on PlatformException catch (e) {
      throw FaceDetectorException(
        'Detection failed: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<List<FaceBox>> detectFromYuv({
    required Uint8List yuvBytes,
    required int width,
    required int height,
    int orientation = 0,
  }) async {
    if (!_isInitialized) {
      throw FaceDetectorException('Detector not initialized');
    }

    try {
      final List<dynamic>? result = await methodChannel.invokeMethod(
        'detectFromYuv',
        {
          'yuvBytes': yuvBytes,
          'width': width,
          'height': height,
          'orientation': orientation,
        },
      );

      if (result == null) return [];

      return result
          .map((face) => FaceBox.fromMap(face as Map<dynamic, dynamic>))
          .toList();
    } on PlatformException catch (e) {
      throw FaceDetectorException(
        'Detection failed: ${e.message}',
        code: e.code,
      );
    }
  }

  @override
  Future<void> destroy() async {
    try {
      await methodChannel.invokeMethod('destroy');
      _isInitialized = false;
    } on PlatformException catch (e) {
      throw FaceDetectorException(
        'Failed to destroy detector: ${e.message}',
        code: e.code,
      );
    }
  }

}
