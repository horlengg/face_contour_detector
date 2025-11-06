# face_contour_detector

A Flutter plugin for detecting face contours in rgb image.

- Currently support only android and in future I'll add feature for support iOS.
- This plugin take time 20ms -> 80ms for detect face contour from image base on image size.


---

## Getting Started

Add this plugin to your `pubspec.yaml`:

```yaml
dependencies:
  face_contour_detector: ^0.0.2

```


## Initialization
Need initialize the detector before using it:

```dart

import 'package:face_contour_detector/face_contour_detector.dart';

bool status = await FaceContourDetector.initialize();

```

## Detect Faces from image bytes
```dart

List<Rect> faces = await FaceContourDetector.detectFromImage(imageBytes);


```
## Detect Faces from image yuv bytes
```dart

List<Rect> faces = await FaceContourDetector.detectFromYuv(yuvBytes: yuvBytes,width: width,height: height);


```


## Cleanup
Destroy the detector when it’s no longer needed:
```dart

FaceContourDetector.destroy();

```
