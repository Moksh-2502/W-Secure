import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:security/controllers/auth_controller.dart';
import 'package:security/screens/home.dart';

class SocialLoginButtons extends StatelessWidget {
  final bool isSmallScreen;

  const SocialLoginButtons({Key? key, required this.isSmallScreen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonSize = isSmallScreen ? 45.0 : 55.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildSocialButton(
          onPressed: () async {
            try {
              await Get.find<AuthController>().loginWithGoogle();
              if (Get.find<AuthController>().isSignedIn.value) {
                Get.offAll(() => const HomePage());
              }
            } catch (e) {
              Get.snackbar(
                "Error",
                "Failed to sign in with Google",
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          },
          icon: 'assets/google_logo.png',
          size: buttonSize,
          iconSize: iconSize,
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          onPressed: () {
            // Handle Facebook login
          },
          icon: 'assets/facebook_logo.png',
          size: buttonSize,
          iconSize: iconSize,
        ),
        const SizedBox(width: 16),
        _buildSocialButton(
          onPressed: () {
            // Handle Apple login
          },
          icon: 'assets/apple_logo.png',
          size: buttonSize,
          iconSize: iconSize,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String icon,
    required double size,
    required double iconSize,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5E9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Image.asset(
          icon,
          width: iconSize,
          height: iconSize,
        ),
      ),
    );
  }
}
