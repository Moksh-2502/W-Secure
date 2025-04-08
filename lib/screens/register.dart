import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:security/controllers/register_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends GetView<RegisterController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Container(
                height: 100.h,
                width: 100.w,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/splash.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 15.h,
                        child: Image.asset('assets/logo.png'),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 3.h),
                        child: Text(
                          "Sign up",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                fontFamily: GoogleFonts.nunito().fontFamily,
                                color: const Color(0xFFFF3974),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 1.h),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: SizedBox(
                          width: 90.w,
                          child: TextField(
                            controller: controller.nameController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                            decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: TextStyle(
                                color: Colors.white54,
                                fontSize: 14.sp,
                              ),
                              filled: true,
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white54,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: SizedBox(
                          width: 90.w,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: controller.emailController,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Email Address",
                                  labelStyle: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14.sp,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black54,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.white54,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 3.w, top: 0.5.h),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: SizedBox(
                          width: 90.w,
                          child: TextField(
                            controller: controller.emergencyContactController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                            decoration: InputDecoration(
                              labelText: "Emergency Contact",
                              labelStyle: TextStyle(
                                color: Colors.white54,
                                fontSize: 14.sp,
                              ),
                              filled: true,
                              fillColor: Colors.black54,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(
                                Icons.contact_phone,
                                color: Colors.white54,
                                size: 20.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: SizedBox(
                          width: 90.w,
                          child: Obx(() => TextField(
                                controller: controller.passwordController,
                                obscureText:
                                    !controller.isPasswordVisible.value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Create a password",
                                  labelStyle: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14.sp,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black54,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.white54,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.isPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white54,
                                      size: 20.sp,
                                    ),
                                    onPressed:
                                        controller.togglePasswordVisibility,
                                  ),
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: SizedBox(
                          width: 90.w,
                          child: Obx(() => TextField(
                                controller:
                                    controller.confirmPasswordController,
                                obscureText:
                                    !controller.isConfirmPasswordVisible.value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Confirm password",
                                  labelStyle: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14.sp,
                                  ),
                                  filled: true,
                                  fillColor: Colors.black54,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Colors.white54,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      controller.isConfirmPasswordVisible.value
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white54,
                                      size: 20.sp,
                                    ),
                                    onPressed: controller
                                        .toggleConfirmPasswordVisibility,
                                  ),
                                ),
                              )),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 2.h),
                        child: SizedBox(
                          width: 90.w,
                          child: Row(
                            children: [
                              Obx(() => Transform.scale(
                                    scale: 1.2,
                                    child: Checkbox(
                                      value: controller.agreesToTerms.value,
                                      onChanged: (value) => controller
                                          .agreesToTerms.value = value ?? false,
                                      fillColor:
                                          WidgetStateProperty.resolveWith(
                                        (states) => states
                                                .contains(WidgetState.selected)
                                            ? const Color(0xFFFF3974)
                                            : Colors.white54,
                                      ),
                                    ),
                                  )),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                    ),
                                    children: [
                                      const TextSpan(
                                          text:
                                              "I've read and agree with the "),
                                      TextSpan(
                                        text: "Terms and Conditions",
                                        style:
                                            const TextStyle(color: Colors.blue),
                                        recognizer: controller.termsRecognizer,
                                      ),
                                      const TextSpan(text: " and the "),
                                      TextSpan(
                                        text: "Privacy Policy",
                                        style:
                                            const TextStyle(color: Colors.blue),
                                        recognizer:
                                            controller.privacyRecognizer,
                                      ),
                                      const TextSpan(text: "."),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: SizedBox(
                          width: 90.w,
                          height: 6.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              try {
                                await controller.register();
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .set({
                                    'name': controller.nameController.text,
                                    'email': controller.emailController.text,
                                    'emergencyContact': controller
                                        .emergencyContactController.text,
                                  }, SetOptions(merge: true));
                                }
                              } catch (e) {
                                Get.snackbar('Error', e.toString(),
                                    snackPosition: SnackPosition.BOTTOM);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFECD0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Proceed',
                              style: TextStyle(
                                color: Colors.black,
                                fontFamily: GoogleFonts.nunito().fontFamily,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
