import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_article.dart';

class ResultCard extends StatefulWidget {
  final NewsArticle article;
  final VoidCallback onDelete;
  const ResultCard({super.key, required this.article, required this.onDelete});
  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard> {
  bool _expanded = false;

  VerificationResult? get r => widget.article.verificationResult;

  static const _neon = Color(0xFF00FFB2);
  static const _card = Color(0xFF0F1320);
  static const _border = Color(0xFF1A2035);

  @override
  Widget build(BuildContext context) {
    if (r == null) return const SizedBox.shrink();
    final verdict = r!.verdict;
    final accent = _accentColor(verdict);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.2)),
      ),
      child: Column(children: [
        // Header row
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              // Verdict dot
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: accent, shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: accent.withOpacity(0.5), blurRadius: 8)],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.article.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.85), letterSpacing: 0.2,
                    )),
                  const SizedBox(height: 2),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: accent.withOpacity(0.3)),
                      ),
                      child: Text(_verdictLabel(verdict), style: GoogleFonts.rajdhani(
                        fontSize: 9, color: accent,
                        fontWeight: FontWeight.w700, letterSpacing: 1.5,
                      )),
                    ),
                    const SizedBox(width: 6),
                    Text('${(r!.confidence * 100).toInt()}% CONF',
                      style: GoogleFonts.rajdhani(
                        fontSize: 9, color: Colors.white.withOpacity(0.3),
                        letterSpacing: 1,
                      )),
                    if (r!.economicImpact != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: _severityColor(r!.economicImpact!.severityLevel)
                            .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('ECO',
                          style: GoogleFonts.rajdhani(
                            fontSize: 8,
                            color: _severityColor(r!.economicImpact!.severityLevel),
                            fontWeight: FontWeight.w700, letterSpacing: 1,
                          )),
                      ),
                    ],
                  ]),
                ],
              )),
              const SizedBox(width: 8),
              // Time
              Text(_timeAgo(widget.article.timestamp),
                style: GoogleFonts.rajdhani(
                  fontSize: 9, color: Colors.white.withOpacity(0.2),
                  letterSpacing: 0.5,
                )),
              const SizedBox(width: 8),
              Icon(
                _expanded ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
                size: 18, color: Colors.white.withOpacity(0.25)),
            ]),
          ),
        ),

        // Expanded content
        if (_expanded) ...[
          Container(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary
                Text(r!.summary ?? r!.reasoning,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13, color: Colors.white.withOpacity(0.6),
                    height: 1.5, letterSpacing: 0.2,
                  )),

                // Red flags
                if (r!.redFlags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...r!.redFlags.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(Icons.circle, size: 5,
                          color: Color(0xFFFF4D6D)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: GoogleFonts.rajdhani(
                        fontSize: 12, color: Colors.white.withOpacity(0.55),
                        height: 1.4,
                      ))),
                    ]),
                  )),
                ],

                // Economic impact compact
                if (r!.economicImpact != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _severityColor(r!.economicImpact!.severityLevel)
                        .withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _severityColor(r!.economicImpact!.severityLevel)
                          .withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.trending_up_rounded, size: 12,
                            color: _severityColor(r!.economicImpact!.severityLevel)),
                          const SizedBox(width: 6),
                          Text('ECONOMIC · ${r!.economicImpact!.severityLevel}',
                            style: GoogleFonts.rajdhani(
                              fontSize: 9, fontWeight: FontWeight.w700,
                              color: _severityColor(r!.economicImpact!.severityLevel),
                              letterSpacing: 1.5,
                            )),
                        ]),
                        const SizedBox(height: 6),
                        Text('🌍 ${r!.economicImpact!.globalImpact}',
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rajdhani(
                            fontSize: 12, color: Colors.white.withOpacity(0.6),
                            height: 1.4,
                          )),
                        const SizedBox(height: 4),
                        Text('🇮🇳 ${r!.economicImpact!.indiaImpact}',
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.rajdhani(
                            fontSize: 12, color: Colors.white.withOpacity(0.6),
                            height: 1.4,
                          )),
                      ],
                    ),
                  ),
                ],

                // Source URL
                if (widget.article.url != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => launchUrl(Uri.parse(widget.article.url!)),
                    child: Row(children: [
                      Icon(Icons.open_in_new_rounded, size: 12, color: accent),
                      const SizedBox(width: 6),
                      Expanded(child: Text(
                        widget.article.url!,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rajdhani(
                          fontSize: 11, color: accent,
                          decoration: TextDecoration.underline,
                          decorationColor: accent.withOpacity(0.4),
                        ),
                      )),
                    ]),
                  ),
                ],

                // Delete
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: widget.onDelete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D6D).withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFFF4D6D).withOpacity(0.2)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.delete_outline_rounded,
                          size: 12, color: Color(0xFFFF4D6D)),
                        const SizedBox(width: 5),
                        Text('DELETE', style: GoogleFonts.rajdhani(
                          fontSize: 9, color: const Color(0xFFFF4D6D),
                          fontWeight: FontWeight.w700, letterSpacing: 1.5,
                        )),
                      ]),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 200.ms).slideY(begin: -0.02, end: 0),
        ],
      ]),
    );
  }

  Color _accentColor(NewsVerdict v) {
    switch (v) {
      case NewsVerdict.fake: return const Color(0xFFFF4D6D);
      case NewsVerdict.real: return _neon;
      case NewsVerdict.uncertain: return const Color(0xFFFF9F43);
    }
  }

  String _verdictLabel(NewsVerdict v) {
    switch (v) {
      case NewsVerdict.fake: return 'FAKE';
      case NewsVerdict.real: return 'VERIFIED';
      case NewsVerdict.uncertain: return 'UNCERTAIN';
    }
  }

  Color _severityColor(String s) {
    switch (s.toUpperCase()) {
      case 'CRITICAL': return const Color(0xFFFF4D6D);
      case 'HIGH':     return const Color(0xFFFF8C00);
      case 'MEDIUM':   return const Color(0xFFFFD700);
      default:         return _neon;
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'NOW';
    if (d.inHours < 1) return '${d.inMinutes}M';
    if (d.inDays < 1) return '${d.inHours}H';
    return '${dt.day}/${dt.month}';
  }
}
