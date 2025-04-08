import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:security/widgets/nav_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? userPos;

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _determinePosition().then((value) {
        setState(() {
          userPos = LatLng(value.latitude, value.longitude);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const styleUrl =
        "https://tiles.stadiamaps.com/tiles/alidade_smooth/{z}/{x}/{y}{r}.png"; // Updated to light mode style
    const apiKey = "a1e9793d-bed4-4986-949c-24f3abf9e654";
    return userPos == null
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            bottomNavigationBar: BottomNavBar(),
            extendBody: true,
            body: FlutterMap(
              options: MapOptions(
                  initialCenter: userPos!,
                  initialZoom:
                      15, 
                  keepAlive: true),
              children: [
                TileLayer(
                  urlTemplate: "$styleUrl?api_key={api_key}",
                  additionalOptions: {"api_key": apiKey},
                  maxZoom: 20,
                  maxNativeZoom: 20,
                ),
                CurrentLocationLayer(
                    alignPositionOnUpdate: AlignOnUpdate.always,
                    alignDirectionOnUpdate: AlignOnUpdate.always,
                    style: LocationMarkerStyle(
                      marker: const DefaultLocationMarker(
                        child: Icon(
                          Icons.navigation,
                          color: Colors.white,
                        ),
                      ),
                      markerSize: const Size(30, 30),
                      markerDirection: MarkerDirection.heading,
                    )),
                MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                  builder: (context, markers) => Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  maxClusterRadius: 45,
                  size: const Size(40, 40),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(50),
                  maxZoom: 15,
                  markers: [
                    Marker(
                        point: LatLng(28.453511131201953, 77.52568658088984),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                        )),
                    Marker(
                        point: LatLng(28.451916602494208, 77.50955442506789),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.green,
                        )),
                  ],
                )),
              ],
            ),
          );
  }
}
