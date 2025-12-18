import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../providers/weather_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final weatherProvider = context.watch<WeatherProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Paramètres"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 🌗 THÈME
          Card(
            child: SwitchListTile(
              title: const Text("Mode sombre"),
              subtitle: const Text("Activer / désactiver le thème sombre"),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
              secondary: const Icon(Icons.dark_mode),
            ),
          ),

          const SizedBox(height: 12),

          // ⭐ FAVORIS
          Card(
            child: ExpansionTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: const Text("Villes favorites"),
              subtitle: Text("${weatherProvider.favorites.length} ville(s)"),
              children: weatherProvider.favorites.isEmpty
                  ? const [
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          "Aucune ville favorite",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ]
                  : weatherProvider.favorites
                        .map(
                          (city) => ListTile(
                            title: Text(city),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                weatherProvider.removeFavorite(city);
                              },
                            ),
                          ),
                        )
                        .toList(),
            ),
          ),

          const SizedBox(height: 12),

          // 🧹 SUPPRIMER TOUS
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Supprimer tous les favoris"),
              onTap: () {
                weatherProvider.clearFavorites();
              },
            ),
          ),

          const SizedBox(height: 24),

          // ℹ️ INFOS
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("À propos"),
              subtitle: Text("WeatherNow v1.0.0"),
            ),
          ),
        ],
      ),
    );
  }
}
