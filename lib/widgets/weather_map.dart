import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class WeatherMap extends StatelessWidget {
  final double lat;
  final double lon;
  final String city;

  const WeatherMap({
    super.key,
    required this.lat,
    required this.lon,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        child: FlutterMap(
          options: MapOptions(initialCenter: LatLng(lat, lon), initialZoom: 10),
          children: [
            // 🗺️ OpenStreetMap tiles (FREE)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.weatherapp',
            ),

            // 📍 Marqueur ville
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lon),
                  width: 50,
                  height: 50,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 40,
                      ),
                      Text(
                        city,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
