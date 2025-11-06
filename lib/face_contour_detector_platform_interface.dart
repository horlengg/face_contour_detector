import 'dart:typed_data';

import 'package:flutter/animation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'face_contour_detector_method_channel.dart';

abstract class FaceContourDetectorPlatform extends PlatformInterface {
  /// Constructs a FaceBoundingBoxDetectorPlatform.
  FaceContourDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FaceContourDetectorPlatform _instance = MethodChannelFaceContourDetector();

  /// The default instance of [FaceBoundingBoxDetectorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFaceContourDetector].
  static FaceContourDetectorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FaceContourDetectorPlatform] when
  /// they register themselves.
  static set instance(FaceContourDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Initialize the face detector
  Future<bool> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Detect faces from image bytes (JPEG, PNG, etc.)
  Future<List<Rect>> detectFromImage(Uint8List imageBytes){
    throw UnimplementedError('detectFromImage() has not been implemented.');
  }

  /// Detect faces from YUV420 camera data
  Future<List<Rect>> detectFromYuv({
    required Uint8List yuvBytes,
    required int width,
    required int height,
    int orientation = 0,
  }){
    throw UnimplementedError('detectFromYuv() has not been implemented.');
  }

  /// Destroy the detector and free resources
  Future<void> destroy() {
    throw UnimplementedError('destroy() has not been implemented.');
  }

}
