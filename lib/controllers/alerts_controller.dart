import 'package:get/get.dart';

class AlertsController extends GetxController {
  var alerts = [
    {'distance': 3, 'time': '2:00pm'},
    {'distance': 5, 'time': '2:30pm'},
    {'distance': 7, 'time': '2:15pm'},
    {'distance': 9, 'time': '2:24pm'},
  ].obs;

  // Future implementation for BluetoothNet functionality
  // This will scan for alerts within a 100m radius and update the alerts list dynamically.
  // void fetchBluetoothAlerts() {
  //   // BluetoothNet logic here
  // }
}
