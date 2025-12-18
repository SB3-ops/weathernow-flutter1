import 'dart:math' as math;
import 'package:flutter/material.dart';

class WeatherBackground extends StatefulWidget {
  final Map<String, dynamic>? weather;
  final Widget child;

  const WeatherBackground({
    super.key,
    required this.weather,
    required this.child,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  bool _isDay() {
    final icon = widget.weather?["weather"]?[0]?["icon"]?.toString() ?? "";
    // OpenWeather: "01d" day, "01n" night
    return icon.endsWith("d");
  }

  List<Color> _dayColors() => const [
    Color(0xFF6EC6FF), // sky
    Color(0xFF2196F3),
    Color(0xFF0D47A1),
  ];

  List<Color> _nightColors() => const [
    Color(0xFF0B1026), // deep night
    Color(0xFF141B3A),
    Color(0xFF1E2A78),
  ];

  @override
  Widget build(BuildContext context) {
    final isDay = _isDay();

    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value; // 0..1

        return Stack(
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDay ? _dayColors() : _nightColors(),
                ),
              ),
            ),

            // Stars (night only)
            if (!isDay)
              Positioned.fill(
                child: CustomPaint(painter: _StarsPainter(seed: 12, phase: t)),
              ),

            // Sun / Moon
            Positioned(
              top: 60 + 20 * math.sin(2 * math.pi * t),
              right: 24 + 10 * math.cos(2 * math.pi * t),
              child: isDay ? _SunGlow(phase: t) : _MoonGlow(phase: t),
            ),

            // Light clouds overlay (optional)
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: isDay ? 0.10 : 0.06,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topLeft,
                        radius: 1.2,
                        colors: [Colors.white, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Your UI on top
            widget.child,
          ],
        );
      },
    );
  }
}

class _SunGlow extends StatelessWidget {
  final double phase;
  const _SunGlow({required this.phase});

  @override
  Widget build(BuildContext context) {
    final glow = 0.55 + 0.15 * math.sin(2 * math.pi * phase);
    return Container(
      width: 78,
      height: 78,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.yellow.withAlpha((255 * glow).round()),
            Colors.orange.withAlpha((255 * (glow * 0.55)).round()),
            Colors.transparent,
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFFFD54F),
          ),
        ),
      ),
    );
  }
}

class _MoonGlow extends StatelessWidget {
  final double phase;
  const _MoonGlow({required this.phase});

  @override
  Widget build(BuildContext context) {
    final glow = 0.45 + 0.10 * math.sin(2 * math.pi * phase);
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withAlpha((255 * glow).round()),
            Colors.blueGrey.withAlpha((255 * (glow * 0.35)).round()),
            Colors.transparent,
          ],
          stops: const [0.0, 0.6, 1.0],
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: CircleAvatar(radius: 22, backgroundColor: Color(0xFFECEFF1)),
          ),
          Positioned(
            left: 30,
            top: 20,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF0B1026),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final int seed;
  final double phase;
  _StarsPainter({required this.seed, required this.phase});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final paint = Paint()..color = Colors.white.withAlpha(220);

    // fixed star positions from seed, twinkle with phase
    for (int i = 0; i < 120; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * (size.height * 0.55);
      final r = 0.6 + rnd.nextDouble() * 1.4;

      final tw =
          0.35 +
          0.65 * (0.5 + 0.5 * math.sin(2 * math.pi * (phase + i * 0.03)));
      paint.color = Colors.white.withAlpha((255 * tw).round());

      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
