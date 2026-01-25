# OrientAI Project Status Report
**Date:** January 25, 2026
**Status:** Pre-Release (Phase 1.5 - Release Engineering)
**Version:** 1.0.0+1 (Target)

## 1. Executive Summary
OrientAI is an "Active Assistant" designed to guide Italian students through university orientation. Unlike passive chatbots, it aims to provide proactive guidance, psychological profiling, and concrete advice ("Smart Retention"). The project is currently in the **Release Engineering** phase, preparing for a V1.0 launch on the Google Play Store.

## 2. Technical Architecture
The application is built on a robust Flutter + Firebase stack, leveraging Google's Gemini 2.5 models for intelligence.

*   **Frontend:** Flutter (Dart 3.2+)
*   **Backend:** Firebase (Authentication, Firestore, Storage)
*   **AI Engine:**
    *   **Free Users:** Gemini 2.5 Flash Lite (Cost-optimized, $0.10/1M input).
    *   **Premium Users:** Gemini 2.5 Pro (High reasoning).
    *   **Implementation:** `lib/services/ai_service.dart` uses `GenerativeModelWrapper` for testability.
*   **Monetization:** Google Mobile Ads (Banner) + Optional Donations (Ko-fi).

### Key Components Verified
| Component | Status | File Location | Notes |
| :--- | :--- | :--- | :--- |
| **AI Service** | ✅ Operational | `lib/services/ai_service.dart` | Implements `summarizeChat` & tiered models. |
| **Database** | ✅ Operational | `lib/services/database_service.dart` | Handles batch deletions & user profiles. |
| **Sustainability** | ✅ Implemented | `lib/screens/profile_screen.dart` | "Offrici un caffè" & Privacy links present. |
| **AdMob** | ⚠️ Configuration | `AndroidManifest.xml` | Using **Test App ID** (`ca-app-pub-3940...`). |
| **Build Config** | ⚠️ Configuration | `android/app/build.gradle.kts` | Release build currently uses `debug` signing config. |

## 3. Roadmap Progress
Based on `docs/ROADMAP_TECNICA.md`:

*   **Phase 1: Stability (Completed)**
    *   Core chat functionality is stable.
    *   Error handling is robust (no raw stack traces to UI/DB).
    *   Input validation is centralized.
*   **Phase 1.5: Release Engineering (In Progress)**
    *   **Current Focus:** The app works, but is not "store-ready".
    *   **Missing:** Signed Release APK/AAB, Real AdMob IDs, Hosted Privacy Policy, Store Assets.
*   **Phase 2: Active Assistant (Pending)**
    *   Multimodality (Images/PDFs) and Proactive Notifications are deferred until after V1.0 launch.

## 4. Operational & Financial Strategy
*   **Legal:** Project operates under "Prestazione Occasionale" (Individual) for the short term.
*   **Fees:** Enrollment in Google Play 15% service fee tier is a mandatory pre-launch step.
*   **Security:** Strict sanitization of logs (API Keys) and error messages (to prevent persistent XSS in chat history).

## 5. Immediate Action Items (Pre-Launch)
1.  **Keystore:** Generate production `.jks` file (do not commit to git).
2.  **Signing:** Update `key.properties` and `build.gradle.kts` to use the release key.
3.  **AdMob:** Register real Ad Units in AdMob Console and update `AndroidManifest.xml` / `main.dart`.
4.  **Privacy:** Host the Privacy Policy text online and verify the link in `ProfileScreen`.
5.  **Assets:** Create icon (512px), feature graphic, and screenshots for Play Store.
