import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../widgets/news_input_form.dart';
import '../widgets/analysis_history.dart';
import '../widgets/settings_sheet.dart';
import '../providers/news_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _gridController;
  late AnimationController _pulseController;

  static const _neon = Color(0xFF00FFB2);
  static const _bg = Color(0xFF080B14);

  @override
  void initState() {
    super.initState();
    _gridController = AnimationController(
      vsync: this, duration: const Duration(seconds: 20))..repeat();
    _pulseController = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gridController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewsProvider>(context);
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Animated grid background
        _CyberGrid(controller: _gridController),
        // Radial glow top-center
        Positioned(
          top: -120, left: 0, right: 0,
          child: Center(
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    _neon.withOpacity(0.07 + _pulseController.value * 0.04),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(children: [
            _buildTopBar(provider),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: const [NewsInputForm(), AnalysisHistory()],
              ),
            ),
          ]),
        ),
      ]),
      bottomNavigationBar: _buildBottomNav(provider),
    );
  }

  Widget _buildTopBar(NewsProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 10),
      child: Row(children: [
        // Logo
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: _neon,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [BoxShadow(
              color: _neon.withOpacity(0.4),
              blurRadius: 16, spreadRadius: -2,
            )],
          ),
          child: const Icon(Icons.verified_user_rounded,
              color: Color(0xFF080B14), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TRUTH LENS',
                style: GoogleFonts.rajdhani(
                  fontSize: 20, fontWeight: FontWeight.w700,
                  color: Colors.white, letterSpacing: 3,
                )),
              Text(
                provider.hasApiKey ? 'GEMINI ONLINE' : 'API KEY REQUIRED',
                style: GoogleFonts.rajdhani(
                  fontSize: 10, fontWeight: FontWeight.w600,
                  color: provider.hasApiKey ? _neon : const Color(0xFFFF9F43),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        // Status chip
        if (provider.hasApiKey)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _neon.withOpacity(0.08 + _pulseController.value * 0.04),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _neon.withOpacity(0.4)),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: _neon.withOpacity(0.6 + _pulseController.value * 0.4),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: _neon.withOpacity(0.6),
                      blurRadius: 6,
                    )],
                  ),
                ),
                const SizedBox(width: 6),
                Text('AI ON', style: GoogleFonts.rajdhani(
                  color: _neon, fontSize: 10,
                  fontWeight: FontWeight.w700, letterSpacing: 1.5,
                )),
              ]),
            ),
          ),
        const SizedBox(width: 8),
        // Settings
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => SettingsSheet(newsProvider: provider),
          ),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF141826),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E2540)),
            ),
            child: const Icon(Icons.tune_rounded,
                size: 18, color: Color(0xFF5A6A8A)),
          ),
        ),
      ]),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildBottomNav(NewsProvider provider) {
    final articles = context.watch<NewsProvider>().articles;
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C0F1B),
        border: Border(top: BorderSide(color: Color(0xFF1A1E30), width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.radar_rounded, 'SCAN'),
              _navItem(1, Icons.history_edu_rounded, 'ARCHIVE',
                  badge: articles.isNotEmpty ? '${articles.length}' : null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int idx, IconData icon, String label, {String? badge}) {
    final active = _currentIndex == idx;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = idx),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: 250.ms,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: active ? _neon.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? _neon.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Stack(clipBehavior: Clip.none, children: [
            Icon(icon, size: 22,
              color: active ? _neon : const Color(0xFF3A4A6A)),
            if (badge != null)
              Positioned(
                top: -5, right: -10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4D6D),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(badge,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                ),
              ),
          ]),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.rajdhani(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: active ? _neon : const Color(0xFF3A4A6A),
            letterSpacing: 1.5,
          )),
        ]),
      ),
    );
  }
}

// ── Animated cyber grid background ──────────────────────────────────────────
class _CyberGrid extends StatelessWidget {
  final AnimationController controller;
  const _CyberGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => CustomPaint(
        painter: _GridPainter(controller.value),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double t;
  _GridPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFB2).withOpacity(0.025)
      ..strokeWidth = 0.5;
    const spacing = 40.0;
    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Scanning line
    final scanY = (t * size.height * 2) % (size.height + 200) - 100;
    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          const Color(0xFF00FFB2).withOpacity(0.08),
          const Color(0xFF00FFB2).withOpacity(0.12),
          const Color(0xFF00FFB2).withOpacity(0.08),
          Colors.transparent,
        ],
        stops: const [0, 0.3, 0.5, 0.7, 1],
      ).createShader(Rect.fromLTWH(0, scanY - 40, size.width, 80));
    canvas.drawRect(
      Rect.fromLTWH(0, scanY - 40, size.width, 80), scanPaint);

    // Corner decorations
    _drawCorner(canvas, const Offset(20, 20), math.pi, false);
    _drawCorner(canvas, Offset(size.width - 20, 20), -math.pi / 2, false);
  }

  void _drawCorner(Canvas canvas, Offset pos, double angle, bool flip) {
    final paint = Paint()
      ..color = const Color(0xFF00FFB2).withOpacity(0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(pos.dx, pos.dy + 20)
      ..lineTo(pos.dx, pos.dy)
      ..lineTo(pos.dx + 20, pos.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.t != t;
}
