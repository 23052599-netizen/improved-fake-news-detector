# 🛡️ Fake News Detector - Flutter App

A modern Flutter application that uses **AI-powered analysis** to help users identify potentially fake news articles. Built with Google's **Gemini 1.5 Flash** model via **Google AI Studio API**.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![AI](https://img.shields.io/badge/AI-Gemini%201.5%20Flash-orange.svg)

## ✨ Features

### 🤖 AI-Powered Analysis
- **Real AI Detection**: Uses Google's Gemini 1.5 Flash model directly
- **Detailed Analysis**: 5 comprehensive analysis categories
- **Text Analysis**: Analyzes article titles and content for authenticity
- **Image Support**: Upload images or provide URLs for visual context analysis
- **Confidence Scoring**: Get percentage-based confidence ratings
- **Smart Recommendations**: Actionable verification steps

### 🎯 Analysis Categories
1. **Source Credibility** - Evaluates source reliability and citations
2. **Language Quality** - Checks for sensationalism and professionalism
3. **Factual Consistency** - Identifies logical inconsistencies
4. **Bias Indicators** - Detects political or ideological bias
5. **Verification Status** - Assesses verifiability of claims

### 🎨 Modern UI/UX
- **Material Design 3**: Latest design system with dynamic theming
- **Glassmorphism Effects**: Beautiful frosted glass UI elements
- **Smooth Animations**: Flutter Animate for delightful interactions
- **Google Fonts**: Professional typography with Inter font family
- **Dark Mode**: Full dark theme support
- **Gradient Backgrounds**: Eye-catching color schemes
- **Expandable Details**: Collapsible detailed analysis sections

### 📱 Core Functionality
- **Multi-Input Support**: Text, URLs, and images
- **Analysis History**: Track all your fact-checks
- **Red Flag Detection**: Identifies specific problematic elements
- **Verdict System**: REAL, FAKE, or UNCERTAIN classification
- **Offline Fallback**: Basic analysis when API is unavailable

## 🧠 AI Model Information

### Primary Model
- **Model**: Google Gemini 1.5 Flash
- **Provider**: Google AI Studio (Direct API)
- **Endpoint**: `generativelanguage.googleapis.com`
- **Location**: `lib/services/fake_news_detector_service.dart`

### Why Google AI Studio?
✅ **Completely FREE** - 1,500 requests/day  
✅ **No Rate Limits** - Unlike OpenRouter  
✅ **Direct API** - Faster, more reliable  
✅ **Better Performance** - Google's infrastructure  
✅ **Easy Setup** - Just need a Google account  

### Analysis Capabilities
1. **Sensational Language Detection**: Identifies clickbait and exaggerated claims
2. **Source Credibility**: Checks for proper citations and references
3. **Emotional Manipulation**: Detects attempts to trigger emotional responses
4. **Formatting Analysis**: Spots excessive punctuation and ALL CAPS
5. **Image-Text Consistency**: Verifies if images match article content (when image provided)
6. **Content Quality**: Evaluates overall article structure and professionalism

### Fallback System
If no API key is configured, the app uses a local rule-based analysis system that checks for:
- Sensational keywords
- Formatting red flags
- Source indicators
- Emotional manipulation patterns

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Google AI Studio API key (free at [aistudio.google.com](https://aistudio.google.com))

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/ashu13579/fake-news-detector-flutter.git
cd fake-news-detector-flutter
```

2. **Install dependencies**:
```bash
flutter pub get
```

3. **Run the app**:
```bash
flutter run
```

### Setting Up AI Analysis

#### Quick Setup (2 minutes):

1. **Get a Google AI Studio API Key**:
   - Visit [aistudio.google.com/app/apikey](https://aistudio.google.com/app/apikey)
   - Sign in with your Google account
   - Click "Create API Key"
   - Copy the key (starts with `AIzaSy...`)

2. **Add API Key in App**:
   - Open the app
   - Tap the settings icon (⚙️) in the top right
   - Paste your API key
   - Tap "Save Key"
   - You're ready to use AI analysis!

📚 **Detailed Setup Guide**: See [docs/GOOGLE_AI_SETUP.md](docs/GOOGLE_AI_SETUP.md)

## 📱 Usage

### Analyzing an Article

1. **Navigate to Analyze Tab**:
   - Enter the article title
   - Paste the article content (minimum 50 characters)
   - Optionally add source URL
   - Optionally upload an image or provide image URL

2. **Run Analysis**:
   - Tap "Analyze Article"
   - Wait for AI processing (2-3 seconds)
   - View results in the History tab

3. **Understanding Results**:
   - **🔵 Blue Badge**: Appears Legitimate (REAL)
   - **🔴 Red Badge**: Likely Fake News (FAKE)
   - **🟠 Orange Badge**: Uncertain (needs more verification)
   - **Confidence Score**: Percentage of certainty (0-100%)
   - **Summary**: 2-3 sentence overall assessment
   - **Red Flags**: Specific issues found
   - **Detailed Analysis**: Expandable 5-category breakdown
   - **Recommendations**: Actionable verification steps

### Verdict Classification

| Verdict | Condition | Badge Color | Meaning |
|---------|-----------|-------------|---------|
| **REAL** | Confidence ≥ 50% + Not Fake | 🔵 Blue | Appears legitimate |
| **FAKE** | Confidence ≥ 50% + Is Fake | 🔴 Red | Likely misinformation |
| **UNCERTAIN** | Confidence < 50% | 🟠 Orange | Insufficient evidence |

## 🏗️ Project Structure

```
lib/
├── main.dart                          # App entry point with theme
├── models/
│   └── news_article.dart             # Data models (Article, Result, DetailedAnalysis)
├── providers/
│   └── news_provider.dart            # State management
├── screens/
│   └── home_screen.dart              # Main screen with navigation
├── services/
│   └── fake_news_detector_service.dart # Google AI Studio integration ⭐
└── widgets/
    ├── analysis_history.dart         # History view
    ├── news_input_form.dart          # Input form with image support
    ├── result_card.dart              # Result display with expandable details
    └── settings_sheet.dart           # API key configuration

docs/
├── GOOGLE_AI_SETUP.md                # Detailed setup guide
└── AI_MODELS.md                      # Model alternatives (legacy)
```

## 🎨 UI Components

### Modern Design Elements
- **Glassmorphism Cards**: Frosted glass effect containers
- **Gradient Backgrounds**: Multi-color gradients
- **Animated Transitions**: Smooth fade-ins and slides
- **Expandable Sections**: Collapsible detailed analysis
- **Confidence Progress Bar**: Visual confidence indicator
- **Color-Coded Verdicts**: Instant visual feedback
- **Rounded Corners**: 16-24px border radius throughout
- **Elevation Shadows**: Depth with colored shadows

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1              # State management
  http: ^1.1.0                  # API calls
  shared_preferences: ^2.2.2    # Local storage
  google_fonts: ^6.1.0          # Typography
  flutter_animate: ^4.3.0       # Animations
  cached_network_image: ^3.3.0  # Image caching
  url_launcher: ^6.2.2          # URL handling
```

## 🔧 Configuration

### API Key Storage
- Keys are stored locally using `shared_preferences`
- Never committed to version control
- Can be changed anytime in settings

### Customization
- **Theme**: Edit `main.dart` for color schemes
- **Model**: Change in `fake_news_detector_service.dart` (line 7)
- **Prompt**: Modify `_buildPrompt()` method for different analysis focus
- **UI**: Customize widgets in `lib/widgets/`

## 📊 Free Tier Limits

| Feature | Google AI Studio Free Tier |
|---------|---------------------------|
| **Requests per day** | 1,500 |
| **Requests per minute** | 15 |
| **Cost** | $0.00 |
| **Model** | Gemini 1.5 Flash |

**For this app:**
- Each analysis = 1 request
- ~50 articles per hour
- ~1,500 articles per day
- Completely free!

## 🛠️ Troubleshooting

### Common Issues

**"API key not valid"**
- Check you copied the full key (starts with `AIzaSy`)
- Remove any extra spaces
- Try creating a new API key

**"API Error: 403"**
- Enable the Generative Language API
- Go to [console.cloud.google.com](https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com)
- Click "Enable"

**"Quota exceeded"**
- You've hit the daily limit (1,500 requests)
- Wait until tomorrow (resets at midnight PST)
- Or upgrade to paid tier

**Everything shows "Uncertain"**
- Check your internet connection
- Verify API key is correct
- Try analyzing different content
- Check if you've hit rate limits

📚 **Full Troubleshooting Guide**: See [docs/GOOGLE_AI_SETUP.md](docs/GOOGLE_AI_SETUP.md)

## 🔐 Security

- ✅ API keys stored locally (not in code)
- ✅ No data sent to third parties
- ✅ HTTPS for all API calls
- ✅ No user data collection
- ✅ Open source for transparency

## 🚀 Future Enhancements

- [ ] Multi-language support
- [ ] Browser extension
- [ ] Batch analysis
- [ ] Export reports
- [ ] Share results
- [ ] Fact-checking database integration
- [ ] Real-time news monitoring
- [ ] Chrome extension

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 👨‍💻 Author

**Ashutosh Yadav**
- GitHub: [@ashu13579](https://github.com/ashu13579)
- Email: 23053934@kiit.ac.in

## 🙏 Acknowledgments

- Google AI Studio for free Gemini API access
- Flutter team for the amazing framework
- Material Design team for design guidelines
- Open source community for inspiration

## 📞 Support

If you encounter any issues or have questions:
1. Check [docs/GOOGLE_AI_SETUP.md](docs/GOOGLE_AI_SETUP.md)
2. Open an issue on GitHub
3. Contact via email

---

**Made with ❤️ using Flutter and Google Gemini AI**
