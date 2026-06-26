# **Product Requirement Document (PRD)**

## **Project: AI Screenshot Organizer (iOS Native)**

## **1\. Executive Summary & Problem Statement**

### **1.1 Problem Statement**

Users frequently take screenshots while reading articles, watching videos, or browsing social media reels to save information for future use. However, these images are saved sequentially into the native iOS gallery app without context. Over time, this transforms the camera roll into a unsearchable "digital graveyard" where the original meaning, source, and intent of the screenshot are lost.

### **1.2 Objective**

To build a privacy-first, native iOS application that automatically imports, analyzes, and contextualizes user screenshots. By extracting text and processing visual data on-device, the app transforms unorganized images into a highly searchable, auto-categorized digital notebook featuring structured titles, tags, and context summaries.

## **2\. Product Architecture & Tech Stack**

The app is engineered to maximize efficiency and privacy by leveraging native Apple frameworks to perform resource-heavy operations locally on the Apple Neural Engine.

* **OS Target:** iOS 17.0+ (to ensure full compatibility with SwiftData)  
* **UI Framework:** SwiftUI  
* **Design Pattern:** MVVM (Model-View-ViewModel)  
* **Database Layer:** SwiftData (Local, type-safe persistence)  
* **Media Fetching:** PhotoKit (Photos framework)  
* **AI Engine (OCR):** Vision Framework (On-device text extraction)

## **3\. Core Feature Requirements**

### **3.1 Background Sync & Automated Import**

* **Requirement:** The app must automatically identify and import new screenshots without forcing the user to upload them manually.  
* **Technical Implementation:** \* Request permission using NSPhotoLibraryUsageDescription.  
  * Implement a PHPhotoLibraryChangeObserver to track camera roll modifications.  
  * Query the photo library specifically filtering for the .photoScreenshot media subtype to isolate screenshots from standard photos.

### **3.2 On-Device AI Text Extraction (OCR)**

* **Requirement:** The app must extract raw text strings out of every imported screenshot.  
* **Technical Implementation:** Use VNRecognizeTextRequest set to .accurate level execution. This must function entirely offline to respect user privacy constraints.

### **3.3 Smart Contextualization & Categorization**

* **Requirement:** The app must translate raw OCR text into user-readable metadata (Titles, Tags, and Summaries).  
* **Execution Routes:**  
  * *On-Device Route:* Utilize Apple's native NaturalLanguage framework or a lightweight localized CoreML model to parse nouns/entities.  
  * *Hybrid Route:* Send only the extracted text string (never the actual image file) to a secure LLM API endpoint to retrieve a standardized JSON block containing structured tags, titles, and shortened summaries.

### **3.4 Deep Text & Metadata Search**

* **Requirement:** Users must be able to search through their screenshot collection instantly.  
* **Functionality:** The search function must query across all parameters simultaneously: Title, Context Summary, Tags, and hidden raw extracted OCR text.

## **4\. User Interface (UI) Requirements**

The app design should favor high scannability, mimicking structured grid notebooks like Pinterest or Notion.

| View Component | Description | Requirements |
| :---- | :---- | :---- |
| **Dashboard / Home** | Main workspace displaying all captured items. | Uses a LazyVGrid to show dual-column thumbnail card layouts. Integrates the SwiftData @Query macro for immediate list rendering. |
| **Screenshot Card** | Individual visual representation of an entry. | Shows an image preview thumbnail, an AI-generated title, and a short 2-line context preview snippet. |
| **Detail View** | Full page preview of a selected entry. | Displays the full-resolution screenshot image, editable fields for the Title/Notes, tappable tag chips, and a copyable block of the raw extracted text. |

## **5\. Non-Functional Requirements & Constraints**

### **5.1 Privacy & Security**

* **Constraint:** Screenshots frequently capture private information like sensitive messages or financial details.  
* **Mitigation:** Storage must reside strictly inside the application's local sandbox environment container managed by SwiftData. Image tracking must utilize local asset IDs (localIdentifier) rather than duplicating bulky assets into insecure databases.

### **5.2 OS Sandboxing & App Tracking Limitations**

* **Constraint:** Unlike Android, iOS sandboxing blocks apps from detecting what background application was open when the system-level screenshot buttons were pressed.  
* **Workaround:** Implement string-matching heuristic parsers on the extracted OCR text. For example, if the text block detects occurrences of "instagram.com/reels", "tiktok.com", or "amazon.com", the application will deduce the source platform and auto-generate appropriate origin tags.

### **5.3 Background Thread Management**

* **Constraint:** Foreground UI performance must never lag due to text recognition tasks.  
* **Mitigation:** Image rendering handles light asynchronous preview requests via PHImageManager. Heavy computational processing pipelines must run strictly on a background queue (DispatchQueue.global(qos: .userInitiated)).

