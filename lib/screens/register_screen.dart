import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String errorText = "";

  Future<void> handleRegister() async {
    debugPrint("REGISTER BUTTON CLICKED ✅");

    final success = await AuthService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    debugPrint("REGISTER RESULT: $success");

    if (success) {
      Navigator.pop(context); // ✅ Go back to LoginScreen

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Registration successful! Please login."),
        ),
      );
    } else {
      setState(() {
        errorText = "❌ Registration failed. Try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),

            if (errorText.isNotEmpty)
              Text(errorText, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: handleRegister, // ✅ Correct
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
