import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:security/services/alerts_service.dart';
import 'package:geocoding/geocoding.dart';

class ConnectNearbyController extends GetxController {
  final AlertsService _alertsService = AlertsService();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeFromController = TextEditingController();
  final TextEditingController timeToController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
  var locationSuggestions = <String>[].obs;
  var isSnackbarShown = false;

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      locationController.text =
          'Lat: ${position.latitude}, Long: ${position.longitude}';
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> saveAlert() async {
    try {
      final DateTime timeFrom =
          dateFormat.parse(timeFromController.text.replaceAll('/', '-'));
      final DateTime timeTo =
          dateFormat.parse(timeToController.text.replaceAll('/', '-'));

      await _alertsService.saveAlert(
        location: locationController.text,
        timeFrom: timeFrom.toIso8601String(),
        timeTo: timeTo.toIso8601String(),
        message: messageController.text,
      );

      Get.snackbar('Success', 'Alert saved successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Invalid date format. Use DD-MM-YYYY.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> fetchLocationSuggestions(String query) async {
    try {
      print('Fetching location suggestions for query: $query');
      if (query.isEmpty) {
        locationSuggestions.clear();
        return;
      }

      List<Location> locations = await locationFromAddress(query);
      if (locations.isEmpty) {
        throw Exception('No results found for the supplied address.');
      }

      locationSuggestions.value =
          await Future.wait(locations.map((location) async {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          location.latitude,
          location.longitude,
        );
        return placemarks.first.name ?? 'Unknown location';
      }));
      isSnackbarShown =
          false; 
    } catch (e) {
      print('Error fetching location suggestions: $e');
      locationSuggestions.clear();
      if (!isSnackbarShown) {
        Get.snackbar('Notice', 'Try using the locator.',
            snackPosition: SnackPosition.BOTTOM);
        isSnackbarShown =
            true; 
      }
    }
  }

  void selectLocation(String location) {
    locationController.text = location;
    locationSuggestions.clear();
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    isSnackbarShown = false; 
  }
}
