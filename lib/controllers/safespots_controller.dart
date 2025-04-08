import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SafespotsController extends GetxController {
  var safeSpots = [
    {
      'name': 'Omaxe Connaught Place Mall',
      'distance': 3,
      'contact': '01204567890',
      'openingTime': TimeOfDay(hour: 10, minute: 0),
      'closingTime': TimeOfDay(hour: 22, minute: 0),
    },
    {
      'name': 'Yatharth Super Speciality Hospital',
      'distance': 5,
      'contact': '01204561234',
      'openingTime': TimeOfDay(hour: 0, minute: 0),
      'closingTime': TimeOfDay(hour: 23, minute: 59),
    },
    {
      'name': 'Gaur City Mall',
      'distance': 8,
      'contact': '01204567891',
      'openingTime': TimeOfDay(hour: 10, minute: 0),
      'closingTime': TimeOfDay(hour: 22, minute: 0),
    },
    {
      'name': 'Sharda Hospital',
      'distance': 6,
      'contact': '01204567892',
      'openingTime': TimeOfDay(hour: 0, minute: 0),
      'closingTime': TimeOfDay(hour: 23, minute: 59),
    },
  ].obs;

  String getStatus(Map<String, dynamic> spot) {
    final now = TimeOfDay.now();
    final openingTime = spot['openingTime'] as TimeOfDay;
    final closingTime = spot['closingTime'] as TimeOfDay;

    final nowMinutes = now.hour * 60 + now.minute;
    final openingMinutes = openingTime.hour * 60 + openingTime.minute;
    final closingMinutes = closingTime.hour * 60 + closingTime.minute;

    if (nowMinutes >= openingMinutes && nowMinutes <= closingMinutes) {
      return 'Open';
    } else {
      return 'Closed';
    }
  }

  Color getStatusColor(Map<String, dynamic> spot) {
    return getStatus(spot) == 'Open' ? Colors.green : Colors.red;
  }

  // Future implementation for fetching nearest police stations using map data
  // void fetchNearestPoliceStations() {
  //   // Map integration logic here
  // }
}
