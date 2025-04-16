import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:get/get.dart';
import 'package:security/controllers/connect_nearby_controller.dart';

class ConnectNearbyPage extends StatelessWidget {
  final ConnectNearbyController controller = Get.put(ConnectNearbyController());

  ConnectNearbyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEACD),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCEACD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Connect nearby',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(4.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: controller.locationController,
                    onChanged: controller.fetchLocationSuggestions,
                    decoration: InputDecoration(
                      hintText: 'Enter location',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.my_location,
                            color: Color(0xFFFF4D79)),
                        onPressed: controller.getCurrentLocation,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  Obx(() => Container(
                        decoration: BoxDecoration(
                          color: Colors.pinkAccent,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.locationSuggestions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                controller.locationSuggestions[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                controller.locationController.text =
                                    controller.locationSuggestions[index];
                                controller.locationSuggestions.clear();
                              },
                            );
                          },
                        ),
                      )),
                ],
              ),
              SizedBox(height: 3.h),
              const Text('Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 1.h),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.timeFromController,
                      decoration: InputDecoration(
                        hintText: 'From (DD-MM-YYYY)',
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  SizedBox(width: 2.h),
                  Expanded(
                    child: TextField(
                      controller: controller.timeToController,
                      decoration: InputDecoration(
                        hintText: 'To (DD-MM-YYYY)',
                        suffixIcon: const Icon(Icons.calendar_today,
                            color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              const Text('Message',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 1.h),
              TextField(
                controller: controller.messageController,
                maxLines: 12,
                decoration: InputDecoration(
                  hintText: 'Enter your message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 4.h),
              Center(
                child: ElevatedButton(
                  onPressed: controller.saveAlert,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4D79),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  ),
                  child: const Text('SEND',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
