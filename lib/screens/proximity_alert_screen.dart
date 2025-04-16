import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:security/controllers/proximity_alert_controller.dart';
import 'package:security/widgets/nav_bar.dart';
import 'dart:ui' as ui;

class ProximityAlertScreen extends GetView<ProximityAlertController> {
  const ProximityAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEACD),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Proximity Alerts', 
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold
          )
        ),
        backgroundColor: const Color(0xFFFFE4D0),
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            icon: Icon(
              controller.isSoundEnabled.value 
                ? Icons.volume_up 
                : Icons.volume_off,
              color: controller.isSoundEnabled.value 
                ? const Color(0xFFFF4D79) 
                : Colors.grey,
            ),
            onPressed: controller.toggleSound,
            tooltip: controller.isSoundEnabled.value 
              ? 'Sound On' 
              : 'Sound Off',
          )),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFE4D0),
              const Color(0xFFFCEACD),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAlertButton(),
              SizedBox(height: 3.h),
              _buildNearbyAlertsSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildAlertButton() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Send Alert',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF4D79),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: controller.isTracking.value ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: controller.isTracking.value ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.isTracking.value ? Icons.location_on : Icons.location_off,
                    color: controller.isTracking.value ? Colors.green : Colors.red,
                    size: 14.sp,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    controller.isTracking.value ? 'Tracking Active' : 'Tracking Inactive',
                    style: TextStyle(
                      color: controller.isTracking.value ? Colors.green : Colors.red,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller.alertMessageController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter alert message (optional)',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.all(3.w),
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 7.h,
                decoration: BoxDecoration(
                  color: controller.isAlertActive.value
                      ? Colors.grey
                      : controller.isProcessing.value
                          ? const Color(0xFFFF4D79).withOpacity(0.7)
                          : const Color(0xFFFF4D79),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF4D79).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: controller.isAlertActive.value
                        ? controller.cancelAlert
                        : controller.isProcessing.value
                            ? null
                            : controller.sendAlert,
                    child: Center(
                      child: controller.isProcessing.value && !controller.isAlertActive.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              controller.isAlertActive.value
                                  ? 'Cancel Alert'
                                  : 'Send Alert',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            AnimatedBuilder(
              animation: controller.alertButtonScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: controller.isAlertActive.value ? 1.0 : controller.alertButtonScale.value,
                  child: Container(
                    height: 7.h,
                    width: 30.w,
                    decoration: BoxDecoration(
                      color: controller.isAlertActive.value
                          ? Colors.grey
                          : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: controller.isAlertActive.value || controller.isProcessing.value
                            ? null
                            : controller.sendSOSAlert,
                        child: Center(
                          child: controller.isProcessing.value && !controller.isAlertActive.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.white,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      'SOS',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(height: 2.h),
        if (controller.isAlertActive.value)
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF4CAF50)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Your alert is active. Nearby users will be notified of your location.',
                    style: TextStyle(
                      color: const Color(0xFF4CAF50),
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ));
  }

  Widget _buildNearbyAlertsSection() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4D79).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Alerts',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFF4D79),
                  ),
                ),
                Obx(() => Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.nearbyAlerts.length} ${controller.nearbyAlerts.length == 1 ? "Alert" : "Alerts"}',
                    style: TextStyle(
                      color: const Color(0xFFFF4D79),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Expanded(
            child: Obx(() {
              if (controller.nearbyAlerts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 50.sp,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'No alerts in your area',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'You will be notified when someone nearby needs help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.7),
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                itemCount: controller.nearbyAlerts.length,
                itemBuilder: (context, index) {
                  final alert = controller.nearbyAlerts[index];
                  final bool isEmergency = alert['isEmergency'] == true;
                  
                  return Hero(
                    tag: 'alert_${alert['id']}',
                    child: Container(
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: isEmergency 
                                ? Colors.red.withOpacity(0.2) 
                                : const Color(0xFFFF4D79).withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(
                          color: isEmergency 
                              ? Colors.red 
                              : const Color(0xFFFF4D79),
                          width: isEmergency ? 2 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              // Navigate to map with this alert location
                              Get.toNamed('/map', arguments: {
                                'alertLocation': alert['location'],
                                'alertId': alert['id'],
                                'alertData': alert,
                              });
                            },
                            child: Column(
                              children: [
                                if (isEmergency)
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                    color: Colors.red,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: Colors.white,
                                          size: 14.sp,
                                        ),
                                        SizedBox(width: 1.w),
                                        Text(
                                          'EMERGENCY',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.all(3.w),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 6.w,
                                        backgroundColor: isEmergency 
                                            ? Colors.red 
                                            : const Color(0xFFFF4D79),
                                        child: alert['photoUrl'] != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(6.w),
                                                child: Image.network(
                                                  alert['photoUrl'],
                                                  width: 12.w,
                                                  height: 12.w,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.person,
                                                      color: Colors.white,
                                                      size: 6.w,
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.person,
                                                color: Colors.white,
                                                size: 6.w,
                                              ),
                                      ),
                                      SizedBox(width: 3.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              alert['userName'] ?? 'Anonymous',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                                color: isEmergency 
                                                    ? Colors.red 
                                                    : const Color(0xFFFF4D79),
                                              ),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(
                                              alert['message'] ?? 'Emergency alert',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 1.h),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 12.sp,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 0.5.w),
                                                Text(
                                                  controller.formatTimestamp(alert['timestamp']),
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                                SizedBox(width: 2.w),
                                                Icon(
                                                  Icons.location_on,
                                                  size: 12.sp,
                                                  color: Colors.grey,
                                                ),
                                                SizedBox(width: 0.5.w),
                                                Text(
                                                  '${alert['distance']} km away',
                                                  style: TextStyle(
                                                    fontSize: 12.sp,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: isEmergency 
                                              ? Colors.red.withOpacity(0.1) 
                                              : const Color(0xFFFF4D79).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        padding: EdgeInsets.all(2.w),
                                        child: Icon(
                                          Icons.navigation_outlined,
                                          color: isEmergency 
                                              ? Colors.red 
                                              : const Color(0xFFFF4D79),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
  }
}
