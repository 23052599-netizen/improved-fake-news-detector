import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/news_provider.dart';

class SettingsSheet extends StatefulWidget {
  final NewsProvider newsProvider;
  const SettingsSheet({super.key, required this.newsProvider});
  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final _ctrl = TextEditingController();
  bool _obscure = true;
  bool _saved = false;

  static const _neon = Color(0xFF00FFB2);
  static const _bg = Color(0xFF080B14);
  static const _card = Color(0xFF0F1320);
  static const _border = Color(0xFF1A2035);

  @override
  void initState() {
    super.initState();
    if (widget.newsProvider.hasApiKey) _ctrl.text = '••••••••••••••••';
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0xFF1E2540))),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Handle
            Center(child: Container(
              width: 40, height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFF2A3050),
                borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 24),

            // Title
            Row(children: [
              Container(width: 3, height: 16,
                decoration: BoxDecoration(
                  color: _neon, borderRadius: BorderRadius.circular(2),
                  boxShadow: [BoxShadow(
                    color: _neon.withOpacity(0.6), blurRadius: 8)],
                )),
              const SizedBox(width: 10),
              Text('CONFIGURATION', style: GoogleFonts.rajdhani(
                fontSize: 13, color: _neon.withOpacity(0.7),
                fontWeight: FontWeight.w700, letterSpacing: 2.5,
              )),
            ]),
            const SizedBox(height: 6),
            Text('API Settings', style: GoogleFonts.rajdhani(
              fontSize: 26, fontWeight: FontWeight.w700,
              color: Colors.white, letterSpacing: -0.5,
            )),
            const SizedBox(height: 24),

            // Status indicator
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.newsProvider.hasApiKey
                  ? _neon.withOpacity(0.05)
                  : const Color(0xFFFF9F43).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.newsProvider.hasApiKey
                    ? _neon.withOpacity(0.2)
                    : const Color(0xFFFF9F43).withOpacity(0.2)),
              ),
              child: Row(children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: widget.newsProvider.hasApiKey
                      ? _neon : const Color(0xFFFF9F43),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                      color: (widget.newsProvider.hasApiKey
                        ? _neon : const Color(0xFFFF9F43)).withOpacity(0.6),
                      blurRadius: 8,
                    )],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(
                  widget.newsProvider.hasApiKey
                    ? 'Gemini API connected — AI analysis active'
                    : 'No API key — running in basic heuristic mode',
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: widget.newsProvider.hasApiKey
                      ? _neon.withOpacity(0.8)
                      : const Color(0xFFFF9F43).withOpacity(0.8),
                    letterSpacing: 0.3,
                  ),
                )),
              ]),
            ),

            const SizedBox(height: 20),

            // API Key label
            Text('GEMINI API KEY', style: GoogleFonts.rajdhani(
              fontSize: 10, color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w700, letterSpacing: 2,
            )),
            const SizedBox(height: 8),

            // Input
            Container(
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Row(children: [
                const SizedBox(width: 14),
                const Icon(Icons.key_rounded, size: 16,
                  color: Color(0xFF3A4A6A)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    obscureText: _obscure,
                    onTap: () {
                      if (widget.newsProvider.hasApiKey) {
                        _ctrl.clear();
                        _obscure = false;
                        setState(() {});
                      }
                    },
                    style: GoogleFonts.rajdhani(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14, letterSpacing: 0.5),
                    decoration: InputDecoration(
                      hintText: 'AIzaSy...',
                      hintStyle: GoogleFonts.rajdhani(
                        color: const Color(0xFF2E3D5A), fontSize: 13),
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                    size: 16, color: const Color(0xFF3A4A6A)),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ]),
            ),
            const SizedBox(height: 8),
            Text(
              'Get your free key at aistudio.google.com/app/apikey',
              style: GoogleFonts.rajdhani(
                fontSize: 11, color: const Color(0xFF3A4A6A), letterSpacing: 0.3)),
            const SizedBox(height: 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: 200.ms,
                height: 50,
                decoration: BoxDecoration(
                  color: _saved ? _neon.withOpacity(0.2) : _neon,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _saved ? [] : [BoxShadow(
                    color: _neon.withOpacity(0.3), blurRadius: 16,
                    offset: const Offset(0, 4),
                  )],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _saveKey,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(child: Text(
                      _saved ? '✓  SAVED' : 'SAVE API KEY',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: _saved ? _neon : _bg, letterSpacing: 2,
                      ),
                    )),
                  ),
                ),
              ),
            ),

            if (widget.newsProvider.hasApiKey) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _removeKey,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFFFF4D6D), width: 1),
                    ),
                  ),
                  child: Text('REMOVE API KEY',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12, color: const Color(0xFFFF4D6D),
                      fontWeight: FontWeight.w700, letterSpacing: 2,
                    )),
                ),
              ),
            ],

            const SizedBox(height: 24),
            // Model info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ACTIVE MODELS', style: GoogleFonts.rajdhani(
                    fontSize: 9, color: const Color(0xFF3A4A6A),
                    fontWeight: FontWeight.w700, letterSpacing: 2,
                  )),
                  const SizedBox(height: 10),
                  _modelRow('gemini-2.5-flash-lite', 'PRIMARY', '1,000 RPD', _neon),
                  const SizedBox(height: 8),
                  _modelRow('gemini-2.5-flash', 'FALLBACK', '250 RPD',
                    const Color(0xFF7B8FFF)),
                ],
              ),
            ),
          ]).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
        ),
      ),
    );
  }

  Widget _modelRow(String model, String role, String quota, Color color) {
    return Row(children: [
      Container(
        width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: color.withOpacity(0.5), blurRadius: 6)]),
      ),
      const SizedBox(width: 8),
      Expanded(child: Text(model, style: GoogleFonts.rajdhani(
        fontSize: 12, color: Colors.white.withOpacity(0.7), letterSpacing: 0.3))),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(role, style: GoogleFonts.rajdhani(
          fontSize: 8, color: color,
          fontWeight: FontWeight.w700, letterSpacing: 1,
        )),
      ),
      const SizedBox(width: 6),
      Text(quota, style: GoogleFonts.rajdhani(
        fontSize: 9, color: const Color(0xFF3A4A6A), letterSpacing: 0.5)),
    ]);
  }

  void _saveKey() {
    final key = _ctrl.text.trim();
    if (key.isEmpty || key.contains('•')) return;
    if (!key.startsWith('AIza')) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid key format (must start with "AIza")',
          style: GoogleFonts.rajdhani()),
        backgroundColor: const Color(0xFFFF4D6D),
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    HapticFeedback.mediumImpact();
    widget.newsProvider.setApiKey(key);
    setState(() { _saved = true; _obscure = true; });
    Future.delayed(1.5.seconds, () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _removeKey() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F1320),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1A2035))),
        title: Text('Remove API Key?', style: GoogleFonts.rajdhani(
          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text('You will revert to basic heuristic mode.',
          style: GoogleFonts.rajdhani(
            color: Colors.white.withOpacity(0.5), fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: GoogleFonts.rajdhani(
              color: Colors.white.withOpacity(0.4), letterSpacing: 1))),
          TextButton(
            onPressed: () {
              widget.newsProvider.removeApiKey();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: Text('REMOVE', style: GoogleFonts.rajdhani(
              color: const Color(0xFFFF4D6D),
              fontWeight: FontWeight.w700, letterSpacing: 1))),
        ],
      ),
    );
  }
}
