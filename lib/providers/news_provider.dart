import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_article.dart';
import '../services/fake_news_detector_service.dart';

class NewsProvider with ChangeNotifier {
  final FakeNewsDetectorService _detectorService = FakeNewsDetectorService();

  List<NewsArticle> _articles = [];
  bool _isLoading = false;
  String? _error;
  String? _apiKey;

  List<NewsArticle> get articles => _articles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  // FIX: trim the key to avoid whitespace issues from copy-paste
  bool get hasApiKey => _apiKey != null && _apiKey!.trim().isNotEmpty;

  NewsProvider() {
    _loadApiKey();
    _loadHistory();
  }

  // FIX: Persist API key across sessions using SharedPreferences
  Future<void> _loadApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('gemini_api_key');
      if (saved != null && saved.isNotEmpty) {
        _apiKey = saved;
        _detectorService.setApiKey(saved);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load API key: $e');
    }
  }

  // FIX: Persist history across sessions
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('analysis_history');
      if (json != null) {
        final list = jsonDecode(json) as List;
        _articles = list.map((e) => NewsArticle.fromJson(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to load history: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // FIX: Only save the last 50 items to avoid unbounded storage growth
      final toSave = _articles.take(50).toList();
      await prefs.setString('analysis_history', jsonEncode(toSave.map((a) => a.toJson()).toList()));
    } catch (e) {
      debugPrint('Failed to save history: $e');
    }
  }

  Future<void> setApiKey(String key) async {
    // FIX: Trim whitespace to prevent subtle API failures
    final trimmed = key.trim();
    _apiKey = trimmed;
    _detectorService.setApiKey(trimmed);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_api_key', trimmed);
    } catch (e) {
      debugPrint('Failed to save API key: $e');
    }
    notifyListeners();
  }

  Future<void> removeApiKey() async {
    _apiKey = null;
    _detectorService.setApiKey('');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('gemini_api_key');
    } catch (e) {
      debugPrint('Failed to remove API key: $e');
    }
    notifyListeners();
  }

  // FIX: clearAnalysis and clearHistory were duplicates — unified into one method
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> analyzeNews(
    String title,
    String content, {
    String? url,
    String? imageUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final article = NewsArticle(
        title: title,
        content: content,
        url: url,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
      );

      final result = await _detectorService.analyzeNews(
        title,
        content,
        url: url,
        imageUrl: imageUrl,
      );

      final verifiedArticle = article.copyWith(verificationResult: result);
      _articles.insert(0, verifiedArticle);

      // FIX: Save history after each analysis
      await _saveHistory();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // FIX: Better error messages — strip "Exception: " prefix that Dart adds
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIX: Renamed clearAnalysis → clearHistory (they were identical, remove duplicate)
  void clearHistory() {
    _articles.clear();
    _saveHistory();
    notifyListeners();
  }

  void removeArticle(int index) {
    if (index < 0 || index >= _articles.length) return;
    _articles.removeAt(index);
    _saveHistory();
    notifyListeners();
  }
}
