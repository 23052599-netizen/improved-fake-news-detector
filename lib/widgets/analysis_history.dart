import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/result_card.dart';

class AnalysisHistory extends StatelessWidget {
  const AnalysisHistory({super.key});

  static const _neon = Color(0xFF00FFB2);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewsProvider>(context);
    final articles = provider.articles;

    if (articles.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _neon.withOpacity(0.06),
              shape: BoxShape.circle,
              border: Border.all(color: _neon.withOpacity(0.15)),
            ),
            child: Icon(Icons.history_edu_rounded,
              size: 36, color: _neon.withOpacity(0.3)),
          ),
          const SizedBox(height: 20),
          Text('NO ARCHIVES', style: GoogleFonts.rajdhani(
            fontSize: 16, color: Colors.white.withOpacity(0.2),
            fontWeight: FontWeight.w700, letterSpacing: 3,
          )),
          const SizedBox(height: 8),
          Text('Analyzed articles will appear here', style: GoogleFonts.rajdhani(
            fontSize: 12, color: Colors.white.withOpacity(0.15),
            letterSpacing: 0.5,
          )),
        ]).animate().fadeIn(duration: 500.ms),
      );
    }

    return Column(children: [
      // Header
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        child: Row(children: [
          Container(
            width: 3, height: 14,
            decoration: BoxDecoration(
              color: _neon,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [BoxShadow(
                color: _neon.withOpacity(0.6), blurRadius: 8)],
            ),
          ),
          const SizedBox(width: 10),
          Text('ANALYSIS ARCHIVE', style: GoogleFonts.rajdhani(
            fontSize: 11, color: _neon.withOpacity(0.7),
            fontWeight: FontWeight.w700, letterSpacing: 2.5,
          )),
          const Spacer(),
          Text('${articles.length} RECORDS',
            style: GoogleFonts.rajdhani(
              fontSize: 10, color: Colors.white.withOpacity(0.25),
              letterSpacing: 1.5, fontWeight: FontWeight.w600,
            )),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          itemCount: articles.length,
          itemBuilder: (ctx, i) => ResultCard(
            article: articles[i],
            onDelete: () => provider.removeArticle(i),
          ).animate(delay: (i * 50).ms)
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.05, end: 0),
        ),
      ),
    ]);
  }
}
