import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../services/attendance_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
    _initializeCamera();
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

  // ✅ Capture Photo + Detect Face
  Future<void> _scanFace() async {
    if (_cameraController == null) return;

    setState(() {
      resultText = "Scanning face...";
    });

    try {
      final XFile file = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFile(File(file.path));

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.isNotEmpty) {
        setState(() {
          resultText = "Saving attendance...";
        });

        // ✅ Upload to Laravel
        await ApiService.markAttendanceWithImage(File(file.path));

        // Optional local save
        AttendanceService.markAttendance();

        final now = DateTime.now();

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AttendanceSuccessScreen(time: now)),
        );
      } else {
        setState(() {
          resultText = "❌ No face detected. Try again.";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        resultText = "⚠️ Error: $e";
      });
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
          // ✅ Camera Preview Full Screen
          CameraPreview(_cameraController!),

          // ✅ Dark Overlay + Face Guide Frame
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
                  "Tap the button to mark attendance",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // ✅ Status Text (Below Oval, Above Button)
          Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                resultText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15, // ✅ Smaller size
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // ✅ Scan Button (Bottom Center)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 90,
                height: 60,
                child: FloatingActionButton(
                  onPressed: _scanFace,
                  child: const Text(
                    "SNAP",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
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
    // Full screen overlay path
    final fullPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Oval hole path
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.65,
      height: size.height * 0.45,
    );

    final ovalPath = Path()..addOval(ovalRect);

    // ✅ Combine paths: full screen - oval hole
    final overlayPath = Path.combine(
      PathOperation.difference,
      fullPath,
      ovalPath,
    );

    // Draw dark overlay with hole cut out
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    canvas.drawPath(overlayPath, overlayPaint);

    // White border around oval
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(ovalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanLinePainter extends CustomPainter {
  final double position;

  ScanLinePainter(this.position);

  @override
  void paint(Canvas canvas, Size size) {
    // Oval frame area
    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.65,
      height: size.height * 0.45,
    );

    // Scan line Y position inside oval
    final y = ovalRect.center.dy + (ovalRect.height / 2) * position;

    final linePaint = Paint()
      ..color = Colors.lightBlueAccent.withValues(alpha: 0.8)
      ..strokeWidth = 3;

    // Draw scan line only inside oval bounds
    canvas.drawLine(
      Offset(ovalRect.left + 20, y),
      Offset(ovalRect.right - 20, y),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
