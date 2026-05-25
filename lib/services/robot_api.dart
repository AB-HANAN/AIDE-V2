import 'dart:convert';
import 'package:http/http.dart' as http;

class Telemetry {
  final Map<String, dynamic> raw;

  Telemetry(this.raw);

  factory Telemetry.fromJson(Map<String, dynamic> json) => Telemetry(json);

  String _s(String key, [String fallback = '-']) {
    final v = raw[key];
    if (v == null) {
      return fallback;
    }
    return v.toString();
  }

  double _d(String key, [double fallback = 0.0]) {
    final v = raw[key];
    if (v is num) {
      return v.toDouble();
    }
    if (v is String) {
      return double.tryParse(v) ?? fallback;
    }
    return fallback;
  }

  bool _b(String key, [bool fallback = false]) {
    final v = raw[key];
    if (v is bool) {
      return v;
    }
    if (v is num) {
      return v != 0;
    }
    if (v is String) {
      final s = v.toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') {
        return true;
      }
      if (s == 'false' || s == '0' || s == 'no') {
        return false;
      }
    }
    return fallback;
  }

  String get mode => _s('mode');
  String get target => _s('target');
  String get obsAction => _s('obs_action');
  String get followState => _s('follow_state');
  String get lastGesture => _s('last_gesture');
  String get placement => _s('placement');
  String get locHeading => _s('loc_heading');
  String get locGrid => _s('loc_grid', '');

  bool get estop => _b('estop');
  bool get locked => _b('locked');
  bool get gestures => _b('gestures');
  bool get followEnabled => _b('follow_enabled');
  bool get obsFresh => _b('obs_fresh');
  bool get locActive => _b('loc_active');
  bool get locTrace => _b('loc_trace');

  double get fps => _d('fps');
  double get steer => _d('steer');
  double get thr => _d('thr');
  double get thrOut => _d('thr_out');
  double get distM => _d('dist_m');
  double get speedMps => _d('speed_mps');
  double get heading => _d('imu_yaw_deg');
  double get speedTargetMps => _d('speed_target_mps');
  double get rpmL => _d('spd_rpm_l');
  double get rpmR => _d('spd_rpm_r');
  double get rpmAvg => _d('spd_rpm_avg');
  double get obsLeftM => _d('obs_left_m');
  double get obsRightM => _d('obs_right_m');
  double get tiltDeg => _d('tilt_deg');

  int get locPathLen {
    final v = raw['loc_path_len'];
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    if (v is String) {
      return int.tryParse(v) ?? 0;
    }
    return 0;
  }
}

class LocStateResponse {
  final String grid;
  final Map<String, dynamic> state;

  LocStateResponse({
    required this.grid,
    required this.state,
  });

  factory LocStateResponse.fromJson(Map<String, dynamic> json) {
    return LocStateResponse(
      grid: (json['grid'] ?? '').toString(),
      state: (json['state'] as Map<String, dynamic>?) ?? <String, dynamic>{},
    );
  }
}

class TraceResponse {
  final bool replayActive;
  final bool traceOn;
  final String locGrid;

  TraceResponse({
    required this.replayActive,
    required this.traceOn,
    required this.locGrid,
  });

  factory TraceResponse.fromJson(Map<String, dynamic> json) {
    return TraceResponse(
      replayActive: json['replay_active'] == true,
      traceOn: json['trace_on'] == true,
      locGrid: (json['loc_grid'] ?? '').toString(),
    );
  }
}

class AiHealthResponse {
  final Map<String, dynamic> raw;

  AiHealthResponse(this.raw);
}

class ConnectionCheck {
  const ConnectionCheck({
    required this.ok,
    required this.url,
    required this.message,
    this.telemetryReady = false,
  });

  final bool ok;
  final String url;
  final String message;
  final bool telemetryReady;
}

class RobotApi {
  RobotApi(String baseUrl) : baseUrl = normalizeBaseUrl(baseUrl);

  String baseUrl;

  static String normalizeBaseUrl(String value) {
    var url = value.trim();
    if (url.isEmpty) {
      return '';
    }

    if (!url.startsWith(RegExp(r'https?://', caseSensitive: false))) {
      url = 'http://$url';
    }

    while (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }

    return url;
  }

  Uri _u(String path) => Uri.parse('$baseUrl$path');

  Future<ConnectionCheck> checkConnection() async {
    final checks = <String>[
      '/telemetry',
      '/health',
      '/status',
      '/',
    ];
    final failures = <String>[];

    for (final path in checks) {
      final url = _u(path).toString();

      try {
        final res = await http.get(_u(path)).timeout(const Duration(seconds: 8));
        if (path == '/telemetry' && res.statusCode == 200) {
          return ConnectionCheck(
            ok: true,
            url: url,
            message: 'Connected to $url',
            telemetryReady: true,
          );
        }

        if (res.statusCode >= 200 && res.statusCode < 500) {
          return ConnectionCheck(
            ok: true,
            url: url,
            message: 'Jetson server is reachable at $url, but /telemetry returned ${path == '/telemetry' ? res.statusCode : 'no confirmed telemetry yet'}.',
          );
        }

        failures.add('$url -> HTTP ${res.statusCode}');
      } catch (e) {
        failures.add('$url -> ${e.toString()}');
      }
    }

    return ConnectionCheck(
      ok: false,
      url: _u('/telemetry').toString(),
      message: 'Could not reach the Jetson API.\n'
          '${failures.join('\n')}'
          '${_looksLikeBrowserFetchBlock(failures) ? '\n\nThis looks like Flutter Web/browser fetch blocking. If you are running this in Chrome, enable CORS on the Jetson API or install the Android APK instead.' : ''}',
    );
  }

  bool _looksLikeBrowserFetchBlock(List<String> failures) {
    return failures.any((failure) => failure.contains('Failed to fetch'));
  }

  Future<bool> ping() async {
    final check = await checkConnection();
    return check.ok;
  }

  Future<Telemetry?> getTelemetry() async {
    try {
      final res = await http.get(_u('/telemetry')).timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) {
        return null;
      }

      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        return Telemetry.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<Telemetry?> getTelemetryStrict() async {
    final res = await http.get(_u('/telemetry')).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('Telemetry failed: HTTP ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return Telemetry.fromJson(decoded);
    }

    throw Exception('Telemetry response was not a JSON object');
  }

  Future<bool> telemetryReady() async {
    try {
      await getTelemetryStrict();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<String> telemetryDiagnostic() async {
    final url = _u('/telemetry').toString();

    try {
      final res = await http.get(_u('/telemetry')).timeout(const Duration(seconds: 8));
      return '$url -> HTTP ${res.statusCode}: ${res.body.length > 160 ? '${res.body.substring(0, 160)}...' : res.body}';
    } catch (e) {
      return '$url -> ${e.toString()}';
    }
  }

  Future<void> sendCmd({
    required double thr,
    required double steer,
  }) async {
    final res = await http.post(
      _u('/cmd'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'thr': thr,
        'steer': steer,
      }),
    ).timeout(const Duration(seconds: 2));

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('CMD failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> setAutoMode(bool auto) async {
    final res = await http.post(
      _u('/mode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'auto': auto,
        'mode': auto ? 'AUTO' : 'MANUAL',
      }),
    ).timeout(const Duration(seconds: 2));

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('MODE failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> triggerEstop({double holdSeconds = 1.5}) async {
    final res = await http.post(
      _u('/estop'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'hold_s': holdSeconds,
      }),
    ).timeout(const Duration(seconds: 2));

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('ESTOP failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> setTarget(String target) async {
    final res = await http.post(
      _u('/config'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'target': target,
      }),
    ).timeout(const Duration(seconds: 2));

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('SET TARGET failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> postSimple(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      _u(path),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? <String, dynamic>{}),
    ).timeout(const Duration(seconds: 3));

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('$path failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<void> locStart() => postSimple('/loc/start');

  Future<void> locStop() => postSimple('/loc/stop');

  Future<void> locReset() => postSimple('/loc/reset');

  Future<LocStateResponse> locState() async {
    final res = await http.get(_u('/loc/state')).timeout(const Duration(seconds: 2));

    if (res.statusCode != 200) {
      throw Exception('LOC STATE failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('LOC STATE invalid response');
    }

    return LocStateResponse.fromJson(decoded);
  }

  Future<TraceResponse> locTrace() async {
    final res = await http.post(
      _u('/loc/trace'),
      headers: {'Content-Type': 'application/json'},
      body: '{}',
    ).timeout(const Duration(seconds: 3));

    if (res.statusCode != 200) {
      throw Exception('TRACE failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('TRACE invalid response');
    }

    return TraceResponse.fromJson(decoded);
  }

  Future<void> tiltUpStart() => postSimple('/kinect_tilt_hold', {
        'dir': 'up',
        'hold': true,
      });

  Future<void> tiltDownStart() => postSimple('/kinect_tilt_hold', {
        'dir': 'down',
        'hold': true,
      });

  Future<void> tiltStop() => postSimple('/kinect_tilt_hold', {
        'dir': 'stop',
        'hold': false,
      });

  Future<void> tiltCenter() => postSimple('/kinect_tilt', {
        'deg': 0,
      });

  Future<String> aiSend({
    required String message,
    int maxTokens = 200,
    double temperature = 0.7,
  }) async {
    final res = await http.post(
      _u('/ai/send'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'max_tokens': maxTokens,
        'temperature': temperature,
      }),
    ).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('AI SEND failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) {
      return (decoded['reply'] ?? '').toString();
    }

    return '';
  }

  Future<void> aiClear() async {
    final res = await http.post(
      _u('/ai/clear'),
      headers: {'Content-Type': 'application/json'},
      body: '{}',
    ).timeout(const Duration(seconds: 5));

    if (res.statusCode != 200) {
      throw Exception('AI CLEAR failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<AiHealthResponse> aiHealth() async {
    final res = await http.get(_u('/ai/health')).timeout(const Duration(seconds: 5));

    if (res.statusCode != 200) {
      throw Exception('AI HEALTH failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('AI HEALTH invalid response');
    }

    return AiHealthResponse(decoded);
  }
}
