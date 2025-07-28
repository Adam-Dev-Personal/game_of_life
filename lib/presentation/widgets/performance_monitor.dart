import 'package:flutter/material.dart';
import 'dart:async';

/// A simple performance monitor widget that displays FPS and other metrics
class PerformanceMonitor extends StatefulWidget {
  const PerformanceMonitor({super.key});

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  int _frameCount = 0;
  int _fps = 0;
  Timer? _fpsTimer;
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    _startFpsTimer();
  }

  @override
  void dispose() {
    _fpsTimer?.cancel();
    super.dispose();
  }

  void _startFpsTimer() {
    _fpsTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _fps = _frameCount;
          _frameCount = 0;
        });
      }
    });
  }

  void _onFrame() {
    _frameCount++;
    _lastFrameTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'FPS: $_fps',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${_fps >= 30 ? "Good" : _fps >= 15 ? "Fair" : "Poor"}',
              style: TextStyle(
                color: _fps >= 30 
                    ? Colors.green 
                    : _fps >= 15 
                        ? Colors.orange 
                        : Colors.red,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 