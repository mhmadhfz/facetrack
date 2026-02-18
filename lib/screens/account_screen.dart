import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? profilePhotoUrl;

  String email = "";
  bool loading = true;
  String message = "";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ✅ Fetch Profile from Backend
  Future<void> loadProfile() async {
    try {
      final user = await ProfileService.fetchProfile();

      setState(() {
        nameController.text = user["name"];
        emailController.text = user["email"];

        profilePhotoUrl = user["profile_photo"] != null
            ? "http://192.168.0.108/facetrack_backend/public/storage/${user["profile_photo"]}"
            : null;

        loading = false;
      });
    } catch (e) {
      setState(() {
        message = "Failed to load profile";
        loading = false;
      });
    }
  }

  // ✅ Save Profile Changes
  Future<void> saveProfile() async {
    setState(() {
      message = "";
    });

    final success = await ProfileService.updateProfile(
      nameController.text.trim(),
      passwordController.text.trim(),
      confirmPasswordController.text.trim(),
    );

    if (success) {
      setState(() {
        message = "Profile updated successfully!";
        passwordController.clear();
        confirmPasswordController.clear();
      });
    } else {
      setState(() {
        message = "Update failed. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Account"), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ✅ Profile Photo Circle
            GestureDetector(
              onTap: () async {
                final picker = ImagePicker();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );

                if (picked == null) return;

                final file = File(picked.path);

                final url = await ProfileService.uploadProfilePhoto(file);

                if (url != null) {
                  setState(() {
                    profilePhotoUrl = url;
                    message = "Photo updated!";
                  });
                } else {
                  setState(() {
                    message = "Upload failed.";
                  });
                }
              },
              child: CircleAvatar(
                radius: 55,
                backgroundColor: Colors.blue.withValues(alpha: 0.2),
                backgroundImage: profilePhotoUrl != null
                    ? NetworkImage(profilePhotoUrl!)
                    : null,
                child: profilePhotoUrl == null
                    ? const Icon(Icons.camera_alt, size: 40, color: Colors.blue)
                    : null,
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Name Input
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ✅ Email Read Only
            TextField(
              readOnly: true,
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ✅ Password Input
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "New Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ✅ Confirm Password Input
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(
                  color: message.contains("✅") ? Colors.green : Colors.black,
                  fontSize: 16,
                ),
              ),

            const SizedBox(height: 20),

            // ✅ Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveProfile,
                child: const Text("Save Changes"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
