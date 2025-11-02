import 'package:face_contour_detector/face_contour_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;


class FaceDetectorExample extends StatefulWidget {
  const FaceDetectorExample({super.key});

  @override
  State<FaceDetectorExample> createState() => _FaceDetectorExampleState();
}

class _FaceDetectorExampleState extends State<FaceDetectorExample> {

  String _statusText = 'Not initialized';
  File? _selectedImage;
  List<FaceBox> faces = [];
  Size? _selectedImageSize;
  String duration = "";

  @override
  void initState() {
    super.initState();
    _initializeDetector();
  }

  Future<void> _initializeDetector() async {
    try {
      final bool initialized = await FaceContourDetectorPlatform.instance.initialize();
      setState(() {
        _statusText = initialized ? 'Ready for detection' : 'Failed to initialize detector';
      });
    } catch (e) {
      setState(() {
        _statusText = 'Error: $e';
      });
    }
  }

  Future<void> _pickAndDetectImage() async {
    setState(() {
      _selectedImage = null;
      _selectedImageSize = null;
      faces = [];
      duration = "";
    });

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;
    try {
      _selectedImage = File(image.path);
      final Uint8List imageBytes = await image.readAsBytes();
      final decodeImage = img.decodeImage(imageBytes);
      print("status : ${decodeImage != null}");
      if(decodeImage != null){
        _selectedImageSize = Size(decodeImage.width.toDouble(),decodeImage.height.toDouble());
        final startDate = DateTime.now();
        faces = await FaceContourDetectorPlatform.instance.detectFromImage(imageBytes);
        duration = "Toatl durarion : ${DateTime.now().difference(startDate).inMilliseconds} ms";
        print("duration : $duration");
      }
    } catch (e) {
      _selectedImage = null;
      faces = [];
      _selectedImageSize = null;
      duration = "";
    }
    finally {
      setState(() {});
    }
  }

  @override
  void dispose() {
    FaceContourDetectorPlatform.instance.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Detector Demo'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _statusText,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _selectedImage != null
                ? Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.lightGreenAccent)
                    ),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _selectedImageSize!.width,
                        height: _selectedImageSize!.height,
                        child: Stack(
                          children: [
                            Image.file(
                              _selectedImage!,
                              width: _selectedImageSize!.width,
                              height: _selectedImageSize!.height,
                              fit: BoxFit.fill,
                            ),
                            if (faces.isNotEmpty)
                              CustomPaint(
                                size: _selectedImageSize!,
                                painter: FaceBoxPainter(faces, _selectedImageSize!),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const Text('No image selected'),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickAndDetectImage,
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Pick Image'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(duration),
                  if(faces.isNotEmpty)
                    Text(
                        'Detected : ${faces[0].toString()} face(s)',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class FaceBoxPainter extends CustomPainter {
  final List<FaceBox> faces;
  final Size imageSize;

  FaceBoxPainter(this.faces, this.imageSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // No scaling needed - coordinates match exactly
    for (var face in faces) {
      final rect = Rect.fromLTWH(
        face.x.toDouble(),
        face.y.toDouble(),
        face.width,
        face.height,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FaceBoxPainter oldDelegate) {
    return faces != oldDelegate.faces || imageSize != oldDelegate.imageSize;
  }
}