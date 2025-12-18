import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';

class LocationsScreen extends StatelessWidget {
  const LocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Villes favorites"), centerTitle: true),
      body: provider.favorites.isEmpty
          ? const Center(
              child: Text(
                "Aucune ville favorite",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final city = provider.favorites[index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_city,
                      color: Colors.blue,
                    ),
                    title: Text(
                      city,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        provider.removeFavorite(city);
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      provider.fetchByCity(city);
                    },
                  ),
                );
              },
            ),
    );
  }
}
