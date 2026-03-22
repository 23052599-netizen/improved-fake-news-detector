# Google AI Studio Setup Guide

## 🎯 Why Google AI Studio?

**Much better than OpenRouter because:**
- ✅ **Completely FREE** - No rate limits on free tier
- ✅ **Direct API** - No middleman, faster responses
- ✅ **More reliable** - Google's infrastructure
- ✅ **Better models** - Latest Gemini 1.5 Flash
- ✅ **No account issues** - Just need a Google account
- ✅ **Generous quota** - 1500 requests per day free!

## 📝 Step-by-Step Setup

### Step 1: Get Your API Key

1. **Go to Google AI Studio:**
   👉 https://aistudio.google.com/app/apikey

2. **Sign in** with your Google account

3. **Click "Create API Key"**
   - Choose "Create API key in new project" (recommended)
   - Or select an existing Google Cloud project

4. **Copy your API key**
   - It looks like: `AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX`
   - ⚠️ **Keep it secret!** Don't share or commit to GitHub

### Step 2: Add API Key to Your App

1. **Open the app**
2. **Go to Settings** (gear icon)
3. **Paste your API key** in the "API Key" field
4. **Tap Save**

### Step 3: Test It!

1. **Create a new analysis**
2. **Enter some news content**
3. **Tap "Analyze"**
4. **You should see results in 2-3 seconds!**

## 🆓 Free Tier Limits

Google AI Studio free tier includes:

| Feature | Free Tier |
|---------|-----------|
| **Requests per day** | 1,500 |
| **Requests per minute** | 15 |
| **Tokens per request** | 32,000 |
| **Cost** | $0.00 |

**For this app:**
- Each analysis = 1 request
- You can analyze **1,500 articles per day** for free!
- That's **~50 articles per hour**

## 🔧 Troubleshooting

### Error: "API key not valid"
**Solution:**
1. Check you copied the full key (starts with `AIzaSy`)
2. Make sure there are no extra spaces
3. Try creating a new API key

### Error: "API Error: 400"
**Solution:**
1. Your API key might be restricted
2. Go to https://console.cloud.google.com/apis/credentials
3. Click on your API key
4. Under "API restrictions", select "Don't restrict key"
5. Save

### Error: "Quota exceeded"
**Solution:**
1. You've hit the daily limit (1,500 requests)
2. Wait until tomorrow (resets at midnight PST)
3. Or upgrade to paid tier for more quota

### Error: "API Error: 403"
**Solution:**
1. Enable the Generative Language API
2. Go to https://console.cloud.google.com/apis/library/generativelanguage.googleapis.com
3. Click "Enable"

## 🔐 Security Best Practices

### ✅ DO:
- Keep your API key private
- Use environment variables in production
- Rotate keys periodically
- Monitor usage in Google Cloud Console

### ❌ DON'T:
- Commit API keys to GitHub
- Share keys publicly
- Use the same key across multiple apps
- Hardcode keys in source code

## 💰 Pricing (If You Need More)

If you exceed free tier limits:

| Tier | Price | Requests/Day |
|------|-------|--------------|
| **Free** | $0 | 1,500 |
| **Pay-as-you-go** | $0.00025/request | Unlimited |

**Example costs:**
- 10,000 requests/day = **$2.50/day** = **$75/month**
- 1,000 requests/day = **$0.25/day** = **$7.50/month**

Still **much cheaper** than OpenRouter or other services!

## 📊 Monitoring Usage

### Check Your Usage:

1. Go to https://console.cloud.google.com/apis/dashboard
2. Select your project
3. Click "Generative Language API"
4. View usage graphs and quotas

### Set Up Alerts:

1. Go to https://console.cloud.google.com/billing/budgets
2. Create a budget alert
3. Get notified when approaching limits

## 🚀 Advanced: API Key Restrictions

For production apps, restrict your API key:

1. **Go to:** https://console.cloud.google.com/apis/credentials
2. **Click your API key**
3. **Set restrictions:**
   - **Application restrictions:** Android apps
   - **Package name:** `com.example.fake_news_detector`
   - **SHA-1 fingerprint:** Your app's signing certificate

This prevents unauthorized use of your key.

## 🔄 Migrating from OpenRouter

### Before (OpenRouter):
```dart
// Used OpenRouter with various models
// Had rate limiting issues
// Required OpenRouter account
```

### After (Google AI Studio):
```dart
// Direct Google Gemini API
// No rate limits on free tier
// Just need Google account
// 1,500 free requests/day
```

**Benefits:**
- ✅ 10x more reliable
- ✅ Faster responses
- ✅ Better accuracy
- ✅ More generous free tier
- ✅ Simpler setup

## 📚 Additional Resources

- **Google AI Studio:** https://aistudio.google.com
- **API Documentation:** https://ai.google.dev/docs
- **Gemini Models:** https://ai.google.dev/models/gemini
- **Pricing:** https://ai.google.dev/pricing
- **Quickstart Guide:** https://ai.google.dev/tutorials/get_started_web

## 💡 Tips for Best Results

1. **Be specific** - More detailed content = better analysis
2. **Include context** - URLs and sources help accuracy
3. **Check confidence** - Low confidence = uncertain result
4. **Use recommendations** - Follow AI's verification suggestions
5. **Cross-reference** - Always verify important claims

## 🎓 Understanding the Model

**Current model:** `gemini-1.5-flash`

**Capabilities:**
- ✅ Fast text analysis (1-2 seconds)
- ✅ Structured JSON responses
- ✅ Fact-checking and reasoning
- ✅ Multi-language support
- ✅ Context understanding

**Limitations:**
- ❌ Can't browse the web (uses training data)
- ❌ Training cutoff (may not know very recent events)
- ❌ Can make mistakes (always verify important claims)

## 🆘 Need Help?

### Common Questions:

**Q: Is it really free?**  
A: Yes! 1,500 requests/day completely free.

**Q: Do I need a credit card?**  
A: No! Free tier doesn't require payment info.

**Q: Will I be charged automatically?**  
A: No! You must manually upgrade to paid tier.

**Q: Can I use this in production?**  
A: Yes! But consider API key restrictions for security.

**Q: What if I hit the limit?**  
A: App falls back to local analysis (still works!).

---

**Last Updated:** January 19, 2026  
**API:** Google AI Studio (Gemini 1.5 Flash)  
**Status:** ✅ Working perfectly!
