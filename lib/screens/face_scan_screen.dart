import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../services/api_service.dart';
import 'attendance_success_screen.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;

  late AnimationController _animationController;
  late Animation<double> _scanAnimation;

  String resultText = "Align your face inside the frame";
  bool isProcessing = false; // ✅ Prevent double scan

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
    _initializeCamera();

    // ✅ Scan Line Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -1, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // ✅ Initialize Face Detector
  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );
  }

  // ✅ Initialize Camera
  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    if (!mounted) return;
    setState(() {});
  }

  // ✅ Capture Photo + Detect Face + Upload Attendance
  Future<void> _scanFace() async {
    if (_cameraController == null) return;
    if (isProcessing) return;

    setState(() {
      isProcessing = true;
      resultText = "Scanning face...";
    });

    try {
      // ✅ Take picture
      final XFile file = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFile(File(file.path));

      // ✅ Detect face
      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.isEmpty) {
        setState(() {
          resultText = "No face detected. Try again.";
          isProcessing = false;
        });
        return;
      }

      setState(() {
        resultText = "Saving attendance...";
      });

      // ✅ Upload Attendance (Laravel returns check_in/check_out)
      final data = await ApiService.markAttendance();
      final type = data["type"];

      final now = DateTime.now();

      if (!mounted) return;

      // ✅ Stop animation before leaving screen
      _animationController.stop();

      // ✅ Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AttendanceSuccessScreen(time: now, type: type),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        resultText = " Verification failed.\nTry again.";
        isProcessing = false;
      });

      debugPrint("FULL ERROR: $e");
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Face Attendance"), centerTitle: true),
      body: Stack(
        children: [
          // ✅ Camera Preview
          CameraPreview(_cameraController!),

          // ✅ Dark Overlay + Oval Guide
          Positioned.fill(child: CustomPaint(painter: FaceGuidePainter())),

          // ✅ Animated Scan Line
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _scanAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ScanLinePainter(_scanAnimation.value),
                );
              },
            ),
          ),

          // ✅ Instruction Text (Top)
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Column(
              children: const [
                Text(
                  "Position your face inside the frame",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Tap SNAP to check-in / check-out",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // ✅ Status Text
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                resultText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ✅ SNAP Button
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.extended(
                onPressed: isProcessing ? null : _scanFace,
                label: isProcessing
                    ? const Text("WAIT...")
                    : const Text("SNAP"),
                icon: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//
// ✅ Face Guide Overlay Painter
//
class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.65,
      height: size.height * 0.45,
    );

    final ovalPath = Path()..addOval(ovalRect);

    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      ovalPath,
    );

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

//
// ✅ Scan Line Painter
//
class ScanLinePainter extends CustomPainter {
  final double position;

  ScanLinePainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.65,
      height: size.height * 0.45,
    );

    final y = ovalRect.center.dy + (ovalRect.height / 2) * position;

    final linePaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.8)
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(ovalRect.left + 20, y),
      Offset(ovalRect.right - 20, y),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
