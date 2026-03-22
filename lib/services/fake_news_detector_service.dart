import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

/// Free-tier models (verified from official docs, March 2026):
///   gemini-2.5-flash-lite  → 15 RPM, 1000 RPD  (primary — most generous)
///   gemini-2.5-flash       → 10 RPM,  250 RPD  (fallback — better quality)
/// All use v1beta endpoint (Google AI Studio keys only)
class FakeNewsDetectorService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static const List<String> _modelChain = [
    'gemini-2.5-flash-lite', // 15 RPM, 1000 RPD — most generous free tier
    'gemini-2.5-flash',      // 10 RPM,  250 RPD — better quality fallback
  ];

  static const Duration _timeout = Duration(seconds: 30);

  String? _apiKey;

  void setApiKey(String key) => _apiKey = key.trim();
  bool get hasApiKey => _apiKey != null && _apiKey!.isNotEmpty;

  Future<VerificationResult> analyzeNews(
    String title,
    String content, {
    String? url,
    String? imageUrl,
  }) async {
    if (!hasApiKey) {
      debugPrint('[TruthLens] No API key — heuristic mode');
      return _fallbackAnalysis(title, content);
    }

    try {
      final prompt = _buildPrompt(title, content, url, imageUrl);
      final response = await _callWithModelChain(prompt, imageUrl: imageUrl);
      return _parseAIResponse(response);
    } catch (e) {
      debugPrint('[TruthLens] Error: $e');
      final msg = e.toString().toLowerCase();

      if (msg.contains('403') || msg.contains('api key') || msg.contains('invalid')) {
        throw Exception('Invalid API key. Please re-enter your key in Settings.');
      }
      if (msg.contains('all models exhausted')) {
        throw Exception(
          'Daily quota exceeded (free tier: 1500 req/day).\n'
          'Quota resets at midnight Pacific Time.\n'
          'Or create a new project at aistudio.google.com/app/apikey for fresh quota.',
        );
      }
      return _fallbackAnalysis(title, content);
    }
  }

  Future<String> _callWithModelChain(String prompt, {String? imageUrl}) async {
    final errors = <String>[];

    for (final model in _modelChain) {
      debugPrint('[TruthLens] Trying: $model');
      try {
        final result = await _callGeminiAPI(prompt, model: model, imageUrl: imageUrl);
        debugPrint('[TruthLens] ✓ Success: $model');
        return result;
      } catch (e) {
        final msg = e.toString();

        // Auth error — pointless to retry with other models
        if (msg.contains('403')) rethrow;

        if (msg.contains('429')) {
          // Per-minute quota: wait 65s for the rolling window to clear, then retry
          debugPrint('[TruthLens] 429 on $model — waiting 65s for RPM reset...');
          await Future.delayed(const Duration(seconds: 65));
          try {
            final result = await _callGeminiAPI(prompt, model: model, imageUrl: imageUrl);
            debugPrint('[TruthLens] ✓ Retry success: $model');
            return result;
          } catch (retryErr) {
            // Daily quota (RPD) likely exhausted on this model — try next
            debugPrint('[TruthLens] $model RPD exhausted — trying next');
            errors.add('$model (after retry): $retryErr');
            continue;
          }
        }

        errors.add('$model: $msg');
        debugPrint('[TruthLens] $model failed ($msg) — trying next');
      }
    }

    throw Exception('All models exhausted: ${errors.join(' | ')}');
  }

  Future<String> _callGeminiAPI(
    String prompt, {
    required String model,
    String? imageUrl,
  }) async {
    final uri = '$_baseUrl/$model:generateContent?key=$_apiKey';
    debugPrint('[TruthLens] POST $model');

    // Build parts — text always included; image added when provided
    final List<Map<String, dynamic>> parts = [{'text': prompt}];

    if (imageUrl != null && imageUrl.startsWith('data:image')) {
      final segments = imageUrl.split(',');
      if (segments.length >= 2 && segments[1].isNotEmpty) {
        final mimeType = imageUrl.split(';')[0].split(':')[1];
        parts.add({
          'inline_data': {
            'mime_type': mimeType,
            'data': segments[1], // base64 encoded image data
          }
        });
        debugPrint('[TruthLens] Image attached (${mimeType})');
      }
    }

    final response = await http
        .post(
          Uri.parse(uri),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [
              {'parts': parts}
            ],
            'generationConfig': {
              'temperature': 0.1,
              'maxOutputTokens': 2048,
            },
          }),
        )
        .timeout(_timeout);

    debugPrint('[TruthLens] $model → HTTP ${response.statusCode}');

    switch (response.statusCode) {
      case 200:
        break;
      case 429:
        throw Exception('429 rate limit');
      case 403:
        throw Exception('403 forbidden — invalid API key');
      case 404:
        throw Exception('404 model not available: $model');
      default:
        throw Exception('${response.statusCode}: ${_extractError(response.body)}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;

    if (candidates == null || candidates.isEmpty) {
      final blocked = data['promptFeedback']?['blockReason'];
      throw Exception('Empty response${blocked != null ? " (blocked: $blocked)" : ""}');
    }

    final candidate = candidates[0] as Map<String, dynamic>;
    if (candidate['finishReason'] == 'SAFETY') {
      throw Exception('Response blocked by safety filter');
    }

    final text = candidate['content']?['parts']?[0]?['text'] as String?;
    if (text == null || text.isEmpty) throw Exception('Empty text in response');

    return text;
  }

  String _extractError(String body) {
    try {
      final j = jsonDecode(body) as Map;
      return j['error']?['message']?.toString() ??
          body.substring(0, body.length.clamp(0, 200));
    } catch (_) {
      return body.substring(0, body.length.clamp(0, 200));
    }
  }

  String _buildPrompt(
      String title, String content, String? url, String? imageUrl) {
    final sb = StringBuffer();
    sb.writeln('You are a professional fact-checker and misinformation analyst.');
    sb.writeln('Analyze the news content below and return ONLY a valid JSON object.\n');
    sb.writeln('TITLE: $title');
    sb.writeln('CONTENT: $content');
    if (url != null && url.isNotEmpty) sb.writeln('SOURCE URL: $url');
    if (imageUrl != null && imageUrl.startsWith('data:')) {
      sb.writeln(
          '\n[IMAGE PROVIDED: Analyze the attached image for signs of manipulation, '
          'deepfakes, misleading visual context, or inconsistencies with the text.]');
    }
    sb.write('''

Evaluate the following criteria:
1. Source credibility — are reputable sources cited?
2. Language quality — is it sensationalist, emotional, or neutral?
3. Factual consistency — are claims logical and verifiable?
4. Bias indicators — does it lean strongly in any direction?
5. Verification status — can key claims be independently verified?
${imageUrl != null && imageUrl.startsWith('data:') ? '6. Image authenticity — does the image match the story and appear unmanipulated?' : ''}

Also perform a detailed ECONOMIC IMPACT analysis:
- Global economic impact: how this news (if true) would affect world markets, trade, commodities, or financial systems
- India-specific economic impact: specific effects on Indian GDP, rupee, stock markets (NSE/BSE), trade, inflation, employment, or key sectors like IT, pharma, agriculture, manufacturing
- Affected sectors: which industries are most impacted globally and in India
- Severity: LOW (minor ripple), MEDIUM (notable impact), HIGH (significant disruption), or CRITICAL (major crisis-level)
- Timeframe: Short-term (days/weeks), Medium-term (months), or Long-term (years)
- Key economic indicators affected: e.g. GDP, inflation, currency, trade balance, stock markets, oil prices, FDI

Return ONLY this JSON. No markdown fences. No explanation. Nothing outside the JSON braces:
{
  "verdict": "REAL",
  "confidence": 75,
  "analysis": {
    "sourceCredibility": "Brief assessment here",
    "languageQuality": "Brief assessment here",
    "factualConsistency": "Brief assessment here",
    "biasIndicators": "Brief assessment here",
    "verificationStatus": "Brief assessment here"
  },
  "summary": "2-3 sentence overall assessment of this content.",
  "redFlags": ["specific concern 1", "specific concern 2"],
  "recommendations": ["actionable step 1", "actionable step 2"],
  "economicImpact": {
    "globalImpact": "Detailed assessment of world economic impact",
    "indiaImpact": "Specific impact on Indian economy, markets, and sectors",
    "affectedSectors": "Comma-separated list of affected industries globally and in India",
    "severityLevel": "LOW",
    "timeframe": "Short-term",
    "keyIndicators": ["GDP", "inflation", "stock markets"]
  }
}

RULES:
- verdict must be exactly "REAL", "FAKE", or "UNCERTAIN"
- confidence is an integer from 0 to 100
- redFlags must be an empty array [] if no concerns found
- severityLevel must be exactly "LOW", "MEDIUM", "HIGH", or "CRITICAL"
- If the news has no clear economic relevance, set severityLevel to "LOW" and explain why
- Output the JSON object only — no text before or after it''');
    return sb.toString();
  }

  VerificationResult _parseAIResponse(String raw) {
    try {
      // Strip markdown code fences if model ignored the instruction
      String s = raw
          .trim()
          .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
          .replaceAll(RegExp(r'```\s*', multiLine: true), '')
          .trim();

      // Extract first valid JSON object
      final start = s.indexOf('{');
      final end = s.lastIndexOf('}');
      if (start == -1 || end <= start) {
        throw FormatException(
            'No JSON object found in response: ${s.substring(0, s.length.clamp(0, 300))}');
      }

      final json =
          jsonDecode(s.substring(start, end + 1)) as Map<String, dynamic>;

      final verdict =
          (json['verdict'] as String?)?.toUpperCase().trim() ?? 'UNCERTAIN';
      final rawConf = (json['confidence'] as num?)?.toDouble() ?? 50.0;
      final confidence = rawConf.clamp(0.0, 100.0) / 100.0;

      DetailedAnalysis? detailed;
      if (json['analysis'] is Map) {
        detailed = DetailedAnalysis.fromJson(
            Map<String, dynamic>.from(json['analysis'] as Map));
      }

      final redFlags = (json['redFlags'] as List?)
              ?.map((e) => e.toString())
              .where((s) => s.isNotEmpty)
              .toList() ??
          [];

      final recommendations = (json['recommendations'] as List?)
          ?.map((e) => e.toString())
          .toList();

      EconomicImpact? economicImpact;
      if (json['economicImpact'] is Map) {
        economicImpact = EconomicImpact.fromJson(
            Map<String, dynamic>.from(json['economicImpact'] as Map));
      }

      debugPrint(
          '[TruthLens] ✓ verdict=$verdict conf=${(confidence * 100).toInt()}% flags=${redFlags.length} economic=${economicImpact != null}');

      return VerificationResult(
        isFake: verdict == 'FAKE',
        confidence: confidence,
        reasoning: json['summary']?.toString() ?? 'Analysis complete.',
        redFlags: redFlags,
        sources: [],
        detailedAnalysis: detailed,
        summary: json['summary']?.toString(),
        recommendations: recommendations,
        economicImpact: economicImpact,
      );
    } catch (e) {
      debugPrint('[TruthLens] Parse error: $e\nRaw was: $raw');
      throw Exception('Failed to parse AI response: $e');
    }
  }

  VerificationResult _fallbackAnalysis(String title, String content) {
    final text = '$title $content'.toLowerCase();
    final flags = <String>[];
    int score = 0;

    const sensational = [
      'shocking', 'unbelievable', 'breaking', 'urgent', 'miracle',
      'secret', 'exposed', "you won't believe", 'they don\'t want you to know'
    ];
    if (sensational.any((w) => text.contains(w))) {
      flags.add('Sensational language detected');
      score += 20;
    }

    const sourceWords = [
      'according to', 'reported by', 'study shows', 'official',
      'spokesperson', 'published in', 'confirmed by', 'research shows'
    ];
    if (!sourceWords.any((s) => text.contains(s))) {
      flags.add('No credible sources cited');
      score += 25;
    }

    if (RegExp(r'[!?]{2,}').hasMatch(text)) {
      flags.add('Excessive punctuation');
      score += 10;
    }
    if (RegExp(r'[A-Z]{5,}').hasMatch(title)) {
      flags.add('All-caps words in headline');
      score += 10;
    }
    if (content.trim().split(RegExp(r'\s+')).length < 50) {
      flags.add('Very short content — may lack context');
      score += 15;
    }

    return VerificationResult(
      isFake: score >= 40,
      confidence: (score / 100.0).clamp(0.0, 1.0),
      reasoning:
          'Basic heuristic scan only. Add a Gemini API key in Settings for real AI-powered analysis.',
      redFlags: flags,
      sources: [],
      detailedAnalysis: DetailedAnalysis(
        sourceCredibility: 'Requires Gemini API key',
        languageQuality:
            score > 20 ? 'Some sensational language detected' : 'Appears neutral',
        factualConsistency: 'Requires Gemini API key',
        biasIndicators: 'Requires Gemini API key',
        verificationStatus: 'Add your free key from aistudio.google.com/app/apikey',
      ),
      summary:
          'Basic scan only (no API key). Add your free Gemini API key in Settings for real AI analysis.',
      recommendations: [
        'Get free key: aistudio.google.com/app/apikey → "Create in new project"',
        'Add key in Settings (⚙️ top right)',
        'Manually verify at Snopes.com or FactCheck.org',
      ],
    );
  }
}
