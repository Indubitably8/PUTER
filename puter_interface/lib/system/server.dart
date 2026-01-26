import 'dart:convert';
import 'package:http/http.dart' as http;

class Server {
  static const String baseUrl = 'http://127.0.0.1:8080';

  static Future<bool> health() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 1));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setServoThrottle(double value) async {
    final v = value.clamp(-1.0, 1.0);

    await http.post(
      Uri.parse('$baseUrl/servo/throttle'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'value': v}),
    );
  }

  static Future<void> stopServo() async {
    await http.post(Uri.parse('$baseUrl/servo/stop'));
  }

  static Future<double> getServoState() async {
    final res = await http.get(Uri.parse('$baseUrl/servo/state'));
    final data = jsonDecode(res.body);
    return (data['throttle'] as num).toDouble();
  }
}
