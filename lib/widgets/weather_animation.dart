import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WeatherAnimation extends StatelessWidget {
  final Map<String, dynamic>? weather;

  const WeatherAnimation({super.key, required this.weather});

  String _backgroundLottie(Map<String, dynamic>? weather) {
    if (weather == null) {
      return "assets/lottie/Uploading to cloud.json";
    }

    final icon = weather["weather"]?[0]?["icon"] ?? "";

    if (icon.startsWith("01")) {
      return "assets/lottie/Weather-sunny.json";
    }
    if (icon.startsWith("09") || icon.startsWith("10")) {
      return "assets/lottie/Rainy.json";
    }
    if (icon.startsWith("11")) {
      return "assets/lottie/Weather-storm.json";
    }
    if (icon.startsWith("13")) {
      return "assets/lottie/Weather-snow.json";
    }

    return "assets/lottie/Uploading to cloud.json";
  }

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      _backgroundLottie(weather),
      fit: BoxFit.cover,
      repeat: true,
    );
  }
}
