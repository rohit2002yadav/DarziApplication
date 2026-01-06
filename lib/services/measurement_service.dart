import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tailor_service.dart';

class MeasurementService {
  static Future<List<Map<String, dynamic>>> addProfile(String phone, Map<String, dynamic> profile) async {
    final response = await http.post(
      Uri.parse("${TailorService.baseUrl}/auth/measurements"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "profile": profile}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to add measurement profile");
    }
  }

  static Future<List<Map<String, dynamic>>> deleteProfile(String phone, String profileId) async {
    final response = await http.delete(
      Uri.parse("${TailorService.baseUrl}/auth/measurements/$phone/$profileId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      return List<Map<String, dynamic>>.from(data);
    } else {
      throw Exception("Failed to delete measurement profile");
    }
  }
}
