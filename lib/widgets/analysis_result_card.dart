import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/news_article.dart';

class AnalysisResultCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onClose;
  const AnalysisResultCard({super.key, required this.article, required this.onClose});

  @override
  State<AnalysisResultCard> createState() => _AnalysisResultCardState();
}

class _AnalysisResultCardState extends State<AnalysisResultCard>
    with TickerProviderStateMixin {
  bool _showDetails = false;
  bool _showEconomic = false;
  late AnimationController _glowCtrl;

  VerificationResult? get r => widget.article.verificationResult;

  static const _neon = Color(0xFF00FFB2);
  static const _card = Color(0xFF0F1320);

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() { _glowCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    if (r == null) return const SizedBox.shrink();
    final verdict = r!.verdict;
    final colors = _verdictColors(verdict);

    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors['border']!.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: colors['glow']!.withOpacity(0.15),
            blurRadius: 30, spreadRadius: -5,
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _buildVerdictHeader(verdict, colors),
        _buildSummary(colors),
        _buildConfidenceBar(colors),
        if (r!.redFlags.isNotEmpty) _buildRedFlags(colors),
        _buildExpandToggle('DETAILED ANALYSIS', _showDetails,
          () => setState(() => _showDetails = !_showDetails), colors),
        if (_showDetails) _buildDetailedAnalysis(colors),
        if (r!.economicImpact != null) ...[
          _buildExpandToggle('ECONOMIC IMPACT', _showEconomic,
            () => setState(() => _showEconomic = !_showEconomic),
            {'accent': const Color(0xFFFF9F43), 'border': const Color(0xFFFF9F43)}),
          if (_showEconomic) _buildEconomicImpact(r!.economicImpact!),
        ],
        _buildFooter(colors),
      ]),
    )
      .animate()
      .fadeIn(duration: 400.ms)
      .slideY(begin: 0.05, end: 0)
      .scale(begin: const Offset(0.97, 0.97));
  }

  // ── VERDICT HEADER ───────────────────────────────────────────────────────────
  Widget _buildVerdictHeader(NewsVerdict verdict, Map<String, Color> colors) {
    final label = verdict == NewsVerdict.fake ? 'FAKE'
      : verdict == NewsVerdict.real ? 'VERIFIED' : 'UNCERTAIN';
    final icon = verdict == NewsVerdict.fake ? Icons.gpp_bad_rounded
      : verdict == NewsVerdict.real ? Icons.verified_rounded
      : Icons.help_outline_rounded;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [
            colors['bg']!.withOpacity(0.9),
            colors['bg']!.withOpacity(0.4),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(children: [
        // Animated verdict icon
        AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, __) => Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: colors['accent']!.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colors['accent']!.withOpacity(0.3 + _glowCtrl.value * 0.3)),
              boxShadow: [BoxShadow(
                color: colors['glow']!.withOpacity(0.15 + _glowCtrl.value * 0.15),
                blurRadius: 20,
              )],
            ),
            child: Icon(icon, color: colors['accent'], size: 26),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.rajdhani(
              fontSize: 28, fontWeight: FontWeight.w700,
              color: colors['accent'],
              letterSpacing: 2,
              shadows: [Shadow(
                color: colors['glow']!.withOpacity(0.5), blurRadius: 12)],
            )),
            Text(
              widget.article.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rajdhani(
                fontSize: 13, color: Colors.white.withOpacity(0.55),
                height: 1.35, letterSpacing: 0.3,
              ),
            ),
          ],
        )),
        // Confidence badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors['accent']!.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors['accent']!.withOpacity(0.3)),
          ),
          child: Column(children: [
            Text('${(r!.confidence * 100).toInt()}%',
              style: GoogleFonts.rajdhani(
                fontSize: 20, fontWeight: FontWeight.w700,
                color: colors['accent'], letterSpacing: -0.5,
              )),
            Text('CONF', style: GoogleFonts.rajdhani(
              fontSize: 9, color: colors['accent']!.withOpacity(0.7),
              letterSpacing: 1.5, fontWeight: FontWeight.w600,
            )),
          ]),
        ),
      ]),
    );
  }

  // ── SUMMARY ──────────────────────────────────────────────────────────────────
  Widget _buildSummary(Map<String, Color> colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Text(
          r!.summary ?? r!.reasoning,
          style: GoogleFonts.rajdhani(
            fontSize: 13.5, color: Colors.white.withOpacity(0.7),
            height: 1.55, letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  // ── CONFIDENCE BAR ───────────────────────────────────────────────────────────
  Widget _buildConfidenceBar(Map<String, Color> colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('CONFIDENCE LEVEL', style: GoogleFonts.rajdhani(
            fontSize: 9, color: Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.w700, letterSpacing: 2,
          )),
          const Spacer(),
          Text(
            r!.confidence < 0.4 ? 'LOW' : r!.confidence < 0.7 ? 'MEDIUM' : 'HIGH',
            style: GoogleFonts.rajdhani(
              fontSize: 9, color: colors['accent'],
              fontWeight: FontWeight.w700, letterSpacing: 1.5,
            )),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: r!.confidence),
            duration: 800.ms,
            curve: Curves.easeOutCubic,
            builder: (_, val, __) => LinearProgressIndicator(
              value: val,
              backgroundColor: Colors.white.withOpacity(0.06),
              valueColor: AlwaysStoppedAnimation(colors['accent']),
              minHeight: 6,
            ),
          ),
        ),
      ]),
    );
  }

  // ── RED FLAGS ─────────────────────────────────────────────────────────────────
  Widget _buildRedFlags(Map<String, Color> colors) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.flag_rounded, size: 12, color: const Color(0xFFFF4D6D)),
          const SizedBox(width: 6),
          Text('RED FLAGS (${r!.redFlags.length})', style: GoogleFonts.rajdhani(
            fontSize: 9, color: const Color(0xFFFF4D6D),
            fontWeight: FontWeight.w700, letterSpacing: 2,
          )),
        ]),
        const SizedBox(height: 8),
        ...r!.redFlags.map((flag) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.only(top: 5),
              width: 5, height: 5,
              decoration: const BoxDecoration(
                color: Color(0xFFFF4D6D), shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(flag, style: GoogleFonts.rajdhani(
              fontSize: 13, color: Colors.white.withOpacity(0.75),
              height: 1.4, letterSpacing: 0.2,
            ))),
          ]),
        )),
      ]),
    );
  }

  // ── EXPAND TOGGLE ────────────────────────────────────────────────────────────
  Widget _buildExpandToggle(String label, bool expanded, VoidCallback onTap,
      Map<String, Color> colors) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: (colors['accent'] ?? _neon).withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: (colors['accent'] ?? _neon).withOpacity(0.2)),
        ),
        child: Row(children: [
          Icon(
            expanded ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
            size: 16, color: (colors['accent'] ?? _neon).withOpacity(0.8)),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.rajdhani(
            fontSize: 10, fontWeight: FontWeight.w700,
            color: (colors['accent'] ?? _neon).withOpacity(0.8),
            letterSpacing: 2,
          )),
        ]),
      ),
    );
  }

  // ── DETAILED ANALYSIS ────────────────────────────────────────────────────────
  Widget _buildDetailedAnalysis(Map<String, Color> colors) {
    if (r!.detailedAnalysis == null) return const SizedBox.shrink();
    final a = r!.detailedAnalysis!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(children: [
          _analysisRow('SOURCE CREDIBILITY', a.sourceCredibility, Icons.source_rounded),
          _divider(),
          _analysisRow('LANGUAGE QUALITY', a.languageQuality, Icons.text_snippet_rounded),
          _divider(),
          _analysisRow('FACTUAL CONSISTENCY', a.factualConsistency, Icons.fact_check_rounded),
          _divider(),
          _analysisRow('BIAS INDICATORS', a.biasIndicators, Icons.balance_rounded),
          _divider(),
          _analysisRow('VERIFICATION STATUS', a.verificationStatus, Icons.verified_rounded, last: true),
          if (r!.recommendations?.isNotEmpty == true) ...[
            _divider(),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.lightbulb_outline_rounded,
                size: 12, color: _neon.withOpacity(0.6)),
              const SizedBox(width: 6),
              Text('RECOMMENDATIONS', style: GoogleFonts.rajdhani(
                fontSize: 9, color: _neon.withOpacity(0.6),
                fontWeight: FontWeight.w700, letterSpacing: 2,
              )),
            ]),
            const SizedBox(height: 8),
            ...r!.recommendations!.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.chevron_right_rounded,
                  size: 14, color: _neon.withOpacity(0.6)),
                const SizedBox(width: 6),
                Expanded(child: Text(rec, style: GoogleFonts.rajdhani(
                  fontSize: 12.5, color: Colors.white.withOpacity(0.65),
                  height: 1.4, letterSpacing: 0.2,
                ))),
              ]),
            )),
          ],
        ]),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: -0.03, end: 0);
  }

  Widget _analysisRow(String label, String value, IconData icon, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 14, color: const Color(0xFF3A4A6A)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.rajdhani(
            fontSize: 9, color: const Color(0xFF4A5A7A),
            fontWeight: FontWeight.w700, letterSpacing: 1.5,
          )),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.rajdhani(
            fontSize: 13, color: Colors.white.withOpacity(0.8),
            height: 1.4, letterSpacing: 0.2,
          )),
        ])),
      ]),
    );
  }

  Widget _divider() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1, color: Colors.white.withOpacity(0.06)),
  );

  // ── ECONOMIC IMPACT ──────────────────────────────────────────────────────────
  Widget _buildEconomicImpact(EconomicImpact impact) {
    final sColor = _severityColor(impact.severityLevel);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A0E1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sColor.withOpacity(0.35), width: 1.5),
          boxShadow: [BoxShadow(
            color: sColor.withOpacity(0.08), blurRadius: 20)],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Severity header bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: sColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              border: Border(bottom: BorderSide(color: sColor.withOpacity(0.2))),
            ),
            child: Row(children: [
              Icon(_severityIcon(impact.severityLevel), size: 16, color: sColor),
              const SizedBox(width: 8),
              Text('${impact.severityLevel} IMPACT',
                style: GoogleFonts.rajdhani(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: sColor, letterSpacing: 2,
                )),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2035),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(impact.timeframe, style: GoogleFonts.rajdhani(
                  fontSize: 9, color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600, letterSpacing: 1,
                )),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Global
              _ecoRow(Icons.public_rounded, const Color(0xFF4FC3F7),
                'GLOBAL ECONOMY', impact.globalImpact),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withOpacity(0.05)),
              const SizedBox(height: 14),
              // India
              _ecoRow(Icons.location_on_rounded, const Color(0xFFFF8A65),
                '🇮🇳  INDIA ECONOMY', impact.indiaImpact),
              const SizedBox(height: 14),
              Container(height: 1, color: Colors.white.withOpacity(0.05)),
              const SizedBox(height: 14),
              // Sectors
              _ecoRow(Icons.business_center_rounded, const Color(0xFFCE93D8),
                'AFFECTED SECTORS', impact.affectedSectors),
              if (impact.keyIndicators.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: Colors.white.withOpacity(0.05)),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(Icons.bar_chart_rounded, size: 12,
                    color: const Color(0xFF80CBC4)),
                  const SizedBox(width: 6),
                  Text('KEY INDICATORS', style: GoogleFonts.rajdhani(
                    fontSize: 9, color: const Color(0xFF80CBC4),
                    fontWeight: FontWeight.w700, letterSpacing: 2,
                  )),
                ]),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6,
                  children: impact.keyIndicators.map((i) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF80CBC4).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF80CBC4).withOpacity(0.25)),
                    ),
                    child: Text(i, style: GoogleFonts.rajdhani(
                      fontSize: 10, color: const Color(0xFF80CBC4),
                      fontWeight: FontWeight.w700, letterSpacing: 0.5,
                    )),
                  )).toList(),
                ),
              ],
            ]),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.03, end: 0);
  }

  Widget _ecoRow(IconData icon, Color color, String title, String value) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.rajdhani(
          fontSize: 9, color: color.withOpacity(0.8),
          fontWeight: FontWeight.w700, letterSpacing: 1.5,
        )),
        const SizedBox(height: 3),
        Text(value, style: GoogleFonts.rajdhani(
          fontSize: 13, color: Colors.white.withOpacity(0.8),
          height: 1.45, letterSpacing: 0.2,
        )),
      ])),
    ]);
  }

  // ── FOOTER ───────────────────────────────────────────────────────────────────
  Widget _buildFooter(Map<String, Color> colors) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      child: Row(children: [
        Icon(Icons.access_time_rounded, size: 11,
          color: Colors.white.withOpacity(0.25)),
        const SizedBox(width: 5),
        Text(
          _timeAgo(widget.article.timestamp),
          style: GoogleFonts.rajdhani(
            fontSize: 10, color: Colors.white.withOpacity(0.25),
            letterSpacing: 0.5,
          )),
        const Spacer(),
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text('DISMISS', style: GoogleFonts.rajdhani(
              fontSize: 10, color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w700, letterSpacing: 1.5,
            )),
          ),
        ),
      ]),
    );
  }

  // ── HELPERS ──────────────────────────────────────────────────────────────────
  Map<String, Color> _verdictColors(NewsVerdict v) {
    switch (v) {
      case NewsVerdict.fake: return {
        'bg': const Color(0xFF3D0A0A),
        'border': const Color(0xFFFF4D6D),
        'accent': const Color(0xFFFF4D6D),
        'glow': const Color(0xFFFF4D6D),
      };
      case NewsVerdict.real: return {
        'bg': const Color(0xFF061A12),
        'border': _neon,
        'accent': _neon,
        'glow': _neon,
      };
      case NewsVerdict.uncertain: return {
        'bg': const Color(0xFF1A1400),
        'border': const Color(0xFFFF9F43),
        'accent': const Color(0xFFFF9F43),
        'glow': const Color(0xFFFF9F43),
      };
    }
  }

  Color _severityColor(String s) {
    switch (s.toUpperCase()) {
      case 'CRITICAL': return const Color(0xFFFF4D6D);
      case 'HIGH':     return const Color(0xFFFF8C00);
      case 'MEDIUM':   return const Color(0xFFFFD700);
      default:         return const Color(0xFF00FFB2);
    }
  }

  IconData _severityIcon(String s) {
    switch (s.toUpperCase()) {
      case 'CRITICAL': return Icons.warning_rounded;
      case 'HIGH':     return Icons.trending_up_rounded;
      case 'MEDIUM':   return Icons.remove_rounded;
      default:         return Icons.trending_down_rounded;
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'JUST NOW';
    if (d.inHours < 1) return '${d.inMinutes}M AGO';
    if (d.inDays < 1) return '${d.inHours}H AGO';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
