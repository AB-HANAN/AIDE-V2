import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/robot_api.dart';
import '../theme/app_theme.dart';

class RobotLiveFeed extends StatefulWidget {
  const RobotLiveFeed({
    super.key,
    required this.baseUrl,
    this.height = 260,
    this.demoMode = false,
  });

  final String baseUrl;
  final double height;
  final bool demoMode;

  @override
  State<RobotLiveFeed> createState() => _RobotLiveFeedState();
}

class _RobotLiveFeedState extends State<RobotLiveFeed> {
  WebViewController? _controller;
  bool _started = false;
  bool _loading = false;
  String _status = 'Camera is ready to start.';

  @override
  void didUpdateWidget(covariant RobotLiveFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.baseUrl != widget.baseUrl ||
        oldWidget.demoMode != widget.demoMode) {
      setState(() {
        _controller = null;
        _started = false;
        _loading = false;
        _status = 'Camera is ready to start.';
      });
    }
  }

  Future<void> _startCamera() async {
    final normalizedUrl = RobotApi.normalizeBaseUrl(widget.baseUrl);

    if (widget.demoMode) {
      setState(() {
        _status = 'Skip mode is active.';
      });
      return;
    }

    if (normalizedUrl.isEmpty) {
      setState(() {
        _status = 'No Jetson URL available.';
      });
      return;
    }

    setState(() {
      _started = true;
      _loading = true;
      _status = 'Opening Jetson camera page...';
    });

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF090B13))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            await _focusVideoOnly();
            if (!mounted) {
              return;
            }
            setState(() {
              _loading = false;
              _status = 'Live feed loaded.';
            });
          },
          onWebResourceError: (error) {
            if (!mounted) {
              return;
            }
            setState(() {
              _loading = false;
              _status = 'Live feed unavailable: ${error.description}';
            });
          },
        ),
      );

    setState(() {
      _controller = controller;
    });

    await controller.loadRequest(Uri.parse(normalizedUrl));
  }

  Future<void> _focusVideoOnly() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    try {
      await controller.runJavaScript('''
        (function () {
          const video = document.getElementById('webrtc');
          document.documentElement.style.margin = '0';
          document.documentElement.style.padding = '0';
          document.documentElement.style.background = '#090B13';
          document.body.style.margin = '0';
          document.body.style.padding = '0';
          document.body.style.overflow = 'hidden';
          document.body.style.background = '#090B13';

          if (!video) {
            document.body.innerHTML =
              '<div style="height:100vh;display:flex;align-items:center;justify-content:center;color:#E9EDF6;font:14px sans-serif;text-align:center;padding:24px;">Camera element not found on Jetson page.</div>';
            return;
          }

          document.body.innerHTML = '';
          video.removeAttribute('class');
          video.autoplay = true;
          video.muted = true;
          video.playsInline = true;
          video.style.width = '100vw';
          video.style.height = '100vh';
          video.style.objectFit = 'cover';
          video.style.background = '#090B13';
          document.body.appendChild(video);
        })();
      ''');
    } catch (_) {
      // If page injection fails, leave the Jetson page visible instead of crashing.
    }
  }

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = RobotApi.normalizeBaseUrl(widget.baseUrl);

    return Container(
      height: widget.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF090B13),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_started && _controller != null)
            WebViewWidget(controller: _controller!)
          else
            _CameraPlaceholder(
              demoMode: widget.demoMode,
              status: widget.demoMode
                  ? 'Skip mode is active.'
                  : (normalizedUrl.isEmpty
                      ? 'No Jetson URL available.'
                      : 'Uses the same Jetson web camera page that works in Flask.'),
              onStart: widget.demoMode ? null : _startCamera,
            ),
          if (_loading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          Positioned(
            top: 14,
            left: 14,
            child: _pill(
              icon: _started
                  ? Icons.play_circle_outline_rounded
                  : Icons.pause_circle_outline_rounded,
              text: _started ? 'Live' : 'Ready',
              accent: _started ? const Color(0xFFEF6A3B) : Colors.white70,
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Text(
              _status,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AideColors.textMuted,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required IconData icon,
    required String text,
    required Color accent,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.42),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  const _CameraPlaceholder({
    required this.demoMode,
    required this.status,
    required this.onStart,
  });

  final bool demoMode;
  final String status;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/robot_hero.png',
          fit: BoxFit.contain,
        ),
        Container(
          color: Colors.black.withValues(alpha: isLight ? 0.4 : 0.62),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  demoMode ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                  size: 42,
                  color: AideColors.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  demoMode ? 'Demo camera preview' : 'Camera preview',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                if (onStart != null) ...[
                  const SizedBox(height: 14),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onStart,
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Start Camera'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
