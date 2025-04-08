import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:get/get.dart';
import 'package:security/widgets/nav_bar.dart';
import '../controllers/alerts_controller.dart';

class AlertsPage extends StatelessWidget {
  final AlertsController controller = Get.put(AlertsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCEACD),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Nearby Disturbances'),
        backgroundColor: const Color(0xFFFCEACD),
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 10.h, left: 1.h, right: 1.h),
        child: Obx(
          () => ListView.builder(
            itemCount: controller.alerts.length,
            itemBuilder: (context, index) {
              final alert = controller.alerts[index];
              return Card(
                color: const Color(0xFFFCEACD),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Color(0xFFFF4D79), width: 0.2.w),
                ),
                borderOnForeground: true,
                margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
                child: ListTile(
                  leading: const Icon(Icons.location_on_outlined,
                      color: Color(0xFFFF4D79)),
                  title: Text('ALERT!!!',
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold)),
                  subtitle: Text('${alert['distance']}km, ${alert['time']}'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black54),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/connectNearby');
        },
        backgroundColor: const Color(0xFFFF4D79),
        child: const Icon(Icons.add_location_alt, color: Colors.white),
      ),
    );
  }
}
