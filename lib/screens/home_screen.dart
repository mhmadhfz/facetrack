import 'package:flutter/material.dart';

import 'face_scan_screen.dart';
import 'attendance_history_screen.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'terms_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

            // ✅ Dropdown appears directly below burger button
            offset: const Offset(0, 50),

            onSelected: (value) async {
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

            // ✅ Top Welcome Card
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
                  DashboardButton(
                    icon: Icons.camera_alt,
                    title: "Start Face Attendance",
                    subtitle: "Scan your face and mark attendance",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FaceScanScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  DashboardButton(
                    icon: Icons.history,
                    title: "Attendance History",
                    subtitle: "View your previous check-ins",
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
// ✅ Custom Dashboard Button Widget
//
class DashboardButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
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
        onPressed: onTap,
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
