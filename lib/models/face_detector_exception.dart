// 

class FaceDetectorException implements Exception {
  final String message;
  final String? code;

  FaceDetectorException(this.message, {this.code});

  @override
  String toString() => 'FaceDetectorException: $message${code != null ? ' (code: $code)' : ''}';
}