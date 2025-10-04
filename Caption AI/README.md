# Caption Clash 🏆

**A playful, privacy-first iOS app where you clash captions with on-device AI**

Caption Clash is a modern iOS 19+ app that challenges you to create the best 3-5 word captions for your photos and compete against Apple's on-device AI. Built with SwiftUI, Apple Foundation Models, and a privacy-first architecture.

---

## ✨ Features

### Core Gameplay
- **📸 Image Selection**: Pick any photo from your library
- **✍️ Caption Creation**: Write creative 3-5 word captions
- **🤖 AI Competition**: On-device AI generates its own caption
- **⚖️ Fair Judging**: AI judges both captions on relevance, creativity, and specificity
- **🎯 Scoring**: Get scored 0-10 with actionable tips for improvement

### Gamification
- **🏅 10 Unlockable Badges**: From "First Light" to "Perfectionist"
- **🔥 Daily Streaks**: Maintain momentum with daily challenges
- **📊 Statistics Tracking**: Monitor your progress and win rate
- **🎊 Confetti Celebrations**: Visual rewards for high scores (9-10)
- **📈 Leaderboard**: Track your best performances

### Privacy & Design
- **🔒 100% On-Device**: All AI processing happens locally—no cloud, no tracking
- **🎨 Beautiful UI**: Modern, playful design following Apple HIG 2025
- **♿️ Full Accessibility**: VoiceOver, Dynamic Type, high contrast support
- **📱 Native Experience**: SwiftUI, haptics, SF Symbols, smooth animations

---

## 🏗️ Architecture

### Technology Stack
- **Platform**: iOS 19+ (Apple Intelligence compatible devices)
- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **AI**: Apple Foundation Models (on-device LLM)
- **Persistence**: SwiftData (local-only)
- **Photos**: PhotosUI framework

### Key Components

#### App Structure
- `CaptionClashApp.swift` - Main app entry with @main, ScenePhase lifecycle
- `RootView.swift` - TabView navigation (Play, History, Badges, Settings)

#### Gameplay Views
- `PlayView.swift` - Multi-stage gameplay flow
- `ScoreView.swift` - Results display with tips and sharing
- `HistoryView.swift` - Past rounds with statistics
- `BadgesView.swift` - Achievement tracking and display
- `SettingsView.swift` - Privacy info, data management, AI status

#### AI/Foundation Models Layer
- `AFMService.swift` - Foundation Models integration with availability checks
- `AFMModels.swift` - @Generable structs for guided generation
- `AFMJudge.swift` - Markdown-formatted prompts and rubrics
- `AFMTokenBudget.swift` - Context window management (~4k tokens)

#### Game Logic
- `GameEngine.swift` - Streaks, scoring, badge unlock logic
- `BadgeCatalog.swift` - Complete badge definitions with criteria
- `Models.swift` - SwiftData models (RoundRecord, BadgeState)

#### Utilities
- `DesignSystem.swift` - Colors, typography, reusable components
- `PhotoPickerService.swift` - Image selection with authorization
- `ImageUtils.swift` - Downscaling, orientation fix, compression
- `Haptics.swift` - Tactile feedback wrapper
- `ConfettiView.swift` - Particle-based celebration animation

---

## 🎮 How to Play

1. **Select a Photo** 📸
   - Tap "Select Photo" and choose from your library
   - Any image works, but clear subjects work best

2. **Write Your Caption** ✍️
   - Enter 3-5 words that capture the essence
   - Be creative, specific, and evocative

3. **AI Processing** 🤖
   - **Stage A**: AI interprets the image (objects, scene, vibes)
   - **Stage B**: AI generates its own 3-5 word caption
   - **Judge**: AI compares both captions and scores yours

4. **View Results** 🎯
   - See your score (0-10) and comparison
   - Get actionable tips for improvement
   - Share your best captions
   - Unlock badges for achievements

---

## 🏅 Badges & Achievements

| Badge | Icon | Criteria |
|-------|------|----------|
| **First Light** | 🌅 | Score 8+ on your first caption |
| **Wordsmith** | ✍️ | Score 9+ three times in a row |
| **Lens Master** | 📷 | Complete 20 rounds |
| **Minimalist** | ➖ | Win with exactly 3 words |
| **Perfectionist** | ⭐ | Score a perfect 10 |
| **Streaker** | 🔥 | Maintain a 7-day streak |
| **Explorer** | 🗺️ | Play with 50 different images |
| **Critic** | 👓 | Score 5 or lower 3 times |
| **Creative** | 🎨 | 5+ points in Originality category |
| **Speedster** | ⚡ | Complete a round in under 30s |

---

## 🔒 Privacy & Security

Caption Clash is built with **privacy as the foundation**:

### What We DO
- ✅ Process everything on your device
- ✅ Use Apple Foundation Models (on-device LLM)
- ✅ Store only low-res thumbnails locally
- ✅ Respect photo library permissions
- ✅ Support full data erasure

### What We DON'T Do
- ❌ No cloud services or external APIs
- ❌ No data collection or analytics
- ❌ No tracking or telemetry
- ❌ No user profiling
- ❌ No ads or third-party SDKs

### Declarations
- `NSPhotoLibraryUsageDescription`: Explained clearly
- `PrivacyInfo.xcprivacy`: Zero tracking, zero data collection
- SwiftData: Local-only, no iCloud sync by default

---

## 🚀 Getting Started

### Requirements
- **Xcode 16.0+** (for iOS 19 SDK)
- **iOS 19.0+** deployment target
- **Apple Intelligence compatible device**:
  - iPhone 15 Pro or later
  - iPad with M1 chip or later
- **No external dependencies** (Swift Package Manager only, no packages needed)

### Build & Run
1. Open `Caption AI.xcodeproj` in Xcode
2. Select an iOS 19+ simulator or physical device
3. Build and run (⌘R)
4. Grant photo library access when prompted

### Testing
- **Unit Tests**: `Caption AITests/` - Core logic, scoring, token estimation
- **UI Tests**: `Caption AIUITests/` - End-to-end flows with accessibility
- **Manual Testing**: Offline mode, dark/light themes, VoiceOver

---

## 🎨 Design Philosophy

### Apple Human Interface Guidelines 2025
- **Playful & Imaginative**: Confetti, animations, haptics
- **Modern & Sleek**: Gradients, frosted glass, SF Symbols 7+
- **Accessible**: Full VoiceOver, Dynamic Type, reduced motion
- **Transparent**: Clear AI status, privacy indicators

### Design System
- **Colors**: System colors with accent gradients (blue → mint)
- **Typography**: San Francisco with semantic sizes
- **Spacing**: Consistent 4/8/16/24/32px scale
- **Components**: Reusable cards, buttons, modifiers

---

## 🧪 Apple Foundation Models Integration

### Three-Stage Pipeline

#### Stage A: Image Interpretation
```swift
// Input: UIImage + markdown prompt
// Output: ImageInterpretation (objects, scene, actions, vibes, altText, safetyFlag)
// Budget: ~800 tokens response, temperature 0.5 (factual)
```

#### Stage B: AI Caption Generation
```swift
// Input: ImageInterpretation summary + constraints
// Output: AICaption (3-5 words, Title Case)
// Budget: ~50 tokens response, temperature 0.7 (creative)
```

#### Judge: Scoring & Tips
```swift
// Input: User caption + AI caption + interpretation + rubric
// Output: CaptionJudgment (score 0-10, tips, categories)
// Budget: ~200 tokens response, temperature 0.6 (balanced)
```

### Guided Generation
Uses `@Generable` Swift structs for type-safe, structured outputs:
- No JSON parsing
- Direct Swift object returns
- Validation enforced by schema

### Fallback Modes
- AFM unavailable → Manual scoring (heuristic-based)
- Model not downloaded → Graceful UI with instructions
- Context exhausted → Retry with simplified schema

---

## 📦 File Structure

```
Caption AI/
├── CaptionClashApp.swift       # App entry point
├── RootView.swift              # Tab navigation
├── Info.plist                  # App configuration
├── PrivacyInfo.xcprivacy       # Privacy manifest
│
├── Views/
│   ├── PlayView.swift          # Main gameplay
│   ├── ScoreView.swift         # Results display
│   ├── HistoryView.swift       # Past rounds
│   ├── BadgesView.swift        # Achievements
│   └── SettingsView.swift      # Settings & privacy
│
├── AI/
│   ├── AFMService.swift        # Foundation Models service
│   ├── AFMModels.swift         # Guided generation structs
│   ├── AFMJudge.swift          # Prompts & rubrics
│   └── AFMTokenBudget.swift    # Context management
│
├── Game/
│   ├── GameEngine.swift        # Core game logic
│   ├── BadgeCatalog.swift      # Badge definitions
│   └── Models.swift            # SwiftData models
│
├── Utilities/
│   ├── PhotoPickerService.swift
│   ├── ImageUtils.swift
│   ├── Haptics.swift
│   └── ConfettiView.swift
│
├── Design/
│   └── DesignSystem.swift      # UI components
│
└── Assets.xcassets/
    └── AppIcon.appiconset/     # App icons (generated)
```

---

## 🔧 Configuration

### Bundle Identifier
Update in Xcode project settings:
```
com.yourorg.captionclash
```

### Deployment Target
- Minimum: iOS 19.0
- Supports: iPhone, iPad

### Capabilities
- Photo Library (read)
- SwiftData (local storage)

---

## 🐛 Known Limitations

### iOS 19 Beta
- Foundation Models API may be incomplete in early betas
- Fallback modes implemented for unavailable features

### Device Compatibility
- Requires Apple Intelligence compatible devices
- A17+ or M1+ chip required for on-device AI
- Older devices get manual mode with heuristic scoring

### Performance
- Large images (>2048px) downscaled for memory efficiency
- AI processing typically <3s on A17+ chips
- First launch may require model download (~500MB)

---

## 📈 Future Enhancements (Post-MVP)

- [ ] Local notifications for daily challenges
- [ ] Custom themes and color schemes
- [ ] SharePlay for multiplayer caption battles
- [ ] Vision framework tool calling for advanced analysis
- [ ] iCloud sync for cross-device progress
- [ ] Widgets for quick stats
- [ ] Apple Watch companion app

---

## 📄 License

Copyright © 2025. All rights reserved.

This project is built as a demonstration of iOS 19+ capabilities with Apple Foundation Models and follows Apple's design and privacy guidelines.

---

## 🙏 Acknowledgments

- **Apple Foundation Models** - On-device LLM powering AI features
- **SF Symbols 7+** - Comprehensive iconography
- **Apple HIG 2025** - Design guidance for Generative AI experiences
- **SwiftUI & SwiftData** - Modern declarative frameworks

---

## 📞 Support

For issues or questions:
1. Check Settings > AI Status for model availability
2. Ensure iOS 19+ on compatible device
3. Try "Erase All Data" in Settings to reset
4. Review privacy permissions in Settings app

---

**Built with ❤️ for iOS 19 and Apple Intelligence**

