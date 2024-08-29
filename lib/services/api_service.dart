// services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/series_model.dart';
import '../models/episode_model.dart';

class ApiService {
  // Fetch series data
  Future<List<Series>> fetchSeries() async {
    final response = await http.get(Uri.parse('https://short.anubisscan.xyz/api/get_series.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['series'] as List).map((item) => Series.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load series');
    }
  }

  // Fetch episodes data for a series
  Future<List<Episode>> fetchEpisodes(String seriesId) async {
    final response = await http.get(Uri.parse('https://short.anubisscan.xyz/api/get_episodes.php?id=$seriesId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['episodes'] as List).map((item) => Episode.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load episodes');
    }
  }
}
