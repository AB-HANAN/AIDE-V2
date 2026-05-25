import 'dart:async';
import 'package:flutter/material.dart';
import '../services/robot_api.dart';
import '../widgets/aide_shell.dart';
import '../widgets/robot_live_feed.dart';

class LocalizationScreen extends StatefulWidget {
  const LocalizationScreen({super.key, required this.api});
  final RobotApi api;

  @override
  State<LocalizationScreen> createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  Timer? _timer;
  Telemetry? _t;
  String _grid = '';
  String _msg = '';

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(milliseconds: 900), (_) => _refresh());
  }

  Future<void> _refresh() async {
    final t = await widget.api.getTelemetry();
    final ls = await widget.api.locState();
    if (!mounted) return;
    setState(() {
      _t = t;
      _grid = ls.grid;
    });
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
                  heroTag: 'fullscreen_camera',
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
                    await widget.api.locStart();
                    await _refresh();
                    setState(() => _msg = 'Mapping started');
                  },
                  child: const Text('Start Mapping'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await widget.api.locStop();
                    await _refresh();
                    setState(() => _msg = 'Mapping stopped');
                  },
                  child: const Text('Stop'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    await widget.api.locReset();
                    await _refresh();
                    setState(() => _msg = 'Map reset');
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final res = await widget.api.locTrace();
                    await _refresh();
                    setState(() {
                      _grid = res.locGrid;
                      _msg = res.replayActive ? 'Trace replay started' : 'Trace replay stopped';
                    });
                  },
                  child: const Text('Trace Route'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Localization active: ${t?.locActive == true ? "YES" : "NO"}', style: TextStyle(color: textColor)),
          Text('Trace enabled: ${t?.locTrace == true ? "YES" : "NO"}', style: TextStyle(color: textColor)),
          Text('Heading: ${t?.locHeading ?? "-"}', style: TextStyle(color: textColor)),
          Text('Path length: ${t?.locPathLen ?? 0}', style: TextStyle(color: textColor)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isLight
                  ? Colors.black.withValues(alpha: 0.05)
                  : const Color(0xFF161B22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLight ? Colors.black.withValues(alpha: 0.08) : Colors.white10,
              ),
            ),
            child: SelectableText(
              _grid.isEmpty ? 'No grid yet.' : _grid,
              style: TextStyle(
                fontFamily: 'monospace',
                color: textColor,
              ),
            ),
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

/// Full screen camera view
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