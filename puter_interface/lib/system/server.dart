import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      statusCode == null ? message : '$message (HTTP $statusCode)';
}

class ServerEvent {
  final Map<String, dynamic> data;

  ServerEvent(this.data);

  String? get type => data['event'] as String?;
}

class Server {
  static String baseUrl = 'http://127.0.0.1:8080';
  static Duration _timeout = const Duration(seconds: 2);

  static http.Client _http = http.Client();

  static WebSocketChannel? _ws;
  static final StreamController<ServerEvent> _events =
      StreamController<ServerEvent>.broadcast();

  static Stream<ServerEvent> get events => _events.stream;

  static void configure({
    String? newBaseUrl,
    Duration? newTimeout,
    http.Client? client,
  }) {
    if (newBaseUrl != null) baseUrl = newBaseUrl;
    if (newTimeout != null) _timeout = newTimeout;
    if (client != null) {
      _http.close();
      _http = client;
    }
  }

  static Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  static Map<String, dynamic> _decodeJson(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      try {
        final j = jsonDecode(res.body);
        final String msg =
            (j is Map && j['error'] != null) ? '${j['error']}' : res.body;
        throw ApiException(msg, statusCode: res.statusCode);
      } catch (_) {
        throw ApiException(
          res.body.isEmpty ? 'Request failed' : res.body,
          statusCode: res.statusCode,
        );
      }
    }

    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw ApiException('Expected JSON object, got: ${res.body}');
    } catch (_) {
      throw ApiException('Bad JSON from server: ${res.body}');
    }
  }

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final http.Response res =
        await _http.get(_uri(path, query)).timeout(_timeout);
    return _decodeJson(res);
  }

  static Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final http.Response res = await _http
        .post(
          _uri(path),
          headers: {'Content-Type': 'application/json'},
          body: body == null ? null : jsonEncode(body),
        )
        .timeout(_timeout);
    return _decodeJson(res);
  }

  static Future<bool> health() async {
    try {
      final http.Response res = await _http.get(_uri('/health')).timeout(_timeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static void connectEvents({String path = '/ws'}) {
    final String wsUrl = baseUrl.replaceFirst(RegExp(r'^http'), 'ws') + path;

    _ws?.sink.close();
    _ws = WebSocketChannel.connect(Uri.parse(wsUrl));

    _ws!.stream.listen(
      (msg) {
        try {
          final j = jsonDecode(msg as String);
          if (j is Map<String, dynamic>) _events.add(ServerEvent(j));
        } catch (_) {}
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  static void disconnectEvents() {
    _ws?.sink.close();
    _ws = null;
  }

  static Future<void> dispose() async {
    disconnectEvents();
    await _events.close();
    _http.close();
  }
}
