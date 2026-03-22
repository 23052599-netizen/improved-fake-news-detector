import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../providers/news_provider.dart';
import '../widgets/analysis_result_card.dart';

class NewsInputForm extends StatefulWidget {
  const NewsInputForm({super.key});
  @override
  State<NewsInputForm> createState() => _NewsInputFormState();
}

class _NewsInputFormState extends State<NewsInputForm>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();
  final _picker = ImagePicker();
  XFile? _selectedImage;
  late TabController _tabController;
  int _currentTab = 0;
  bool _hasAnalyzed = false;

  static const _neon = Color(0xFF00FFB2);
  static const _bg = Color(0xFF080B14);
  static const _card = Color(0xFF0F1320);
  static const _border = Color(0xFF1A2035);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (!_tabController.indexIsChanging) {
          setState(() {
            _currentTab = _tabController.index;
            _formKey.currentState?.reset();
          });
        }
      });
  }

  @override
  void dispose() {
    _titleCtrl.dispose(); _contentCtrl.dispose();
    _urlCtrl.dispose(); _imageUrlCtrl.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewsProvider>(context);
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHero(),
          _buildInputPanel(provider),
          if (provider.articles.isNotEmpty && !provider.isLoading && _hasAnalyzed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: AnalysisResultCard(
                article: provider.articles.first,
                onClose: () => setState(() => _hasAnalyzed = false),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── HERO ────────────────────────────────────────────────────────────────────
  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Row(children: [
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
            Text('INTELLIGENCE MODULE', style: GoogleFonts.rajdhani(
              fontSize: 11, color: _neon.withOpacity(0.7),
              fontWeight: FontWeight.w600, letterSpacing: 2.5,
            )),
          ]).animate().fadeIn(delay: 50.ms),
          const SizedBox(height: 14),
          // Headline
          RichText(
            text: TextSpan(children: [
              TextSpan(
                text: 'DETECT\n',
                style: GoogleFonts.rajdhani(
                  fontSize: 48, fontWeight: FontWeight.w700,
                  color: Colors.white, height: 0.95, letterSpacing: -1,
                ),
              ),
              TextSpan(
                text: 'MISINFORMATION',
                style: GoogleFonts.rajdhani(
                  fontSize: 48, fontWeight: FontWeight.w700,
                  color: _neon, height: 1.0, letterSpacing: -1,
                  shadows: [Shadow(
                    color: _neon.withOpacity(0.4), blurRadius: 20)],
                ),
              ),
            ]),
          ).animate().fadeIn(delay: 100.ms, duration: 600.ms)
            .slideX(begin: -0.05, end: 0),
          const SizedBox(height: 14),
          Text(
            'Neural analysis powered by Gemini AI.\nPaste article, URL, or upload image.',
            style: GoogleFonts.rajdhani(
              fontSize: 14, color: const Color(0xFF4A5A7A),
              height: 1.5, letterSpacing: 0.3,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          // Feature tags
          Wrap(spacing: 8, runSpacing: 8, children: [
            _tag('◈  GEMINI 2.5', _neon),
            _tag('◉  MULTIMODAL', const Color(0xFF7B8FFF)),
            _tag('◆  ECONOMIC ANALYSIS', const Color(0xFFFF9F43)),
          ]).animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(text, style: GoogleFonts.rajdhani(
        fontSize: 10, color: color,
        fontWeight: FontWeight.w700, letterSpacing: 1.2,
      )),
    );
  }

  // ── INPUT PANEL ─────────────────────────────────────────────────────────────
  Widget _buildInputPanel(NewsProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _border),
          boxShadow: [
            BoxShadow(
              color: _neon.withOpacity(0.04),
              blurRadius: 30, spreadRadius: -5,
            ),
          ],
        ),
        child: Column(children: [
          _buildTabBar(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ..._buildTabContent(),
                  const SizedBox(height: 20),
                  _buildAnalyzeButton(provider),
                  if (provider.error != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorBanner(provider.error!),
                  ],
                ],
              ),
            ),
          ),
        ]),
      ),
    ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C0F1B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(bottom: BorderSide(color: Color(0xFF1A2035))),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: UnderlineTabIndicator(
          borderSide: const BorderSide(color: _neon, width: 2),
          insets: const EdgeInsets.symmetric(horizontal: 20),
        ),
        labelColor: _neon,
        unselectedLabelColor: const Color(0xFF3A4A6A),
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.rajdhani(
          fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        unselectedLabelStyle: GoogleFonts.rajdhani(
          fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5),
        tabs: const [
          Tab(icon: Icon(Icons.text_fields_rounded, size: 16), text: 'TEXT'),
          Tab(icon: Icon(Icons.link_rounded, size: 16), text: 'URL'),
          Tab(icon: Icon(Icons.image_rounded, size: 16), text: 'IMAGE'),
        ],
      ),
    );
  }

  List<Widget> _buildTabContent() {
    switch (_currentTab) {
      case 0: return _textTab();
      case 1: return _urlTab();
      case 2: return _imageTab();
      default: return [];
    }
  }

  List<Widget> _textTab() => [
    _field(_titleCtrl, 'HEADLINE', 'Enter article headline...',
      Icons.title_rounded, required: true),
    const SizedBox(height: 12),
    _field(_contentCtrl, 'ARTICLE CONTENT', 'Paste full article text here...',
      Icons.article_rounded, lines: 7, required: true),
  ];

  List<Widget> _urlTab() => [
    _field(_urlCtrl, 'SOURCE URL', 'https://example.com/article',
      Icons.link_rounded, keyboardType: TextInputType.url,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Please enter a URL';
        if (!v.startsWith('http')) return 'URL must start with https://';
        return null;
      }),
    const SizedBox(height: 12),
    _field(_titleCtrl, 'HEADLINE (OPTIONAL)', 'Article title if known',
      Icons.title_rounded),
    const SizedBox(height: 12),
    _field(_contentCtrl, 'CONTENT (OPTIONAL)', 'Paste article text if available',
      Icons.article_rounded, lines: 4),
  ];

  List<Widget> _imageTab() => [
    if (_selectedImage != null) ...[
      Stack(children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _neon.withOpacity(0.4)),
            boxShadow: [BoxShadow(
              color: _neon.withOpacity(0.15), blurRadius: 20)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Image.file(File(_selectedImage!.path),
              height: 180, width: double.infinity, fit: BoxFit.cover),
          ),
        ),
        Positioned(top: 8, right: 8,
          child: GestureDetector(
            onTap: () => setState(() => _selectedImage = null),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.5)),
              ),
              child: const Icon(Icons.close_rounded,
                color: Color(0xFFFF4D6D), size: 16),
            ),
          ),
        ),
      ]),
    ] else ...[
      GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: _neon.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _neon.withOpacity(0.2), width: 1,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.cloud_upload_outlined,
              size: 32, color: _neon.withOpacity(0.6)),
            const SizedBox(height: 8),
            Text('TAP TO UPLOAD IMAGE', style: GoogleFonts.rajdhani(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: _neon.withOpacity(0.8), letterSpacing: 1.5,
            )),
            const SizedBox(height: 4),
            Text('JPEG  PNG  WEBP', style: GoogleFonts.rajdhani(
              fontSize: 10, color: const Color(0xFF3A4A6A), letterSpacing: 2,
            )),
          ]),
        ),
      ),
    ],
    const SizedBox(height: 12),
    Row(children: [
      Expanded(child: Divider(color: _border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Text('OR', style: GoogleFonts.rajdhani(
          fontSize: 10, color: const Color(0xFF3A4A6A),
          fontWeight: FontWeight.w700, letterSpacing: 2,
        )),
      ),
      Expanded(child: Divider(color: _border)),
    ]),
    const SizedBox(height: 12),
    _field(_imageUrlCtrl, 'IMAGE URL', 'https://example.com/image.jpg',
      Icons.insert_link_rounded, keyboardType: TextInputType.url),
    const SizedBox(height: 12),
    _field(_titleCtrl, 'CONTEXT / CAPTION (OPTIONAL)',
      'What is this image about?', Icons.chat_bubble_outline_rounded, lines: 2),
  ];

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    int lines = 1,
    bool required = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: lines,
      keyboardType: keyboardType,
      style: GoogleFonts.rajdhani(
        color: Colors.white.withOpacity(0.9), fontSize: 14, letterSpacing: 0.3),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, size: 18),
        labelStyle: GoogleFonts.rajdhani(
          fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600),
        alignLabelWithHint: lines > 1,
      ),
      validator: validator ?? (required
        ? (v) => (v == null || v.trim().isEmpty) ? 'Required' : null
        : null),
    );
  }

  Widget _buildAnalyzeButton(NewsProvider provider) {
    final loading = provider.isLoading;
    return AnimatedContainer(
      duration: 200.ms,
      height: 54,
      decoration: BoxDecoration(
        color: loading ? _neon.withOpacity(0.3) : _neon,
        borderRadius: BorderRadius.circular(14),
        boxShadow: loading ? [] : [
          BoxShadow(color: _neon.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: loading ? null : () => _submit(provider),
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.1),
          child: Center(
            child: loading
              ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _bg.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('SCANNING WITH AI...', style: GoogleFonts.rajdhani(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: _bg.withOpacity(0.8), letterSpacing: 2,
                  )),
                ])
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.radar_rounded, color: _bg, size: 20),
                  const SizedBox(width: 10),
                  Text('ANALYZE ${_tabName().toUpperCase()}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: _bg, letterSpacing: 2,
                    )),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D6D).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF4D6D).withOpacity(0.3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.warning_amber_rounded,
          color: Color(0xFFFF4D6D), size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(error, style: GoogleFonts.rajdhani(
          color: const Color(0xFFFF8099), fontSize: 13,
          height: 1.4, letterSpacing: 0.3,
        ))),
      ]),
    ).animate().shake(duration: 400.ms);
  }

  String _tabName() {
    switch (_currentTab) {
      case 0: return 'Article'; case 1: return 'URL'; default: return 'Image';
    }
  }

  Future<void> _pickImage() async {
    try {
      final img = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, maxHeight: 1080, imageQuality: 85);
      if (img != null) setState(() { _selectedImage = img; _imageUrlCtrl.clear(); });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick image: $e')));
    }
  }

  Future<void> _submit(NewsProvider provider) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_currentTab == 2 && _selectedImage == null && _imageUrlCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please upload an image or enter an image URL'),
        behavior: SnackBarBehavior.floating));
      return;
    }

    String? imageUrl = _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim();
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      final ext = _selectedImage!.path.split('.').last.toLowerCase();
      final mime = {'jpg': 'image/jpeg', 'jpeg': 'image/jpeg',
        'png': 'image/png', 'gif': 'image/gif', 'webp': 'image/webp'}[ext];
      if (mime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unsupported format. Use JPEG, PNG, or WebP.')));
        return;
      }
      imageUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    }

    var title = _titleCtrl.text.trim();
    var content = _contentCtrl.text.trim();
    final url = _urlCtrl.text.trim();
    if (_currentTab == 1) {
      if (title.isEmpty) title = url;
      if (content.isEmpty) content = 'Article from: $url — analyze for misinformation.';
    }
    if (_currentTab == 2 && title.isEmpty) {
      title = imageUrl != null && imageUrl.startsWith('data:')
        ? 'Uploaded image for analysis' : (imageUrl ?? 'Image analysis');
    }

    setState(() => _hasAnalyzed = true);
    await provider.analyzeNews(title, content,
      url: url.isEmpty ? null : url, imageUrl: imageUrl);

    if (mounted && provider.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded,
            color: Color(0xFF080B14), size: 18),
          const SizedBox(width: 10),
          Text('ANALYSIS COMPLETE', style: GoogleFonts.rajdhani(
            fontWeight: FontWeight.w700, color: const Color(0xFF080B14),
            letterSpacing: 1.5)),
        ]),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _neon,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ));
    }
  }
}
