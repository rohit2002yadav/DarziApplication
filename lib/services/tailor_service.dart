import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class TailorService {
  static const String baseUrl =
      "https://darziapplication.onrender.com/api";

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<String?> _tailorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }

  /* -------------------- CREATE ORDER -------------------- */
  static Future<Map<String, dynamic>> postOrder(
      Map<String, dynamic> orderData) async {
    final response = await http
        .post(
      Uri.parse("$baseUrl/orders"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(orderData),
    )
        .timeout(const Duration(seconds: 60));

    if (!response.headers['content-type']!
        .contains("application/json")) {
      throw Exception("Server returned non-JSON response");
    }

    return jsonDecode(response.body);
  }

  /* -------------------- GET TAILOR ORDERS -------------------- */
  static Future<List<Order>> getTailorOrders(String status) async {
    final token = await _token();
    final tailorId = await _tailorId();

    final response = await http
        .get(
      Uri.parse(
          "$baseUrl/orders/tailor?tailorId=$tailorId&status=$status"),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    )
        .timeout(const Duration(seconds: 60));

    final List data = jsonDecode(response.body);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  /* -------------------- CUSTOMER ORDERS -------------------- */
  static Future<List<Order>> getCustomerOrders(String phone) async {
    final response = await http
        .get(Uri.parse("$baseUrl/orders/customer?phone=$phone"))
        .timeout(const Duration(seconds: 60));

    final List data = jsonDecode(response.body);
    return data.map((e) => Order.fromJson(e)).toList();
  }

  /* -------------------- ACCEPT ORDER -------------------- */
  static Future<void> acceptOrder(String orderId) async {
    final token = await _token();
    await http.post(
      Uri.parse("$baseUrl/orders/$orderId/accept"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  /* -------------------- UPDATE STATUS -------------------- */
  static Future<void> updateStatus(String orderId) async {
    final token = await _token();
    await http.post(
      Uri.parse("$baseUrl/orders/$orderId/update-status"),
      headers: {"Authorization": "Bearer $token"},
    );
  }

  /* -------------------- REGISTERED / NEARBY TAILORS -------------------- */
  static Future<List<Map<String, dynamic>>> getRegisteredTailors({
    double? lat,
    double? lng,
    double radius = 5,
  }) async {
    String url = "$baseUrl/auth/tailors";

    if (lat != null && lng != null) {
      url =
      "$baseUrl/auth/tailors/nearby?lat=$lat&lng=$lng&radius=$radius";
    }

    final response =
    await http.get(Uri.parse(url)).timeout(const Duration(seconds: 60));

    final List data = jsonDecode(response.body);
    return List<Map<String, dynamic>>.from(data);
  }

  /* -------------------- TAILOR ANALYTICS -------------------- */
  static Future<Map<String, dynamic>> getAnalytics() async {
    final response = await http
        .get(Uri.parse("$baseUrl/orders/analytics"))
        .timeout(const Duration(seconds: 60));

    return jsonDecode(response.body);
  }

  /* -------------------- OLD UI COMPATIBILITY -------------------- */
  static Future<List<Order>> getOrders(String status) async {
    return getTailorOrders(status);
  }

  /* -------------------- REJECT ORDER -------------------- */
  static Future<void> rejectOrder(String orderId) async {
    final token = await _token();
    await http.post(
      Uri.parse("$baseUrl/orders/$orderId/reject"),
      headers: {"Authorization": "Bearer $token"},
    );
  }
}
