import 'dart:async';
import 'package:flutter/material.dart';
import '../services/robot_api.dart';
import '../widgets/aide_shell.dart';
import '../widgets/robot_live_feed.dart';
import '../widgets/hold_button.dart';

class ManualDriveScreen extends StatefulWidget {
  const ManualDriveScreen({super.key, required this.api});

  final RobotApi api;

  @override
  State<ManualDriveScreen> createState() => _ManualDriveScreenState();
}

class _ManualDriveScreenState extends State<ManualDriveScreen> {
  Timer? _timer;
  Telemetry? _telemetry;
  String _msg = '';

  static const double steerCenter = 90.0;
  static const double steerLeft = 60.0;
  static const double steerRight = 120.0;
  static const double driveThr = 0.20;

  double _thr = 0.0;
  double _steer = steerCenter;

  @override
  void initState() {
    super.initState();
    widget.api.setAutoMode(false);
    _refreshTelemetry();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      _refreshTelemetry();
    });
  }

  Future<void> _refreshTelemetry() async {
    final telemetry = await widget.api.getTelemetry();
    if (!mounted) {
      return;
    }
    setState(() {
      _telemetry = telemetry;
    });
  }

  Future<void> _send() async {
    try {
      await widget.api.sendCmd(thr: _thr, steer: _steer);
      if (!mounted) {
        return;
      }
      setState(() {
        _msg = 'thr=${_thr.toStringAsFixed(2)} steer=${_steer.toStringAsFixed(0)}';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _msg = 'Command error: $e';
      });
    }
  }

  Future<void> _stop() async {
    _thr = 0.0;
    _steer = steerCenter;
    await _send();
  }

  void _setSteer(double steer) {
    _steer = steer;
    _send();
  }

  void _setThr(double thr) {
    _thr = thr;
    _send();
  }

  Future<void> _triggerEstop() async {
    try {
      await widget.api.triggerEstop();
      await _refreshTelemetry();
      if (!mounted) {
        return;
      }
      setState(() {
        _msg = 'E-STOP triggered';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _msg = 'E-STOP error: $e';
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stop();
    super.dispose();
  }

  Widget _metric(String label, String value) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isLight
              ? Colors.black.withValues(alpha: 0.05)
              : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white10,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isLight ? Colors.black54 : Colors.white60,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = _telemetry;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AideShell(
      showBack: true,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Stack(
            children: [
              RobotLiveFeed(baseUrl: widget.api.baseUrl, height: 220),
              Positioned(
                top: 8,
                right: 8,
                child: FloatingActionButton.small(
                  heroTag: 'fullscreen_drive',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _FullScreenCamera(api: widget.api),
                      ),
                    );
                  },
                  child: const Icon(Icons.fullscreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _triggerEstop,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('E-STOP'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: _stop,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('STOP'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _metric('Speed', '${t?.speedMps.toStringAsFixed(2) ?? '0.00'} m/s'),
              const SizedBox(width: 12),
              _metric('Heading', '${t?.heading.toStringAsFixed(1) ?? '0.0'}°'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric('Thr Out', '${t?.thrOut.toStringAsFixed(3) ?? '0.000'}'),
              const SizedBox(width: 12),
              _metric('Obstacle', t?.obsAction ?? '-'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HoldButton(
                label: 'LEFT',
                icon: Icons.arrow_back,
                onDown: () => _setSteer(steerLeft),
                onUp: () => _setSteer(steerCenter),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  HoldButton(
                    label: 'FWD',
                    icon: Icons.arrow_upward,
                    onDown: () => _setThr(driveThr),
                    onUp: () => _setThr(0.0),
                  ),
                  const SizedBox(height: 16),
                  HoldButton(
                    label: 'BACK',
                    icon: Icons.arrow_downward,
                    onDown: () => _setThr(-driveThr),
                    onUp: () => _setThr(0.0),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              HoldButton(
                label: 'RIGHT',
                icon: Icons.arrow_forward,
                onDown: () => _setSteer(steerRight),
                onUp: () => _setSteer(steerCenter),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _msg,
            style: TextStyle(
              color: isLight ? Colors.black87 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen camera view for manual drive
class _FullScreenCamera extends StatelessWidget {
  const _FullScreenCamera({required this.api});
  final RobotApi api;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Preview'),
        leading: IconButton(
          icon: const Icon(Icons.fullscreen_exit),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: RobotLiveFeed(
          baseUrl: api.baseUrl,
          height: MediaQuery.of(context).size.height - 80,
        ),
      ),
    );
  }
}