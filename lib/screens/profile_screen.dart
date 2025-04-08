import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:get/get.dart';
import 'package:security/controllers/profile_controller.dart';
import 'package:security/widgets/nav_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find();
    return Scaffold(
      backgroundColor: const Color(0xFFFCEACD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(fontSize: 20.sp, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(5.h),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(() {
                        return CircleAvatar(
                          backgroundImage:
                              controller.profilePictureUrl.value != ''
                                  ? FileImage(
                                      File(controller.profilePictureUrl.value))
                                  : const AssetImage('assets/avatar.png')
                                      as ImageProvider,
                          radius: 10.h,
                        );
                      }),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.pinkAccent),
                        onPressed: controller.pickProfilePicture,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Obx(() {
                    final nameController =
                        TextEditingController(text: controller.name.value)
                          ..selection = TextSelection.collapsed(
                              offset: controller.name.value.length);
                    return TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        controller.name.value = value;
                      },
                      onSubmitted: (value) {
                        controller.updateName(value);
                      },
                    );
                  }),
                ),
                Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Obx(() => TextField(
                        enabled: false,
                        controller:
                            TextEditingController(text: controller.email.value),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      )),
                ),
                Padding(
                  padding: EdgeInsets.all(2.h),
                  child: Obx(() {
                    final phoneController = TextEditingController(
                        text: controller.phoneNumber.value)
                      ..selection = TextSelection.collapsed(
                          offset: controller.phoneNumber.value.length);
                    return TextField(
                      controller: phoneController,
                      decoration: InputDecoration(
                        labelText: 'Emergency No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      onChanged: (value) {
                        controller.phoneNumber.value = value;
                      },
                      onSubmitted: (value) {
                        controller.updatePhoneNumber(value);
                      },
                    );
                  }),
                ),
                SizedBox(height: 3.h),
                Obx(() {
                  final isEdited =
                      controller.name.value != controller.originalName ||
                          controller.phoneNumber.value !=
                              controller.originalPhoneNumber;

                  return isEdited
                      ? ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            padding: EdgeInsets.symmetric(
                                horizontal: 20.w, vertical: 1.5.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await controller.updateProfile();
                            controller.originalName.value =
                                controller.name.value;
                            controller.originalPhoneNumber.value =
                                controller.phoneNumber.value;
                            controller.name.refresh();
                            controller.phoneNumber.refresh();
                            Get.snackbar(
                                'Success', 'Profile updated successfully');
                          },
                          child: Text(
                            'Save',
                            style:
                                TextStyle(fontSize: 16.sp, color: Colors.white),
                          ),
                        )
                      : SizedBox.shrink();
                }),
                SizedBox(height: 0.5.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 1.5.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Get.offAllNamed('/login');
                  },
                  child: Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
