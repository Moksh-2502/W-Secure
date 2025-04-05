import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmergencyLockScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final String _lockPassword = "1234"; // Replace with a secure password
  final VoidCallback onExit; // Added onExit callback

  EmergencyLockScreen({required this.onExit}); // Constructor updated

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Emergency Mode Activated",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Enter Password to Exit",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_passwordController.text == _lockPassword) {
                    onExit(); // Call onExit callback
                  } else {
                    Get.snackbar("Error", "Incorrect Password",
                        snackPosition: SnackPosition.BOTTOM);
                  }
                },
                child: const Text("Unlock"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
