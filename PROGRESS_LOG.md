# 📝 Barangay Portal Development Log

This file tracks all features, fixes, and architectural changes to keep the AI and developers synced on the project state.

---

## 🗓️ 2026-05-16: Phase 3 - Notifications & UI Polish

### 🚀 Features Added
*   **Firebase Integration:** Full setup for Push Notifications on both Backend (Node.js) and Mobile (Flutter).
*   **Premium Splash Screen:** Added a high-end, animated-feel splash screen with government branding.
*   **Shimmer Loading:** Replaced all basic spinners with professional "shimmer" cards in Complaint and Appointment lists.
*   **Empty State Widgets:** Added modern, illustrated empty states for screens with no data (Announcements, Complaints, etc.).
*   **Notification Service:** Implemented a robust service to handle foreground/background messages and FCM token registration.

### 🔧 Critical Fixes
*   **Session Persistence:** Fixed a bug where the app wouldn't save the JWT token after login, causing immediate session loss.
*   **Auth Race Condition:** Added defensive guards in `AuthProvider` to prevent slow initialization from overwriting a successful login state.
*   **Network Connectivity:** Updated `api_constants.dart` to use `192.168.100.3` to allow physical devices to talk to the local backend.
*   **Compilation:** Resolved multiple Dart errors related to theme references and parameter passing in history screens.
*   **Android Build:** Enabled Core Library Desugaring in `build.gradle.kts` to support modern Java features required by plugins.
*   **Routing Fix:** Resolved "Route Not Found" (404) errors in Complaint and Appointment submissions by correcting the API endpoint mappings in the Flutter services.
*   **Notification Center Backend:** Added a dedicated API endpoint to fetch notification history for residents.
*   **Email System:** Verified and documented the Email/OTP service for registration and status updates.
*   **Timeline UI:** Implemented a premium status history timeline in Complaint and Appointment detail screens to track administrative actions.
*   **Type Safety:** Hardened `AppointmentProvider` and `ComplaintProvider` to resolve casting errors during data refresh.
*   **Data Integrity:** Corrected API response parsing in `ComplaintService` to ensure submitted records appear in history immediately.

---

## 🎯 Next Steps (Remaining Tasks)
1.  **Notification Center:** Build a UI screen to view the history of received push notifications.
2.  **Dashboard Badges:** Add a "red dot" notification badge to the bell icon on the home screen.
3.  **Physical Device QA:** Final end-to-end test of the registration -> approval -> notification flow.

---
*Last Updated: 2026-05-16 02:27 AM*
