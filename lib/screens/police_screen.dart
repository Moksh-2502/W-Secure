import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:get/get.dart';
import 'package:security/widgets/nav_bar.dart';
import '../controllers/police_stations_controller.dart';

class PoliceStationsPage extends StatelessWidget {
  final PoliceStationsController controller =
      Get.put(PoliceStationsController());

   PoliceStationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
          centerTitle: true,
          title: const Text('Police Stations',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          backgroundColor: const Color(0xFFFFE4D0),
          elevation: 0,
        ),
      ),
      backgroundColor: const Color(0xFFFFE4D0),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.policeStations.length,
          itemBuilder: (context, index) {
            final station = controller.policeStations[index];
            return Card(
              color: const Color(0xFFFFE4D0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFF4D79), width: 2),
              ),
              margin: EdgeInsets.symmetric(vertical: 1.h, horizontal: 2.h),
              child: ListTile(
                leading:
                    const Icon(Icons.location_on, color: Color(0xFFFF4D79)),
                title: Text(station['name'] as String,
                    style: const TextStyle(
                        color: Color(0xFFFF4D79),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
                subtitle:
                    Text('${station['distance']}km, ${station['contact']}'),
                trailing:
                    const Icon(Icons.arrow_forward_ios, color: Colors.black54),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
