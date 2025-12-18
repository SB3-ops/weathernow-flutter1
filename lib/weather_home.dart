import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/weather_provider.dart';
import '../providers/theme_provider.dart';

import '../widgets/weather_background.dart';
import '../widgets/weather_hero.dart';
import '../widgets/hourly_weather_chart.dart';

import 'screens/locations_screen.dart';
import 'screens/map_screen.dart';

class WeatherHome extends StatefulWidget {
  const WeatherHome({super.key});

  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final TextEditingController cityController = TextEditingController();

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  void _search(WeatherProvider provider) {
    final city = cityController.text.trim();
    print("SEARCH CITY = $city");
    if (city.isEmpty) return;
    FocusScope.of(context).unfocus();
    provider.fetchByCity(city);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("WeatherNow"),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Villes favorites",
            icon: const Icon(Icons.location_on),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LocationsScreen()),
              );
            },
          ),
          IconButton(
            tooltip: "Carte météo",
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapScreen()),
              );
            },
          ),
          IconButton(
            tooltip: theme.isDark ? "Mode clair" : "Mode sombre",
            icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: theme.toggleTheme,
          ),
        ],
      ),

      // 🌈 FOND MÉTÉO DYNAMIQUE (jour / nuit)
      body: WeatherBackground(
        weather: provider.weatherData,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 🔍 Recherche ville
                TextField(
                  controller: cityController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(provider),
                  decoration: InputDecoration(
                    hintText: "Rechercher une ville",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Theme.of(context).cardColor.withOpacity(0.9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ⭐ Favoris
                if (provider.favorites.isNotEmpty)
                  SizedBox(
                    height: 42,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: provider.favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final city = provider.favorites[i];
                        return ActionChip(
                          avatar: const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          label: Text(city),
                          onPressed: () {
                            cityController.text = city;
                            provider.fetchByCity(city);
                          },
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 12),

                // 🎯 Boutons action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _search(provider),
                      child: const Text("Rechercher"),
                    ),
                    ElevatedButton.icon(
                      onPressed: provider.fetchByLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text("Ma position"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ⏳ Chargement
                if (provider.loading)
                  const CircularProgressIndicator()
                // 🌤️ Données météo
                else if (provider.weatherData != null)
                  Expanded(
                    child: ListView(
                      children: [
                        // 🌤️ HERO
                        WeatherHero(weather: provider.weatherData!),

                        const SizedBox(height: 24),

                        // ⏰ PRÉVISIONS HORAIRES
                        if (provider.forecastData != null) ...[
                          const Text(
                            "Prévisions horaires",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.forecastData!.length > 8
                                  ? 8
                                  : provider.forecastData!.length,
                              itemBuilder: (_, i) {
                                final item = provider.forecastData![i];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          item["dt_txt"].substring(11, 16),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Image.network(
                                          "https://openweathermap.org/img/wn/${item["weather"][0]["icon"]}@2x.png",
                                          width: 42,
                                        ),
                                        Text("${item["main"]["temp"]} °C"),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 📈 Courbe température
                          HourlyWeatherChart(forecast: provider.forecastData!),
                        ],

                        const SizedBox(height: 28),

                        // 📅 PRÉVISIONS 5 JOURS (CORRIGÉES)
                        if (provider.forecastData != null) ...[
                          const Text(
                            "Prévisions 5 jours",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Column(
                            children: provider
                                .buildDailyForecast(provider.forecastData!)
                                .map((day) {
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: ListTile(
                                      leading: Image.network(
                                        "https://openweathermap.org/img/wn/${day["icon"]}@2x.png",
                                        width: 42,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.cloud),
                                      ),
                                      title: Text(
                                        day["date"].substring(5),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      trailing: Text(
                                        "${day["temp"]} °C",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  )
                // ❌ Aucune donnée
                else
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      "Entrez une ville ou utilisez votre position",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
