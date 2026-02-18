import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms & Conditions"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "FaceTrack Terms & Conditions",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              Text(
                "1. Purpose\n"
                "FaceTrack is a smart attendance system created for educational "
                "and portfolio purposes.\n",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 15),

              Text(
                "2. Attendance Data\n"
                "Attendance records and face scan images are stored securely "
                "for demonstration and system validation only.\n",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 15),

              Text(
                "3. Privacy\n"
                "User data is not shared with third parties. All information "
                "remains within the system database.\n",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 15),

              Text(
                "4. User Responsibility\n"
                "Users are responsible for ensuring correct usage of the "
                "application and protecting their login credentials.\n",
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 25),

              Text(
                "Thank you for using FaceTrack!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
