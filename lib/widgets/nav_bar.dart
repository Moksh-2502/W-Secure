import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';

class BottomNavBar extends GetView<NavigationController> {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: const BoxDecoration(
          color: Color(0xFFFF4D79),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.coffee_outlined, 0, 'Home'),
            // _buildNavItem(Icons.shield_outlined, 1, 'SOS'),
            // _buildNavItem(Icons.book_outlined, 2, 'Book'),
            _buildNavItem(Icons.map_outlined, 3, 'Map'),
            _buildNavItem(Icons.person_outline, 4, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE4D0),
            shape: BoxShape.circle,
            border: controller.selectedIndex == index
                ? Border.all(color: Colors.black26, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            size: 6.w,
            color: controller.selectedIndex == index
                ? Colors.black87
                : Colors.black54,
          ),
        ),
      ),
    );
  }
}
