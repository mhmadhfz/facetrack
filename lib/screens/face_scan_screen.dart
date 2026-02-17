import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../services/attendance_service.dart';
import 'attendance_success_screen.dart';
import '../services/api_service.dart';

class FaceScanScreen extends StatefulWidget {
  const FaceScanScreen({super.key});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  CameraController? _cameraController;
  late FaceDetector _faceDetector;

  String resultText = "Press the button to scan face";

  @override
  void initState() {
    super.initState();
    _initializeFaceDetector();
    _initializeCamera();
  }

  // ✅ Initialize Face Detector
  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.fast),
    );
  }

  // ✅ Initialize Camera (NO stream)
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
      resultText = "Scanning...";
    });

    try {
      // Take picture
      final XFile file = await _cameraController!.takePicture();

      final inputImage = InputImage.fromFile(File(file.path));

      // Detect faces
      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) return;

      if (faces.isNotEmpty) {
        setState(() {
          resultText = "Saving attendance to server...";
        });

        // ✅ Send attendance to Laravel API
        await ApiService.markAttendanceWithImage(File(file.path));

        // ✅ Mark attendance locally too (optional)
        AttendanceService.markAttendance();

        final now = DateTime.now();

        if (!mounted) return;

        // ✅ Navigate to success screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceSuccessScreen(time: now),
          ),
        );

        setState(() {
          resultText = "✅ Attendance Saved!";
        });
      } else {
        setState(() {
          resultText = "❌ No Face Found";
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
      appBar: AppBar(title: const Text("Face Scan")),
      body: Stack(
        children: [
          CameraPreview(_cameraController!),

          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  resultText,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ),

          // ✅ Capture Button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: _scanFace,
                child: const Icon(Icons.camera_alt),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
