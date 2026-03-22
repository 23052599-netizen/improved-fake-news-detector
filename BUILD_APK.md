# Building APK for Fake News Detector

## Quick Build (Debug APK)

For testing on your device:

```bash
flutter build apk --debug
```

The APK will be at: `build/app/outputs/flutter-apk/app-debug.apk`

---

## Production Build (Release APK)

### Option 1: Single APK (Universal)

Build one APK that works on all Android devices:

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Option 2: Split APKs (Smaller Size)

Build separate APKs for different CPU architectures (recommended for Play Store):

```bash
flutter build apk --split-per-abi --release
```

This creates 3 APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM - older devices)
- `app-arm64-v8a-release.apk` (64-bit ARM - most modern devices)
- `app-x86_64-release.apk` (64-bit Intel - emulators/tablets)

Output location: `build/app/outputs/flutter-apk/`

---

## App Bundle (For Google Play Store)

If you're publishing to Play Store, use App Bundle instead:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

---

## Before Building Release APK

### 1. Create a Keystore (First Time Only)

```bash
keytool -genkey -v -keystore ~/fake-news-detector-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fake-news-detector
```

**Save the password and alias!** You'll need them.

### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=fake-news-detector
storeFile=C:/Users/susmi/fake-news-detector-key.jks
```

**Note:** Use absolute path for `storeFile`

### 3. Update `android/app/build.gradle`

Add before `android {` block:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Inside `android {` block, add:

```gradle
signingConfigs {
    release {
        keyAlias keystoreProperties['keyAlias']
        keyPassword keystoreProperties['keyPassword']
        storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        // ... existing release config
    }
}
```

---

## Quick Commands Summary

| Purpose | Command | Output |
|---------|---------|--------|
| **Testing** | `flutter build apk --debug` | `app-debug.apk` |
| **Release (Universal)** | `flutter build apk --release` | `app-release.apk` |
| **Release (Optimized)** | `flutter build apk --split-per-abi --release` | 3 APKs |
| **Play Store** | `flutter build appbundle --release` | `app-release.aab` |

---

## Install APK on Device

### Via USB:

```bash
flutter install
```

Or manually:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

### Via File Transfer:

1. Copy APK to your phone
2. Open the APK file
3. Allow "Install from Unknown Sources" if prompted
4. Install

---

## Troubleshooting

### "Signing key not configured"

You need to set up signing (see "Before Building Release APK" above)

### "Build failed"

Try cleaning first:

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### APK too large

Use split APKs:

```bash
flutter build apk --split-per-abi --release
```

### Can't install APK

- Enable "Install from Unknown Sources" in Android settings
- Make sure you uninstalled any previous debug version
- Check if you have enough storage space

---

## File Sizes (Approximate)

- **Debug APK**: ~50-60 MB
- **Release APK (Universal)**: ~20-25 MB
- **Release APK (Split)**: ~15-18 MB each
- **App Bundle**: ~18-22 MB

---

## Next Steps After Building

1. **Test the APK** on multiple devices
2. **Check app permissions** in Android settings
3. **Test offline functionality**
4. **Verify API key is working**
5. **Test all features** (Text, URL, Image analysis)

---

## For Distribution

### Google Play Store:
- Use App Bundle: `flutter build appbundle --release`
- Upload to Play Console
- Fill in store listing details

### Direct Distribution:
- Use Universal APK: `flutter build apk --release`
- Share the APK file
- Users need to enable "Unknown Sources"

---

## Important Notes

⚠️ **Never commit `key.properties` or `.jks` files to Git!**

Add to `.gitignore`:
```
android/key.properties
*.jks
*.keystore
```

✅ **Keep your keystore file safe!** If you lose it, you can't update your app on Play Store.

✅ **Test release builds** before distributing - they behave differently than debug builds.
