import 'package:flutter/material.dart';
import 'package:unieaat/services/database_service.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  String? password; // Stores the password if found
  bool isLoading = false;

  Future<void> retrievePassword() async {
    setState(() => isLoading = true);
    String email = emailController.text.trim();

    var user = await DatabaseHelper.instance.getUserByEmail(email);

    setState(() {
      isLoading = false;
      if (user != null) {
        password = user['password']; // Show password on screen
      } else {
        password = null; // Email not found
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[100],
      appBar: AppBar(
        title: const Text("Forget Password", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Enter your registered email to retrieve your password",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: const Icon(Icons.email, color: Colors.amber),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: retrievePassword,
              child: const Text("Retrieve Password", style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(height: 20),
            password != null
                ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: Column(
                children: [
                  const Text("Your Password:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    password!,
                    style: const TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                : (password == null && emailController.text.isNotEmpty)
                ? const Text("Email not found", textAlign: TextAlign.center, style: TextStyle(color: Colors.red))
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
