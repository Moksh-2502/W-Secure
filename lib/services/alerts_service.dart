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

      final encodedLocation = Uri.encodeComponent(location);
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$encodedLocation&format=json&limit=1'),
        headers: {
          'User-Agent': 'w_secure_app/1.0 (your_email@example.com)',
        },
      );

      if (response.statusCode != 200) {
        print('Nominatim API error: ${response.body}');
        throw Exception("Failed to fetch coordinates for the location.");
      }

      final List<dynamic> data = json.decode(response.body);
      if (data.isEmpty) {
        print('No results found for location: $location');
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
