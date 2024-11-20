import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BackgroundPage extends StatelessWidget {
  final Widget child;
  final Color primaryColor;
  final Color secondaryColor;

  const BackgroundPage({
    super.key,
    required this.child,
    this.primaryColor = const Color(0xFFFF3974),
    this.secondaryColor = const Color(0xFFFFECD0),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      width: 100.w,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/splash.png',
              ),
              fit: BoxFit.cover)),
      child: Scaffold(backgroundColor: Colors.transparent, body: child),
    );
  }
}
