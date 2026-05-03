import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;

  const ShakeDetector({
    super.key,
    required this.child,
    required this.onShake,
  });

  @override
  State<ShakeDetector> createState() => _ShakeDetectorState();
}

class _ShakeDetectorState extends State<ShakeDetector> {
  double _lastX = 0;
  double _lastY = 0;
  double _lastZ = 0;
  DateTime _lastShakeTime = DateTime.now();
  bool _listening = true;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    // Add keyboard listener for desktop/web (always works)
    RawKeyboard.instance.addListener(_handleKeyPress);

    // Try to add accelerometer for mobile (will fail silently on web)
    try {
      userAccelerometerEvents.listen((event) {
        if (!_listening) return;
        _onAccelerometerEvent(event);
      });
    } catch (e) {
      // Accelerometer not available (web), that's fine
      print('📱 Accelerometer not available, using keyboard only');
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyS) {
      _onShake();
    }
  }

  void _onAccelerometerEvent(UserAccelerometerEvent event) {
    final x = event.x;
    final y = event.y;
    final z = event.z;

    final deltaX = (x - _lastX).abs();
    final deltaY = (y - _lastY).abs();
    final deltaZ = (z - _lastZ).abs();

    final shakeThreshold = 15.0;

    if (deltaX > shakeThreshold || deltaY > shakeThreshold || deltaZ > shakeThreshold) {
      final now = DateTime.now();
      if (now.difference(_lastShakeTime).inMilliseconds > 500) {
        _lastShakeTime = now;
        _onShake();
      }
    }

    _lastX = x;
    _lastY = y;
    _lastZ = z;
  }

  void _onShake() {
    widget.onShake();
  }

  @override
  void dispose() {
    _listening = false;
    RawKeyboard.instance.removeListener(_handleKeyPress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}