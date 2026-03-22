# AI Models & Rate Limit Solutions

## 🚨 Common Issues

### Error 1: Rate Limiting
```
google/gemini-2.0-flash-exp:free is temporarily rate-limited upstream
```
**Solution:** Switch to a different model (see below)

### Error 2: Model Not Found
```
No endpoints found for meta-llama/llama-3.1-8b-instruct:free
```
**Solution:** Model doesn't exist on OpenRouter free tier - use verified models below

## ✅ VERIFIED Working Free Models

These models are **confirmed working** on OpenRouter's free tier:

### Option 1: Mistral 7B Instruct ⭐ (Current)
```dart
static const String _model = 'mistralai/mistral-7b-instruct:free';
```
- ✅ **Status:** Working
- ✅ **Best for:** Structured JSON responses, fact-checking
- ✅ **Speed:** Fast
- ✅ **Rate limits:** Low
- ✅ **Accuracy:** Very good

### Option 2: Google Gemini Flash 1.5
```dart
static const String _model = 'google/gemini-flash-1.5:free';
```
- ✅ **Status:** Working (less rate-limited than 2.0)
- ✅ **Best for:** Detailed analysis
- ✅ **Speed:** Very fast
- ⚠️ **Rate limits:** Medium
- ✅ **Accuracy:** Excellent

### Option 3: Qwen 2.5 7B
```dart
static const String _model = 'qwen/qwen-2.5-7b-instruct:free';
```
- ✅ **Status:** Working
- ✅ **Best for:** Multilingual content
- ✅ **Speed:** Fast
- ✅ **Rate limits:** Low
- ✅ **Accuracy:** Good

### Option 4: Phi-3 Medium
```dart
static const String _model = 'microsoft/phi-3-medium-128k-instruct:free';
```
- ✅ **Status:** Working
- ✅ **Best for:** Long content analysis
- ✅ **Speed:** Medium
- ✅ **Rate limits:** Very low
- ✅ **Accuracy:** Good

## ❌ Models That DON'T Work (Free Tier)

These models are **NOT available** on OpenRouter's free tier:

- ❌ `meta-llama/llama-3.1-8b-instruct:free` - Endpoint doesn't exist
- ❌ `meta-llama/llama-3.2-3b-instruct:free` - Endpoint doesn't exist
- ⚠️ `google/gemini-2.0-flash-exp:free` - Exists but heavily rate-limited

## 🔧 How to Change Models

1. Open `lib/services/fake_news_detector_service.dart`
2. Find line 7:
   ```dart
   static const String _model = 'mistralai/mistral-7b-instruct:free';
   ```
3. Replace with one of the verified models above
4. Save and restart the app

## 📊 Model Comparison (Verified Only)

| Model | Speed | Accuracy | Rate Limits | Status |
|-------|-------|----------|-------------|--------|
| **Mistral 7B** ⭐ | ⚡⚡⚡ | ⭐⭐⭐⭐ | ✅ Low | Working |
| Gemini Flash 1.5 | ⚡⚡⚡⚡ | ⭐⭐⭐⭐⭐ | ⚠️ Medium | Working |
| Qwen 2.5 7B | ⚡⚡⚡ | ⭐⭐⭐⭐ | ✅ Low | Working |
| Phi-3 Medium | ⚡⚡ | ⭐⭐⭐ | ✅ Very Low | Working |

⭐ = Current recommendation

## 💰 Paid Models (Guaranteed Uptime)

If you need better reliability and accuracy:

### GPT-4 Turbo
```dart
static const String _model = 'openai/gpt-4-turbo';
```
- **Cost:** ~$0.01 per analysis
- **Accuracy:** Excellent
- **No rate limits**

### Claude 3.5 Sonnet
```dart
static const String _model = 'anthropic/claude-3.5-sonnet';
```
- **Cost:** ~$0.003 per analysis
- **Accuracy:** Excellent
- **No rate limits**

### Gemini Pro 1.5
```dart
static const String _model = 'google/gemini-pro-1.5';
```
- **Cost:** ~$0.001 per analysis
- **Accuracy:** Very good
- **No rate limits**

## 🛠️ Troubleshooting

### "No endpoints found" Error
**Cause:** Model doesn't exist on OpenRouter  
**Solution:** Use one of the verified models above

### "Rate limited" Error
**Cause:** Too many requests to popular model  
**Solution:** 
1. Wait 1-2 minutes
2. Switch to Mistral 7B or Phi-3 Medium
3. Consider paid model

### "API Error: 404"
**Cause:** Model name typo or model removed  
**Solution:** Double-check model name matches exactly

### Analysis Shows "Uncertain" for Everything
**Cause:** Model not following JSON format  
**Solution:** 
1. Try Mistral 7B (best at structured responses)
2. Check if API key is valid
3. App will use fallback analysis if AI fails

## 🔍 How to Check Model Availability

Visit OpenRouter's model list:
https://openrouter.ai/models

Look for:
- 🟢 **Free** badge - Model has free tier
- 💰 **Price** - If $0.00, it's free
- ⚡ **Status** - Green = available

## 💡 Best Practices

1. **Start with Mistral 7B** - Most reliable free option
2. **Have API key ready** - Better rate limits
3. **Monitor usage** - Check OpenRouter dashboard
4. **Fallback works** - App has local analysis if AI fails
5. **Test before deploying** - Try different models with your content

## 🆘 Still Having Issues?

### Quick Fixes:
1. ✅ Verify API key is correct
2. ✅ Check internet connection
3. ✅ Try Mistral 7B model
4. ✅ Wait 1-2 minutes if rate-limited
5. ✅ Restart the app

### Resources:
- OpenRouter Docs: https://openrouter.ai/docs
- Model List: https://openrouter.ai/models
- Status Page: https://status.openrouter.ai
- Get API Key: https://openrouter.ai/keys

## 📈 Performance Tips

1. **Cache results** - Don't re-analyze same content
2. **Batch requests** - Space out analyses
3. **Use Mistral for production** - Most stable free model
4. **Monitor costs** - Set billing alerts if using paid models

---

**Last Updated:** January 19, 2026  
**Current Model:** `mistralai/mistral-7b-instruct:free` ✅  
**Status:** Working and stable
