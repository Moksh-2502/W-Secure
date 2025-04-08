import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EmergencyLockScreen extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();
  final String _lockPassword = "1234"; 
  final VoidCallback onExit;

  EmergencyLockScreen({super.key, required this.onExit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          true, 
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/splash.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Emergency Mode Activated",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFE4D0),
                    fontFamily: GoogleFonts.nunito().fontFamily,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Enter Password to Exit",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE4D0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.w),
                    ),
                  ),
                  onPressed: () {
                    if (_passwordController.text == _lockPassword) {
                      onExit();
                    } else {
                      Get.snackbar("Error", "Incorrect Password",
                          snackPosition: SnackPosition.BOTTOM);
                    }
                  },
                  child: Text(
                    'Unlock',
                    style: TextStyle(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                      fontFamily: GoogleFonts.nunito().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
