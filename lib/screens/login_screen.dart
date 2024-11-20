import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:security/controllers/login_controller.dart';
import 'package:security/widgets/background_widget.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController _loginController = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return BackgroundPage(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w).copyWith(top: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 5.h),
              child: Text(
                'Login',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFFFFECD0),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            _buildTextField(
              controller: _loginController.emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h),
              child: _buildTextField(
                controller: _loginController.passwordController,
                label: 'Password',
                isPassword: true,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(bottom: 3.h),
                child: TextButton(
                  onPressed: _loginController.forgotPassword,
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Color(0xFFFFECD0),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 3.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      text: 'New Here? ',
                      style: const TextStyle(color: Color(0xFFFFECD0)),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: const TextStyle(
                            color: Color(0xFFFFECD0),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed('/register');
                            },
                        ),
                      ],
                    ),
                  ),
                  Obx(() {
                    return ElevatedButton(
                      onPressed: _loginController.isLoading.value
                          ? null
                          : () async {
                              await _loginController.login();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFF5E9),
                        foregroundColor: Colors.black87,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 6.w : 8.w,
                          vertical: 2.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _loginController.isLoading.value
                          ? const CircularProgressIndicator(
                              color: Colors.black87,
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(fontSize: 16),
                            ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_loginController.isPasswordVisible.value,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 4.w,
            vertical: 1.5.h,
          ),
          suffixIcon: isPassword
              ? Obx(() {
                  return IconButton(
                    icon: Icon(
                      _loginController.isPasswordVisible.value
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.white.withOpacity(0.7),
                    ),
                    onPressed: _loginController.togglePasswordVisibility,
                  );
                })
              : null,
        ),
      ),
    );
  }
}
