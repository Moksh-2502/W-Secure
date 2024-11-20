// app/views/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../controllers/home_controller.dart';
import '../widgets/nav_bar.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE4D0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              SizedBox(height: 4.h),
              const Text(
                'SOS',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3.h),
              Icon(
                Icons.shield_outlined,
                size: 15.w,
                color: Colors.black87,
              ),
              SizedBox(height: 5.h),
              _buildButton(
                'Call Nearest Police Station',
                controller.makeEmergencyCall,
              ),
              SizedBox(height: 2.h),
              _buildButton(
                'Share Live Location',
                controller.shareLocation,
              ),
              SizedBox(height: 2.h),
              Obx(() => _buildButton(
                    controller.isRecording.value
                        ? 'Stop Recording'
                        : 'Take A Video',
                    controller.toggleVideoRecording,
                  )),
              const Spacer(),
              BottomNavBar(
                selectedIndex: 0,
                onItemTapped: (index) {
                  // Handle navigation if needed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D79),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
