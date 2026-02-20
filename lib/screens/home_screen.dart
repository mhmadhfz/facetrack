import 'package:flutter/material.dart';

import 'face_scan_screen.dart';
import 'attendance_history_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'terms_screen.dart';
import 'account_screen.dart';
import '../services/profile_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String buttonText = "Loading...";
  bool isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    loadAttendanceStatus();
  }

  // ✅ Load Today Attendance Status
  Future<void> loadAttendanceStatus() async {
    try {
      final status = await ApiService.getTodayAttendanceStatus();

      setState(() {
        if (status == "not_checked_in") {
          buttonText = "Check In";
          isButtonEnabled = true;
        } else if (status == "checked_in") {
          buttonText = "Check Out";
          isButtonEnabled = true;
        } else {
          buttonText = "Attendance Completed";
          isButtonEnabled = false;
        }
      });
    } catch (e) {
      setState(() {
        buttonText = "Error Loading Status";
        isButtonEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        centerTitle: true,
        elevation: 0,

        // ✅ Burger Menu Dropdown
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),

            // ✅ Dropdown below burger button
            offset: const Offset(0, 50),

            onSelected: (value) async {
              if (value == "account") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AccountScreen()),
                );
              }

              if (value == "terms") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TermsScreen()),
                );
              }

              if (value == "logout") {
                await AuthService.logout();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },

            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "account",
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 10),
                    Text("My Account"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "terms",
                child: Row(
                  children: [
                    Icon(Icons.description, size: 20),
                    SizedBox(width: 10),
                    Text("Terms & Conditions"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 10),
                    Text("Logout"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ✅ Welcome Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: const [
                    Icon(Icons.face_retouching_natural, size: 60),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        "Welcome to FaceTrack 👋\nYour smart attendance system.",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ✅ Dashboard Buttons
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Dynamic Check In / Out Button
                  DashboardButton(
                    icon: Icons.camera_alt,
                    title: buttonText,
                    subtitle: "Scan your face to mark attendance",
                    enabled: isButtonEnabled,
                    onTap: () async {
                      // ✅ Check profile photo first
                      final hasPhoto = await ProfileService.hasProfilePhoto();

                      if (!hasPhoto) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AccountScreen(showUploadMessage: true),
                          ),
                        );
                        return;
                      }

                      // ✅ Go Scan
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FaceScanScreen(),
                        ),
                      ).then((_) {
                        // ✅ Refresh status after scan
                        loadAttendanceStatus();
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // ✅ Attendance History Button
                  DashboardButton(
                    icon: Icons.history,
                    title: "Attendance History",
                    subtitle: "View your previous check-ins",
                    enabled: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceHistoryScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// ✅ Dashboard Button Widget (Supports Disabled State)
//
class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 85,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: enabled ? onTap : null,
        child: Row(
          children: [
            Icon(icon, size: 32),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: enabled ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: enabled ? null : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: enabled ? null : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
