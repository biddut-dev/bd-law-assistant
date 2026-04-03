import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Using Production Render Cloud Backend
  static const String baseUrl = 'https://bd-law-assistant.onrender.com/api';

  static Future<Map<String, dynamic>> askLaw(String question, bool inBengali) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ask-law'),
        headers: {
          'Content-Type': 'application/json',
          'Bypass-Tunnel-Reminder': 'true'
        },
        body: jsonEncode({
          'question': question,
          'language': inBengali ? 'bengali' : 'english'
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get answer');
      }
    } catch (e) {
      throw Exception('Server error: $e');
    }
  }

  static Future<List<dynamic>> searchLaw({String? keyword, String? act, String? section}) async {
    try {
      final queryParams = <String, String>{};
      if (keyword != null && keyword.isNotEmpty) queryParams['keyword'] = keyword;
      if (act != null && act.isNotEmpty) queryParams['act'] = act;
      if (section != null && section.isNotEmpty) queryParams['section'] = section;

      final uri = Uri.parse('$baseUrl/search-law').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: {'Bypass-Tunnel-Reminder': 'true'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to search');
      }
    } catch (e) {
      throw Exception('Server error: $e');
    }
  }
}
