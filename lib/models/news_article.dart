class NewsArticle {
  final String title;
  final String content;
  final String? url;
  final String? imageUrl;
  final DateTime timestamp;
  final VerificationResult? verificationResult;

  NewsArticle({
    required this.title,
    required this.content,
    this.url,
    this.imageUrl,
    required this.timestamp,
    this.verificationResult,
  });

  NewsArticle copyWith({
    String? title,
    String? content,
    String? url,
    String? imageUrl,
    DateTime? timestamp,
    VerificationResult? verificationResult,
  }) {
    return NewsArticle(
      title: title ?? this.title,
      content: content ?? this.content,
      url: url ?? this.url,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp ?? this.timestamp,
      verificationResult: verificationResult ?? this.verificationResult,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'url': url,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'verificationResult': verificationResult?.toJson(),
    };
  }

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'],
      content: json['content'],
      url: json['url'],
      imageUrl: json['imageUrl'],
      timestamp: DateTime.parse(json['timestamp']),
      verificationResult: json['verificationResult'] != null
          ? VerificationResult.fromJson(json['verificationResult'])
          : null,
    );
  }
}

enum NewsVerdict {
  fake,      // High confidence fake news
  real,      // High confidence real news
  uncertain, // Low confidence or mixed signals
}

/// Detailed analysis breakdown for news verification
class DetailedAnalysis {
  final String sourceCredibility;
  final String languageQuality;
  final String factualConsistency;
  final String biasIndicators;
  final String verificationStatus;

  DetailedAnalysis({
    required this.sourceCredibility,
    required this.languageQuality,
    required this.factualConsistency,
    required this.biasIndicators,
    required this.verificationStatus,
  });

  Map<String, dynamic> toJson() {
    return {
      'sourceCredibility': sourceCredibility,
      'languageQuality': languageQuality,
      'factualConsistency': factualConsistency,
      'biasIndicators': biasIndicators,
      'verificationStatus': verificationStatus,
    };
  }

  factory DetailedAnalysis.fromJson(Map<String, dynamic> json) {
    return DetailedAnalysis(
      sourceCredibility: json['sourceCredibility'] ?? '',
      languageQuality: json['languageQuality'] ?? '',
      factualConsistency: json['factualConsistency'] ?? '',
      biasIndicators: json['biasIndicators'] ?? '',
      verificationStatus: json['verificationStatus'] ?? '',
    );
  }
}

/// Economic impact analysis of the news on global and Indian economy
class EconomicImpact {
  final String globalImpact;       // Overall world economic impact
  final String indiaImpact;        // Specific impact on Indian economy
  final String affectedSectors;    // Industries/sectors most affected
  final String severityLevel;      // LOW / MEDIUM / HIGH / CRITICAL
  final String timeframe;          // Short-term / Medium-term / Long-term
  final List<String> keyIndicators; // e.g. GDP, inflation, trade, markets

  EconomicImpact({
    required this.globalImpact,
    required this.indiaImpact,
    required this.affectedSectors,
    required this.severityLevel,
    required this.timeframe,
    required this.keyIndicators,
  });

  Map<String, dynamic> toJson() => {
    'globalImpact': globalImpact,
    'indiaImpact': indiaImpact,
    'affectedSectors': affectedSectors,
    'severityLevel': severityLevel,
    'timeframe': timeframe,
    'keyIndicators': keyIndicators,
  };

  factory EconomicImpact.fromJson(Map<String, dynamic> json) => EconomicImpact(
    globalImpact: json['globalImpact'] ?? 'Unable to assess',
    indiaImpact: json['indiaImpact'] ?? 'Unable to assess',
    affectedSectors: json['affectedSectors'] ?? 'Unknown',
    severityLevel: json['severityLevel'] ?? 'LOW',
    timeframe: json['timeframe'] ?? 'Unknown',
    keyIndicators: List<String>.from(json['keyIndicators'] ?? []),
  );
}

class VerificationResult {
  final bool isFake;
  final double confidence;
  final String reasoning;
  final List<String> redFlags;
  final List<String> sources;
  
  // New detailed analysis fields
  final DetailedAnalysis? detailedAnalysis;
  final String? summary;
  final List<String>? recommendations;
  final EconomicImpact? economicImpact;

  VerificationResult({
    required this.isFake,
    required this.confidence,
    required this.reasoning,
    required this.redFlags,
    required this.sources,
    this.detailedAnalysis,
    this.summary,
    this.recommendations,
    this.economicImpact,
  });

  /// Get the verdict classification based on confidence and isFake flag
  /// 
  /// Logic:
  /// - confidence < 0.50: UNCERTAIN (not enough evidence either way)
  /// - confidence >= 0.50 && isFake == true: FAKE (likely fake news)
  /// - confidence >= 0.50 && isFake == false: REAL (appears legitimate)
  NewsVerdict get verdict {
    if (confidence < 0.50) {
      return NewsVerdict.uncertain;
    }
    return isFake ? NewsVerdict.fake : NewsVerdict.real;
  }

  /// Get a human-readable verdict label
  String get verdictLabel {
    switch (verdict) {
      case NewsVerdict.fake:
        return 'Likely Fake News';
      case NewsVerdict.real:
        return 'Appears Legitimate';
      case NewsVerdict.uncertain:
        return 'Uncertain';
    }
  }

  /// Get a detailed verdict description
  String get verdictDescription {
    switch (verdict) {
      case NewsVerdict.fake:
        return 'This article shows strong indicators of misinformation';
      case NewsVerdict.real:
        return 'This article appears to follow journalistic standards';
      case NewsVerdict.uncertain:
        return 'This article appears to follow journalistic standards with proper sourcing. However, always cross-reference important information with multiple trusted sources.';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'isFake': isFake,
      'confidence': confidence,
      'reasoning': reasoning,
      'redFlags': redFlags,
      'sources': sources,
      'detailedAnalysis': detailedAnalysis?.toJson(),
      'summary': summary,
      'recommendations': recommendations,
      'economicImpact': economicImpact?.toJson(),
    };
  }

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      isFake: json['isFake'],
      confidence: json['confidence'].toDouble(),
      reasoning: json['reasoning'],
      redFlags: List<String>.from(json['redFlags']),
      sources: List<String>.from(json['sources']),
      detailedAnalysis: json['detailedAnalysis'] != null
          ? DetailedAnalysis.fromJson(json['detailedAnalysis'])
          : null,
      summary: json['summary'],
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'])
          : null,
      economicImpact: json['economicImpact'] != null
          ? EconomicImpact.fromJson(json['economicImpact'])
          : null,
    );
  }

  /// Create from Supabase edge function response format
  factory VerificationResult.fromSupabaseResponse(Map<String, dynamic> json) {
    // Map REAL/FAKE/UNCERTAIN to isFake boolean
    final verdict = json['verdict'] as String;
    final isFake = verdict == 'FAKE';
    final confidence = (json['confidence'] as num).toDouble() / 100.0; // Convert 0-100 to 0-1
    
    return VerificationResult(
      isFake: isFake,
      confidence: confidence,
      reasoning: json['summary'] ?? '',
      redFlags: List<String>.from(json['redFlags'] ?? []),
      sources: [], // Supabase format doesn't have sources in the same way
      detailedAnalysis: json['analysis'] != null
          ? DetailedAnalysis.fromJson(json['analysis'])
          : null,
      summary: json['summary'],
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}
