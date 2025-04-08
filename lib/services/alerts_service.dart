import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AlertsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveAlert({
    required String location,
    required String timeFrom,
    required String timeTo,
    required String message,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      // Fetch coordinates from Nominatim API
      final response = await http.get(Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$location&format=json&limit=1'));

      if (response.statusCode != 200) {
        throw Exception("Failed to fetch coordinates for the location.");
      }

      final List<dynamic> data = json.decode(response.body);
      if (data.isEmpty) {
        throw Exception("No results found for the location.");
      }

      final double latitude = double.parse(data[0]['lat']);
      final double longitude = double.parse(data[0]['lon']);
      GeoPoint geoPoint = GeoPoint(latitude, longitude);

      final DateTime parsedTimeFrom = DateTime.parse(timeFrom);
      final DateTime parsedTimeTo = DateTime.parse(timeTo);

      final alertData = {
        'Location': geoPoint,
        'TimeFrom': Timestamp.fromDate(parsedTimeFrom),
        'TimeTo': Timestamp.fromDate(parsedTimeTo),
        'Message': message,
      };

      await _firestore
          .collection('alerts')
          .doc(user.uid)
          .set(alertData, SetOptions(merge: true));

      print('Alert saved successfully: $alertData');
    } catch (e) {
      print('Failed to save alert: $e');
      throw Exception("Failed to save alert: $e");
    }
  }
}
