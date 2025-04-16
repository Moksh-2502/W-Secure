import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:security/widgets/nav_bar.dart';
import '../controllers/safespots_controller.dart';

class SafeSpotsPage extends StatelessWidget {
  final SafespotsController controller = Get.put(SafespotsController());

   SafeSpotsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(15.h),
        child: AppBar(
          centerTitle: true,
          title: const Text('Safe Spots',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          backgroundColor: const Color(0xFFFFE4D0),
          elevation: 0,
        ),
      ),
      backgroundColor: const Color(0xFFFCEACD),
      bottomNavigationBar: const BottomNavBar(),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.safeSpots.length,
          itemBuilder: (context, index) {
            final spot = controller.safeSpots[index];
            return Card(
              color: const Color(0xFFFFE4D0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                    color: controller.getStatusColor(spot), width: 2),
              ),
              margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
              child: ListTile(
                leading: Icon(Icons.location_on_outlined,
                    color: controller.getStatusColor(spot)),
                title: Text(spot['name'] as String,
                    style: const TextStyle(
                        color: Color(0xFFFF4D79),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                subtitle: Text('${spot['distance']}km, ${spot['contact']}'),
                trailing: Text(
                  controller.getStatus(spot),
                  style: TextStyle(
                    color: controller.getStatusColor(spot),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
