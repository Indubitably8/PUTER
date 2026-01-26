import '../server.dart';

class ArduinoDevice {
  final String id;
  final String port;
  final bool online;
  final String? type;
  final String? fw;

  ArduinoDevice({
    required this.id,
    required this.port,
    required this.online,
    this.type,
    this.fw,
  });

  factory ArduinoDevice.fromJson(Map<String, dynamic> j) => ArduinoDevice(
        id: j['id'] as String,
        port: (j['port'] as String?) ?? '',
        online: (j['online'] as bool?) ?? true,
        type: j['type'] as String?,
        fw: j['fw'] as String?,
      );
}

class Arduino {
  static const String devicesPath = '/arduino/devices';
  static const String rescanPath = '/arduino/rescan';
  static const String commandPrefix = '/arduino';

  static Future<List<ArduinoDevice>> devices() async {
    final j = await Server.getJson(devicesPath);
    final List list = (j['devices'] as List? ?? const []);
    return list
        .whereType<Map>()
        .map((e) => ArduinoDevice.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> rescan() => Server.postJson(rescanPath);

  static Future<Map<String, dynamic>> send(
    String deviceId,
    String cmd, {
    Map<String, dynamic> data = const {},
  }) {
    return Server.postJson(
      '$commandPrefix/$deviceId/cmd',
      body: {'cmd': cmd, 'data': data},
    );
  }

  static Future<Map<String, dynamic>> request(
    String deviceId,
    String cmd, {
    Map<String, dynamic> data = const {},
  }) async {
    final Map<String, dynamic> res = await send(deviceId, cmd, data: data);

    if (res['ok'] != true) {
      throw Exception(res['error'] ?? 'Arduino request failed');
    }

    final payload = res['data'];
    if (payload is Map<String, dynamic>) return payload;

    return {};
  }
}
