import 'package:get/get.dart';

class PoliceStationsController extends GetxController {
  var policeStations = [
    {
      'name': 'Knowledge Park Police Station',
      'distance': 2,
      'contact': '8595902542'
    },
    {'name': 'Beta-2 Police Station', 'distance': 5, 'contact': '8595902541'},
    {
      'name': 'Ecotech-1 Police Station',
      'distance': 6,
      'contact': '8595902545'
    },
    {'name': 'Surajpur Police Station', 'distance': 7, 'contact': '8595902540'},
    {
      'name': 'Ecotech-3 Police Station',
      'distance': 8,
      'contact': '8595902548'
    },
    {'name': 'Bisrakh Police Station', 'distance': 10, 'contact': '8595902546'},
  ].obs;

  // Future implementation for fetching nearest police stations using map data
  // void fetchNearestPoliceStations() {
  //   // Map integration logic here
  // }
}
