import 'dart:async';
import 'package:flutter/material.dart';
import '../services/robot_api.dart';
import '../widgets/aide_shell.dart';
import '../widgets/robot_live_feed.dart';

class PersonFollowScreen extends StatefulWidget {
  const PersonFollowScreen({super.key, required this.api});
  final RobotApi api;

  @override
  State<PersonFollowScreen> createState() => _PersonFollowScreenState();
}

class _PersonFollowScreenState extends State<PersonFollowScreen> {
  Timer? _timer;
  Telemetry? _t;
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final t = await widget.api.getTelemetry();
    if (!mounted) return;
    setState(() => _t = t);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _t;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? Colors.black87 : Colors.white;
    final subtextColor = isLight ? Colors.black54 : Colors.white70;

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
                  heroTag: 'fullscreen_follow',
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
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.api.setAutoMode(true);
                    await _refresh();
                    setState(() => _msg = 'AUTO follow mode requested');
                  },
                  child: const Text('Start Follow'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.api.setAutoMode(false);
                    await _refresh();
                    setState(() => _msg = 'Switched back to MANUAL');
                  },
                  child: const Text('Stop Follow'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Target: ${t?.target ?? "-"}', style: TextStyle(color: textColor)),
          Text('Lock: ${t?.locked == true ? "YES" : "NO"}', style: TextStyle(color: textColor)),
          Text('Follow state: ${t?.followState ?? "-"}', style: TextStyle(color: textColor)),
          Text('Distance: ${t?.distM.toStringAsFixed(2) ?? "0.00"} m', style: TextStyle(color: textColor)),
          Text('FPS: ${t?.fps.toStringAsFixed(1) ?? "0.0"}', style: TextStyle(color: textColor)),
          Text('Last gesture: ${t?.lastGesture ?? "-"}', style: TextStyle(color: textColor)),
          Text('Gesture system status: ${t?.gestures == true ? "ON" : "OFF"}', style: TextStyle(color: textColor)),
          Text('Follow enabled flag: ${t?.followEnabled == true ? "ON" : "OFF"}', style: TextStyle(color: textColor)),
          Text('Tilt: ${t?.tiltDeg.toStringAsFixed(0) ?? "0"}°', style: TextStyle(color: textColor)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => widget.api.tiltUpStart(),
                  onTapUp: (_) => widget.api.tiltStop(),
                  onTapCancel: () => widget.api.tiltStop(),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tilt Up',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.api.tiltCenter();
                    await _refresh();
                  },
                  child: const Text('Center'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => widget.api.tiltDownStart(),
                  onTapUp: (_) => widget.api.tiltStop(),
                  onTapCancel: () => widget.api.tiltStop(),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isLight
                          ? Colors.black.withValues(alpha: 0.08)
                          : const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Tilt Down',
                      style: TextStyle(color: textColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _msg,
            style: TextStyle(color: textColor),
          ),
        ],
      ),
    );
  }
}

/// Full screen camera view for person follow
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