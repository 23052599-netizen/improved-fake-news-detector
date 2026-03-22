# TruthLens — Improvement Report
## What Was Fixed & Enhanced

---

## 🐛 Bugs Fixed

### API & Service Layer (`fake_news_detector_service.dart`)

| Bug | Fix |
|-----|-----|
| `gemini-2.5-flash` model string may fail on free tier | Added automatic fallback to `gemini-1.5-flash` if primary returns 404/429/503 |
| No HTTP request timeout — could hang forever | Added 30-second timeout via `.timeout()` |
| API errors silently fell back to heuristic analysis | API key errors (400/403) now thrown with clear user-facing messages |
| Base64 image split assumed `data:...,...` format without guard | Added validation for empty base64 data |
| No check for Gemini safety blocks | Now checks `finishReason == 'SAFETY'` and `promptFeedback.blockReason` |
| `responseMimeType: application/json` not requested | Added to `generationConfig` for consistent JSON output |
| Temperature 0.3 was too high for JSON output | Reduced to 0.2 for more deterministic structured output |
| Fallback sensational-word loop added a flag for every match | Now breaks after first match to avoid score inflation |
| No word-count check in fallback | Added short-content flag (< 50 words) |

### Provider (`news_provider.dart`)

| Bug | Fix |
|-----|-----|
| API key not persisted — lost on app restart | Now saved/loaded via `SharedPreferences` |
| Analysis history not persisted | Saved to `SharedPreferences`, limited to 50 items |
| `clearAnalysis()` and `clearHistory()` were identical duplicates | Removed duplicate, kept `clearHistory()` |
| Error message included noisy `"Exception: "` prefix | Stripped with `replaceFirst()` |
| `setApiKey()` was synchronous, no key trimming | Now `async`, trims whitespace to avoid invisible failures |
| No bounds check in `removeArticle()` | Added `if (index < 0 || index >= _articles.length) return` guard |

### UI — `news_input_form.dart`

| Bug | Fix |
|-----|-----|
| Image tab submit allowed with no image AND no URL | Added explicit validation guard |
| Tab switch didn't reset form validation errors | Added `_formKey.currentState?.reset()` on tab change |
| Keyboard stayed open during analysis | Added `FocusScope.of(context).unfocus()` before submitting |
| URL tab with empty title used raw URL as title silently | Now adds proper fallback content with context label |
| Image-only tab with no title submitted empty string | Now sets a descriptive title automatically |
| `_clearSelectedImage()` called `clearAnalysis()` unnecessarily | Cleaned up to only clear image state |

### Theme (`main.dart`)

| Bug | Fix |
|-----|-----|
| `colorScheme.surfaceVariant.withOpacity()` — `surfaceVariant` deprecated in Flutter 3.22+ | Replaced with explicit hex color constants |
| Duplicate `_buildLightTheme` / `_buildDarkTheme` code | Consolidated patterns, removed duplication |
| `WidgetsFlutterBinding.ensureInitialized()` missing | Added at app startup |
| No orientation lock | Added portrait-only lock via `SystemChrome` |
| `glassmorphism` and `lottie` packages in pubspec but never used | Removed from `pubspec.yaml` |

### Settings Sheet (`settings_sheet.dart`)

| Bug | Fix |
|-----|-----|
| API key not validated before saving | Added format check (`must start with "AIza"`) |
| No way to remove/rotate the API key | Added "Remove API key" option with confirmation dialog |
| Sheet didn't handle keyboard appearing over input | Already had `viewInsets.bottom` — verified correct |
| No haptic feedback on save | Added `HapticFeedback.mediumImpact()` |

---

## 🎨 UI/UX Improvements

### Design System
- **New font pairing**: `Space Grotesk` (headings) + `DM Sans` (body) replacing generic `Inter`
- **Refined color palette**: Dark navy `#1A1A2E` + teal accent `#00C896` — more distinctive than generic purple
- **Consistent dark mode**: Proper `#0D0F1A` deep background, not just inverted light theme
- **Animated background**: Subtle gradient shift animation for visual depth

### Home Screen
- Replaced plain `Column` layout with animated background + `IndexedStack` for proper tab persistence
- Added live **"AI ON" pulsing indicator** in top bar when API key is active
- Upgraded **bottom navigation** with animated active states, badge counter for history items
- Top bar is now informative: shows API mode status

### Analyze Tab
- **Bold hero section** with `"Verify News. Fight Misinformation."` headline + decorative icon
- **Feature pills** showing model name, capabilities
- **Input card** has proper card treatment with shadow and border
- **Upload zone** is a proper tappable area (not just a button)
- Loading button shows spinner inline (not replacing the whole button)
- Error banner uses proper error color system

### Result Card (`AnalysisResultCard`)
- **Pulsing verdict icon** using `AnimationController`
- Confidence bar now shows Low/Medium/High label
- Cleaner expanded details with `UPPERCASE LABEL` micro-typography
- Verdict colors are richer: `#6B1A1A` for fake, `#0D3B2E` for real, `#4A3500` for uncertain
- `Dismiss` button instead of confusing `×` close button

### History Tab (`ResultCard`)
- Cards are now **collapsible** — tap to expand full analysis
- Compact header shows verdict badge + confidence in one glance
- Delete is less prominent (small icon) to prevent accidental taps

---

## ✅ API Integration Verification

### Gemini API Call Flow
```
User input → _analyzeNews() → _callGeminiAPIWithFallback()
    → Try: gemini-2.0-flash
    → On 404/429/503: gemini-1.5-flash
    → On 400/403: throw user-friendly error
    → On success: _parseAIResponse()
    → On parse failure: return uncertain result with recovery message
```

### What the API receives
- **Text analysis**: Title + content in structured prompt
- **URL analysis**: URL + optional title/content
- **Image analysis**: Base64 inline_data with mime_type via multimodal API

### Fallback chain
1. Gemini 2.0 Flash (primary)
2. Gemini 1.5 Flash (if primary quota/unavailable)
3. Local heuristic analysis (if no API key or network error)

---

## 📦 Dependency Cleanup

**Removed unused packages:**
- `glassmorphism: ^3.0.0` — imported but never used
- `lottie: ^2.7.0` — imported but never used

**Updated:**
- `provider: ^6.0.5` → `^6.1.1`
- `flutter_animate: ^4.3.0` → `^4.5.0`
