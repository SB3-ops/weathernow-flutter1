import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';

class WeatherHeader extends StatelessWidget {
  final Map<String, dynamic> weather;

  const WeatherHeader({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();

    final city = weather["name"]?.toString() ?? "";
    final temp = weather["main"]?["temp"];
    final desc =
        weather["weather"]?[0]?["description"]?.toString().toUpperCase() ?? "";
    final icon = weather["weather"]?[0]?["icon"]?.toString() ?? "";

    final isFav = provider.isFavorite(city);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withAlpha(230), // ~90%
            Theme.of(context).colorScheme.secondary.withAlpha(150),
          ],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🌤️ Infos météo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white70,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${temp is num ? temp.round() : temp}°",
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          // ❤️ FAVORI
          Column(
            children: [
              IconButton(
                tooltip: isFav ? "Retirer des favoris" : "Ajouter aux favoris",
                onPressed: () => provider.toggleFavorite(city),
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(isFav),
                    color: isFav ? Colors.redAccent : Colors.white,
                    size: 30,
                  ),
                ),
              ),
              if (icon.isNotEmpty)
                Image.network(
                  "https://openweathermap.org/img/wn/$icon@2x.png",
                  width: 72,
                  height: 72,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
