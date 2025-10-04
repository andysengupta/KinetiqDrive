# Caption Clash - Quick Start Guide

## ⚡ Get Running in 3 Minutes

### Prerequisites
- macOS 14+ with Xcode 16+
- iOS 19+ SDK installed
- Simulator or physical device with iOS 19+

### Step 1: Open Project
```bash
cd "/Users/anand/Documents/GitHub/KinetiqDrive/Caption AI"
open "Caption AI.xcodeproj"
```

### Step 2: Configure (Optional)
In Xcode, update if needed:
- **Bundle Identifier**: `com.yourorg.captionclash` (or keep default)
- **Team**: Select your development team
- **Device**: Choose iPhone 15 Pro simulator or physical device

### Step 3: Build & Run
Press **⌘R** or click the Play button

That's it! 🎉

---

## 🎮 First Use

1. Grant **Photo Library** access when prompted
2. Tap **"Select Photo"** on Play tab
3. Choose any image from your library
4. Write a **3-5 word caption** (e.g., "Cozy Morning Coffee Vibes")
5. Tap **"Clash! ⚔️"** to compete with AI
6. View your **score and tips**

---

## 🧪 Running Tests

### Unit Tests
```bash
⌘U or Product → Test
```
Runs 30+ test cases for game logic, token estimation, badges, etc.

### UI Tests
```bash
Select "Caption AIUITests" scheme → ⌘U
```
Tests navigation, accessibility, and end-to-end flows.

---

## 🐛 Troubleshooting

### "AI Unavailable" Message
**Cause**: Foundation Models requires iOS 19+ with Apple Intelligence  
**Fix**: 
- Ensure iOS 19+ on device/simulator
- Check device compatibility (iPhone 15 Pro+ or iPad M1+)
- App works in manual mode as fallback

### Photo Picker Not Showing
**Cause**: Permissions not granted  
**Fix**: Settings → Privacy → Photos → Caption Clash → Enable

### Build Errors
**Cause**: Missing SDK or deployment target mismatch  
**Fix**: 
- Xcode → Preferences → Components → Download iOS 19 SDK
- Project Settings → Deployment Target → iOS 19.0

### App Crashes on Launch
**Cause**: SwiftData migration issue  
**Fix**: Delete app and reinstall for clean state

---

## 📂 Project Structure Quick Reference

```
Caption AI/
├── CaptionClashApp.swift       ← Start here (app entry)
├── RootView.swift              ← Tab navigation
├── PlayView.swift              ← Main gameplay
├── AFMService.swift            ← AI integration
├── DesignSystem.swift          ← UI components
└── README.md                   ← Full documentation
```

---

## 🔑 Key Features to Demo

1. **Privacy**: Settings → AI Status → "All processing on-device"
2. **Gamification**: Badges tab → 10 unlockable achievements
3. **History**: Complete a round → History tab → See saved rounds
4. **Sharing**: After scoring → Share Result button
5. **Accessibility**: Enable VoiceOver → Navigate entire app

---

## 🚀 Next Steps

- [ ] Read [README.md](README.md) for full documentation
- [ ] Review [IMPLEMENTATION_NOTES.md](IMPLEMENTATION_NOTES.md) for architecture details
- [ ] Customize bundle ID and app icons
- [ ] Test on physical device with Apple Intelligence
- [ ] Submit to TestFlight for beta testing

---

## 💡 Pro Tips

1. **Use iPhone 15 Pro+ simulator** for best experience
2. **Enable Slow Animations** (⌘T) to see confetti
3. **Test VoiceOver** (Accessibility Inspector in Xcode)
4. **Profile with Instruments** (⌘I) for performance
5. **Try offline mode** (Airplane Mode) to test fallbacks

---

## 📞 Common Questions

**Q: Why is AI unavailable?**  
A: Foundation Models requires iOS 19+ on Apple Intelligence devices. Fallback mode works on all devices.

**Q: Where is data stored?**  
A: SwiftData stores everything locally. No cloud sync by default.

**Q: How do I reset progress?**  
A: Settings → Data → Erase All Data

**Q: Can I change the scoring rubric?**  
A: Yes! Edit `AFMJudge.swift` → `buildJudgmentPrompt()`

**Q: How do I add more badges?**  
A: Add cases to `BadgeCatalog.swift` → `Badge` enum

---

**You're ready to clash! 🏆**

