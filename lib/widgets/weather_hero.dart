import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/weather_animation.dart';

class WeatherHero extends StatelessWidget {
  final Map<String, dynamic> weather;

  const WeatherHero({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final provider = context.watch<WeatherProvider>();
    final city = (weather["name"] ?? "").toString();
    final isFav = provider.isFavorite(city);

    final temp = (weather["main"]?["temp"] as num?)?.round() ?? 0;
    final feels = (weather["main"]?["feels_like"] as num?)?.round() ?? 0;
    final min = (weather["main"]?["temp_min"] as num?)?.round() ?? 0;
    final max = (weather["main"]?["temp_max"] as num?)?.round() ?? 0;

    final description = (weather["weather"]?[0]?["description"] ?? "")
        .toString()
        .toUpperCase();

    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
        ),
      ),
      child: Stack(
        children: [
          // 🌌 BACKGROUND ANIMATION (subtle)
          Positioned.fill(
            child: Opacity(
              opacity: 0.12,
              child: WeatherAnimation(weather: weather),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📍 CITY + ❤️ FAVORITE BUTTON
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        city,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    IconButton(
                      tooltip: isFav
                          ? "Retirer des favoris"
                          : "Ajouter aux favoris",
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFav),
                          color: isFav ? Colors.red : Colors.white,
                        ),
                      ),
                      onPressed: city.isEmpty
                          ? null
                          : () => provider.toggleFavorite(city),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // 🌡️ TEMP + MAIN ANIMATION
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "$temp°",
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 72,
                        height: 1,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: WeatherAnimation(weather: weather),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // 🌥️ DESCRIPTION
                Text(
                  description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                // ⬆️⬇️ EXTRA INFOS
                Row(
                  children: [
                    _infoChip("↑ $max°"),
                    const SizedBox(width: 12),
                    _infoChip("↓ $min°"),
                    const SizedBox(width: 12),
                    _infoChip("Ressenti $feels°"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 💊 INFO CHIP
  Widget _infoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
