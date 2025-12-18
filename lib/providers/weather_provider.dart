import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WeatherProvider extends ChangeNotifier {
  // ===============================
  // 🔑 CONFIG API
  // ===============================
  static const String _apiKey = "9d44432669534ddb316fe42bc50b8432";
  static const String _baseUrl = "https://api.openweathermap.org/data/2.5";

  // ===============================
  // 🌤 DATA
  // ===============================
  Map<String, dynamic>? weatherData;
  List<dynamic>? forecastData;

  bool loading = false;

  // ===============================
  // ⭐ FAVORIS (persistés)
  // ===============================
  List<String> favorites = [];
  Future<void> loadLastCity() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString("last_city");
    if (lastCity != null) {
      await fetchByCity(lastCity);
    }
  }

  WeatherProvider() {
    _loadFavorites();
  }

  // ===============================
  // 🔍 FETCH BY CITY
  // ===============================
  Future<void> fetchByCity(String city) async {
    loading = true;
    notifyListeners();

    try {
      final weatherRes = await http.get(
        Uri.parse(
          "$_baseUrl/weather?q=$city&appid=$_apiKey&units=metric&lang=fr",
        ),
      );

      final forecastRes = await http.get(
        Uri.parse(
          "$_baseUrl/forecast?q=$city&appid=$_apiKey&units=metric&lang=fr",
        ),
      );

      if (weatherRes.statusCode == 200 && forecastRes.statusCode == 200) {
        weatherData = json.decode(weatherRes.body);
        forecastData = json.decode(forecastRes.body)["list"];
      }
    } catch (e) {
      debugPrint("Weather error: $e");
    }

    loading = false;
    notifyListeners();
  }

  // ===============================
  // 📍 FETCH BY LOCATION
  // ===============================
  Future<void> fetchByLocation() async {
    loading = true;
    notifyListeners();

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final weatherRes = await http.get(
        Uri.parse(
          "$_baseUrl/weather?lat=${pos.latitude}&lon=${pos.longitude}&appid=$_apiKey&units=metric&lang=fr",
        ),
      );

      final forecastRes = await http.get(
        Uri.parse(
          "$_baseUrl/forecast?lat=${pos.latitude}&lon=${pos.longitude}&appid=$_apiKey&units=metric&lang=fr",
        ),
      );

      if (weatherRes.statusCode == 200 && forecastRes.statusCode == 200) {
        weatherData = json.decode(weatherRes.body);
        forecastData = json.decode(forecastRes.body)["list"];
      }
    } catch (e) {
      debugPrint("Location error: $e");
    }

    loading = false;
    notifyListeners();
  }

  // ===============================
  // ⭐ FAVORIS LOGIC
  // ===============================
  bool isFavorite(String city) {
    return favorites.contains(city);
  }

  void toggleFavorite(String city) {
    if (favorites.contains(city)) {
      favorites.remove(city);
    } else {
      favorites.add(city);
    }
    _saveFavorites();
    notifyListeners();
  }

  void addFavorite(String city) {
    if (!favorites.contains(city)) {
      favorites.add(city);
      _saveFavorites();
      notifyListeners();
    }
  }

  void removeFavorite(String city) {
    favorites.remove(city);
    _saveFavorites();
    notifyListeners();
  }

  void clearFavorites() {
    favorites.clear();
    _saveFavorites();
    notifyListeners();
  }

  // ===============================
  // 💾 PERSISTENCE
  // ===============================
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favorites", favorites);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = prefs.getStringList("favorites") ?? [];
    notifyListeners();
  }

  // ===============================
  // 📅 BUILD 5 DAYS FORECAST
  // ===============================
  List<Map<String, dynamic>> buildDailyForecast(List<dynamic> list) {
    final Map<String, Map<String, dynamic>> days = {};

    for (final item in list) {
      final date = item["dt_txt"].substring(0, 10);

      if (!days.containsKey(date)) {
        days[date] = {
          "date": date,
          "temp": (item["main"]["temp"] as num).round(),
          "icon": item["weather"][0]["icon"],
        };
      }
    }

    return days.values.take(5).toList();
  }
}
