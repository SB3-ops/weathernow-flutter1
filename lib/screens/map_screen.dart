import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    final lat = provider.weatherData?["coord"]?["lat"] ?? 34.0209;
    final lon = provider.weatherData?["coord"]?["lon"] ?? -6.8416;

    return Scaffold(
      appBar: AppBar(title: const Text("Carte météo"), centerTitle: true),
      body: FlutterMap(
        options: MapOptions(initialCenter: LatLng(lat, lon), initialZoom: 9),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.weather',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(lat, lon),
                width: 60,
                height: 60,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
