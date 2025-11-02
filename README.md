# face_contour_detector

A Flutter plugin for detecting face contours in rgb image.

- Currently support only android and in future I'll add feature for support iOS.
- This plugin take time 20ms -> 80ms for detect face contour from image base on image size.


---

## Getting Started

Add this plugin to your `pubspec.yaml`:

```yaml
dependencies:
  face_contour_detector: ^0.0.1

```


## Initialization
Need initialize the detector before using it:

```dart

bool status = await FaceContourDetectorPlatform.instance.initialize();

```

## Detect Faces from Image
```dart
List<FaceBox> faces = await FaceContourDetectorPlatform.instance.detectFromImage(imageBytes);
```


## Cleanup
Destroy the detector when it’s no longer needed:
```dart

FaceContourDetectorPlatform.instance.destroy();

```
