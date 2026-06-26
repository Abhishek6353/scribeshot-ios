# ScribeShot Product Roadmap & Feature Suggestions

This document outlines high-value future features and improvements for **ScribeShot** to enhance usability, intelligence, and native iOS integration.

---

## 🎯 Feature Roadmap

### 1. 🔗 Actionable Deep Links (Quick-Launch)
* **Description**: Scan the extracted OCR text for URLs, product codes, or social media handles and offer a direct launch action.
* **Use Case**: Clicking a single button to `"Open in Amazon"` for a product screenshot, or `"View in YouTube"` for a video frame.
* **Technical Details**:
  * Implement regex parsing on `rawOCRText` to match common URL structures and domain patterns.
  * Use SwiftUI's `Link` view or `openURL` environment action to deep-link users directly into target apps or Safari.

### 2. 🤖 Siri Shortcuts & App Intents (`AppIntents`)
* **Description**: Expose core app search and retrieval features directly to Apple's native Siri and Shortcuts ecosystems.
* **Use Case**: A user asking, *"Siri, search ScribeShot for invoice"* or setting up a shortcut to automatically clean up screenshots weekly.
* **Technical Details**:
  * Define custom App Intents conforming to the Swift `AppIntent` protocol.
  * Implement intent handlers that query the SwiftData `ModelContext` and return structured model representations.

### 3. 📂 Smart Dynamic Folders (Auto-Grouping)
* **Description**: Create self-organizing groups that filter screenshots based on pre-defined query rules rather than manual tags.
* **Use Case**: Dynamic folders like **"Receipts"** (scans for currency symbols and words like `"Total"`, `"Tax"`, `"Invoice"`) or **"Social Media"** (scans for `"instagram"`, `"tiktok"`, `"reels"`).
* **Technical Details**:
  * Build dynamic SwiftData query predicates targeting `title`, `tags`, and `rawOCRText`.
  * Offer customizable filtering rules (e.g., "Contains text X", "Has tag Y", "Created in the last 7 days").

### 4. 🗑 Smart Duplicate & Clutter Clean-Up
* **Description**: Identify identical or very similar screenshots (such as accidental button presses or multiple frames of the same scroll) and offer a quick interface to review and purge them.
* **Use Case**: Deleting 5 repetitive screenshots of a single article page to save local storage.
* **Technical Details**:
  * Use string metrics (e.g. Levenshtein distance) on OCR text to detect close textual similarity.
  * Integrate Apple's `PHPhotoLibrary` deletion requests to securely delete the image files from both ScribeShot and the system Camera Roll.

### 5. 📤 Share Extension (Direct Import)
* **Description**: Add a standard iOS Share Extension target so users can import screenshots into ScribeShot instantly from any system share sheet.
* **Use Case**: Sharing a screenshot from the native iOS markup screen directly into ScribeShot without opening the main app.
* **Technical Details**:
  * Create a lightweight Share Extension target sharing the SwiftData container container group.
  * Extract incoming images using `NSItemProvider` and schedule background OCR/LLM processing immediately.
