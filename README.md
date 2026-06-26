# AI Screenshot Organizer

A privacy-first, native iOS application that automatically imports, analyzes, and organizes your screenshots. By extracting text on-device and generating structured metadata, it transforms your camera roll from a "digital graveyard" into a searchable, categorized personal knowledge base.

---

## 📱 Features

- **Automated Import & Background Sync**: Scans the iOS Photo Library in the background (using `PhotoKit` and `PHPhotoLibraryChangeObserver`) specifically filtering for the `.photoScreenshot` media subtype to isolate screenshots.
- **On-Device OCR**: Extracts text from screenshots using Apple's native `Vision` framework. Processing runs locally on the **Apple Neural Engine (ANE)**, ensuring complete user privacy and offline capabilities.
- **Secure Keychain Storage**: Protects sensitive API keys by storing them in the device's hardware-secured **Keychain** (via the `Security` framework), with safe auto-migration from `UserDefaults` on launch.
- **Interactive API Verification**: Test OpenAI credentials in real-time in Settings with detailed diagnostic feedback and Apple-style visual checkmarks or alerts.
- **Empty-Text Intelligent Fallback**: Detects screenshots without text (e.g., photos, drawings, UI mocks) and immediately completes processing with local fallbacks, saving API token costs.
- **Unified Deep Search**: Instantly query your collection across titles, context summaries, tags, and raw on-device extracted text.
- **Native Apple Design Aesthetics**: Clean, standard `.insetGrouped` form design, centered screenshot previews with native shadows, and modern grayscale capsule tag chips with trailing deletion targets.

---

## 🛠 Tech Stack

- **OS Target**: iOS 17.0+
- **UI Framework**: SwiftUI
- **Database Layer**: SwiftData (local, type-safe persistence)
- **OCR Engine**: Vision Framework (`VNRecognizeTextRequest`)
- **Credential Security**: Keychain Services (`Security`)
- **Remote Integration**: OpenAI API (standardized JSON block mapping for titles, tags, and summaries)

---

## 📂 Project Architecture

The project follows a clean MVVM (Model-View-ViewModel) architectural pattern:

```
AnalyzeScreenshot/
├── App/                     # Core application entry
├── Models/                  # SwiftData entities (e.g., ScreenshotItem)
├── Views/                   # SwiftUI components grouped by feature
│   ├── Home/                # Dashboard and screenshot grid list
│   ├── Detail/              # Inset-grouped screenshot details & tag editor
│   ├── Settings/            # Secure API configuration & key validation
│   ├── Search/              # Real-time multi-parameter search bar
│   └── Onboarding/          # User welcome and initial permission setup
├── ViewModels/              # Observable ViewModels driving UI logic
├── Services/                # Keychain helper, background processing queue, OpenAI service
└── Resources/               # Universal AppIcon asset catalogs and local assets
```

---

## 🚀 Setup & Installation

### Prerequisites
- macOS Sonoma 14.0+
- Xcode 15.0+
- A valid OpenAI API Key (get one from the [OpenAI Platform](https://platform.openai.com/api-keys))

### Installation Steps
1. Clone this repository locally.
2. Open `AnalyzeScreenshot.xcodeproj` in Xcode.
3. Select an iOS 17.0+ Simulator or a physical iOS device.
4. Press `Cmd + R` to build and run the application.

### Configuration
1. Navigate to the **Settings** tab in the application.
2. Click **Get API Key** to open the OpenAI developer portal if you do not have one.
3. Paste your API key in the text field and click **Verify API Key** to validate your setup.

---

## 🔒 Privacy & Sandboxing

- **Local Storage**: All screenshot items, tags, and raw text reside strictly in the app's local sandbox container managed by SwiftData.
- **Zero Image Upload**: The application **never** uploads your screenshot images to any server. Only the raw text extracted locally is sent to the OpenAI API for text summarization and categorization.
- **Metadata Protection**: Source app heuristics are computed locally on extracted text rather than accessing device logs, maintaining complete compliance with iOS sandboxing limits.
