import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A subtle, looping hero animation that implements the layered spec:
/// - drifting background gradient
/// - faint noise overlay
/// - circular time ring (60s progress, soft crossfade)
/// - calm waveform
/// - slow motion dots
class HeroAnimationWidget extends StatefulWidget {
  const HeroAnimationWidget({super.key});

  @override
  State<HeroAnimationWidget> createState() => _HeroAnimationWidgetState();
}

class _HeroAnimationWidgetState extends State<HeroAnimationWidget>
    with TickerProviderStateMixin {
  // Long controllers for slow motion
  late final AnimationController _loopController; // drives primary timeline (0..1)
  late final AnimationController _gradientController; // drift 20-30s
  late final AnimationController _noisePulseController; // slow opacity pulse

  static const Duration ringDuration = Duration(seconds: 60);
  static const Duration gradientDuration = Duration(seconds: 25);
  static const Duration noisePulseDuration = Duration(seconds: 18);

  @override
  void initState() {
    super.initState();

    _loopController = AnimationController(
      vsync: this,
      duration: ringDuration,
    )..repeat(); // used for ring progress and other slow timings

    _gradientController = AnimationController(
      vsync: this,
      duration: gradientDuration,
    )..repeat();

    _noisePulseController = AnimationController(
      vsync: this,
      duration: noisePulseDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loopController.dispose();
    _gradientController.dispose();
    _noisePulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _loopController,
        _gradientController,
        _noisePulseController,
      ]),
      builder: (context, child) {
        return CustomPaint(
          painter: _HeroPainter(
            progress: _loopController.value,
            gradientT: _gradientController.value,
            noisePulse: _noisePulseController.value,
            devicePixelRatio: MediaQuery.of(context).devicePixelRatio,
            theme: Theme.of(context),
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _HeroPainter extends CustomPainter {
  final double progress; // 0..1 (ring)
  final double gradientT; // 0..1 (drift)
  final double noisePulse; // 0..1 (opacity subtle)
  final double devicePixelRatio;
  final ThemeData theme;

  _HeroPainter({
    required this.progress,
    required this.gradientT,
    required this.noisePulse,
    required this.devicePixelRatio,
    required this.theme,
  });

  // Cache noise pattern parameters so the noise doesn't visibly repeat
  final _noiseSeed = 42;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Background (soft linear gradient drifting subtly)
    _paintDriftingGradient(canvas, size);

    // 2) Noise overlay (very fine, low opacity)
    _paintNoiseOverlay(canvas, size);

    // 3) Time ring (slightly above center)
    _paintTimeRing(canvas, size);

    // 4) Waveform across lower third
    _paintWaveform(canvas, size);

    // 5) Motion dots
    _paintMotionDots(canvas, size);
  }

  void _paintDriftingGradient(Canvas canvas, Size size) {
    // Center shifts by up to ~6% on each axis using a slow circular motion
    final maxShift = 0.06; // 6%
    final theta = gradientT * 2 * math.pi;
    final dx = math.sin(theta) * maxShift;
    final dy = math.cos(theta) * maxShift * 0.6; // less vertical

    final center = Offset(size.width * (0.5 + dx), size.height * (0.45 + dy));

    final gradient = RadialGradient(
      center: Alignment((center.dx / size.width) * 2 - 1, (center.dy / size.height) * 2 - 1),
      radius: 0.9,
      colors: [
        // deep desaturated indigo / charcoal -> lighter blue-grey
        const Color(0xFF12141A),
        const Color(0xFF102437),
      ],
      stops: const [0.0, 1.0],
    );

    final paint = Paint()..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  void _paintNoiseOverlay(Canvas canvas, Size size) {
    // Very fine monochrome dots. Opacity 0.03 - 0.06 modulated by noisePulse
    final baseOpacity = 0.04; // mid-point
    final opacity = baseOpacity * (0.8 + 0.4 * (noisePulse - 0.5));

    final paint = Paint()..color = Colors.white.withOpacity(opacity.clamp(0.02, 0.06));

    final rng = math.Random(_noiseSeed);
    final density = (size.width * size.height) / 60000; // low density
    final count = density.clamp(80, 400).toInt();

    // Draw sparse points - non-animated to save CPU
    for (int i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = (rng.nextDouble() * 0.7 + 0.3) * (devicePixelRatio * 0.35);
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  void _paintTimeRing(Canvas canvas, Size size) {
    final ringCenter = Offset(size.width / 2, size.height * 0.38);
    final radius = math.min(size.width, size.height) * 0.24;
    final stroke = (devicePixelRatio <= 2) ? 2.4 : 3.0;

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Colors.white.withOpacity(0.12)
      ..isAntiAlias = true;
    canvas.drawCircle(ringCenter, radius, bgPaint);

    // Progress arc with soft fade at the end
    // We'll make the last ~2% fade to 0 to enable seamless crossfade
    final fadeStart = 0.98;
    final arcOpacity = (progress < fadeStart) ? 0.65 : (0.65 * (1 - (progress - fadeStart) / (1 - fadeStart))).clamp(0.0, 0.65);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke
      ..color = Colors.white.withOpacity(arcOpacity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.75)
      ..isAntiAlias = true;

    final startAngle = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    final rect = Rect.fromCircle(center: ringCenter, radius: radius);
    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);

    // Very subtle glow that follows progress
    if (progress > 0.01) {
      final glowOpacity = (progress * 0.6).clamp(0.0, 0.45);
      final glowPaint = Paint()
        ..color = Colors.white.withOpacity(glowOpacity * 0.08)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.25);
      canvas.drawCircle(ringCenter, radius * (1.03 + 0.03 * math.sin(progress * 2 * math.pi)), glowPaint);
    }
  }

  void _paintWaveform(Canvas canvas, Size size) {
    final waveWidth = size.width * 0.66;
    final left = (size.width - waveWidth) / 2;
    final top = size.height * 0.66;
    final bottom = top + (size.height * 0.06);
    final centerY = top + (bottom - top) / 2;

    // calm amplitude that slowly breathes
    final slow = math.sin(progress * 2 * math.pi * 0.35) * 0.5 + 0.5; // 0..1 slowly
    final amplitude = (size.height * 0.02) * (0.6 + 0.8 * slow);

    // phase moves horizontally
    final phase = progress * 2 * math.pi * 0.9;

    final path = Path();
    const samples = 80;
    for (int i = 0; i <= samples; i++) {
      final t = i / samples;
      final x = left + t * waveWidth;
      final freq = 1.6; // number of waves across
      final env = 1 - math.pow((2 * t - 1).abs(), 2); // taper at edges
      final y = centerY + math.sin((t * freq * 2 * math.pi) + phase) * amplitude * env;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(0.5)
      ..isAntiAlias = true;

    canvas.drawPath(path, wavePaint);
  }

  void _paintMotionDots(Canvas canvas, Size size) {
    final dotPaint = Paint()..color = Colors.white;

    final dotCount = 3;
    final baseRadius = devicePixelRatio <= 2 ? 2.2 : 3.4;

    for (int i = 0; i < dotCount; i++) {
      final phaseOffset = (i / dotCount) * 0.9;
      final t = ((progress + phaseOffset) % 1.0);
      final path = _generateDotPath(size, i);
      final pos = _pointAlongPath(path, t);
      final opacity = (0.3 + 0.7 * (0.5 + 0.5 * math.sin((t - 0.25) * 2 * math.pi))).clamp(0.05, 0.95);
      final r = baseRadius * (0.6 + 0.6 * (i / (dotCount - 1 + 0.001)));
      canvas.drawCircle(pos, r, dotPaint..color = Colors.white.withOpacity(opacity * 0.75));
    }
  }

  Path _generateDotPath(Size size, int index) {
    // soft curved path varying per index
    final w = size.width;
    final h = size.height;
    final start = Offset(w * (0.05 + 0.25 * index), h * 0.55 + index * 6);
    final cp1 = Offset(w * (0.25 + 0.12 * index), h * (0.42 - index * 0.02));
    final cp2 = Offset(w * (0.55 + 0.08 * index), h * (0.62 + index * 0.02));
    final end = Offset(w * (0.85 - 0.05 * index), h * (0.48 + index * 0.01));
    final p = Path()..moveTo(start.dx, start.dy);
    p.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);
    return p;
  }

  Offset _pointAlongPath(Path path, double t) {
    // approximate point sampling using PathMetrics
    final metrics = path.computeMetrics();
    if (metrics.isEmpty) return Offset.zero;
    final metric = metrics.first;
    final len = metric.length;
    final pos = metric.getTangentForOffset((t * len).clamp(0.0, len))?.position;
    return pos ?? Offset.zero;
  }

  @override
  bool shouldRepaint(covariant _HeroPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientT != gradientT ||
        oldDelegate.noisePulse != noisePulse;
  }
}
