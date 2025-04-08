import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class SetPinScreen extends StatelessWidget {
  final TextEditingController _pinController = TextEditingController();
  final HomeController _homeController = Get.find<HomeController>();

  SetPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Emergency PIN'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _pinController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter New PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final pin = _pinController.text;
                if (pin.isNotEmpty) {
                  await _homeController.setAppPin(pin);
                  Get.offAllNamed(
                      '/home'); 
                } else {
                  Get.snackbar('Error', 'PIN cannot be empty');
                }
              },
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}
