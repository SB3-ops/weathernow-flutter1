import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  final String apiKey = "9d44432669534ddb316fe42bc50b8432";

  Future<Map<String, dynamic>> fetchWeather(String city) async {
    final uri = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=$apiKey&lang=fr",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Ville introuvable");
    }
  }

  Future<List<dynamic>> fetchForecast(String city) async {
    final uri = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?q=$city&units=metric&appid=$apiKey&lang=fr",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["list"];
    } else {
      throw Exception("Prévisions indisponibles");
    }
  }

  Future<Map<String, dynamic>> fetchWeatherByCoords(
    double lat,
    double lon,
  ) async {
    final uri = Uri.parse(
      "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey&lang=fr",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur GPS");
    }
  }

  Future<List<dynamic>> fetchForecastByCoords(double lat, double lon) async {
    final uri = Uri.parse(
      "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&units=metric&appid=$apiKey&lang=fr",
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body)["list"];
    } else {
      throw Exception("Prévisions GPS indisponibles");
    }
  }
}
