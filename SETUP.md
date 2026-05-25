# Caribbean Golf Hub — Firebase Setup Guide

Follow these steps in order. Each section takes about 5 minutes.

---

## STEP 1 — Install Flutter (if not already installed)

**macOS:**
```bash
brew install --cask flutter
flutter doctor   # fix anything flagged in red
```

**Windows:** Download from https://flutter.dev/docs/get-started/install/windows

Verify:
```bash
flutter --version   # should show 3.x.x
```

---

## STEP 2 — Create your Firebase project

1. Go to https://console.firebase.google.com
2. Click **"Add project"**
3. Name it: `caribbean-golf-hub`
4. Disable Google Analytics (not needed for MVP) → **Create project**

Inside your new project, enable these services:

### Firestore
- Left sidebar → **Firestore Database** → **Create database**
- Choose **"Start in test mode"** (we'll apply security rules after)
- Select a region close to the Caribbean (e.g. `us-east1`)

### Authentication
- Left sidebar → **Authentication** → **Get started**
- **Sign-in method** tab → Enable **Email/Password**

### Cloud Messaging (FCM)
- Already enabled by default — nothing to do here

---

## STEP 3 — Connect Flutter to Firebase

```bash
# Install the FlutterFire CLI (one time)
dart pub global activate flutterfire_cli

# Make sure firebase CLI is installed
npm install -g firebase-tools
firebase login       # opens browser, sign in with your Google account

# Inside the project folder
cd caribbean_golf_hub

# Run this — it asks which project and which platforms (select Android + iOS + Web)
flutterfire configure
```

This automatically:
- Creates the Android `google-services.json` → placed at `android/app/google-services.json`
- Creates the iOS `GoogleService-Info.plist` → placed at `ios/Runner/GoogleService-Info.plist`
- **Replaces** `lib/firebase_options.dart` with your real project credentials

---

## STEP 4 — Install dependencies

```bash
# Still inside caribbean_golf_hub/
flutter pub get
```

---

## STEP 5 — Deploy Firestore rules and indexes

```bash
# From the repo root (where firebase.json would live)
firebase init firestore   # select your caribbean-golf-hub project

# Copy our rules files
cp firebase/firestore.rules firestore.rules
cp firebase/firestore.indexes.json firestore.indexes.json

firebase deploy --only firestore
```

---

## STEP 6 — Seed initial data

```bash
cd firebase

# Install the admin SDK
npm install firebase-admin

# Download your service account key:
# Firebase Console → Project Settings → Service accounts → Generate new private key
# Save as firebase/serviceAccountKey.json  (never commit this file)

node seed_data.js
```

This loads the 4 T&T golf courses, rules of golf content, and 2 sample specials.

---

## STEP 7 — Run the app

```bash
cd caribbean_golf_hub

# Option A — Run in Chrome (fastest, no emulator needed)
flutter run -d chrome

# Option B — Android emulator (open Android Studio → AVD Manager first)
flutter run -d emulator-5554

# Option C — iOS simulator (macOS only)
open -a Simulator
flutter run -d iPhone

# Option D — See all available devices
flutter devices
flutter run   # picks the first available device
```

---

## STEP 8 — Set up the Admin Dashboard

```bash
# Edit admin/app.js and replace the firebaseConfig block at the top:
# Firebase Console → Project Settings → Your apps → Add web app
# Copy the firebaseConfig object shown and paste it into admin/app.js

# Then open the dashboard locally:
open admin/index.html    # macOS
# or just drag admin/index.html into Chrome
```

To create your first admin user:
1. Firebase Console → Authentication → Users → **Add user**
2. Enter email + password for the pro shop login
3. Firebase Console → Firestore → Add document to `admin_users` collection:
   ```
   Document ID: <the UID shown next to the user in Authentication>
   Fields:
     email:    "proshop@yourclub.com"
     name:     "Moka Pro Shop"
     role:     "club_admin"        (or "super_admin" for yourself)
     courseId: "moka"              (matches the course document ID)
   ```

---

## STEP 9 — Deploy Cloud Functions (optional, for push notifications)

```bash
cd firebase/functions
npm install

firebase deploy --only functions
```

Push notifications fire automatically when a new special is published via the admin dashboard.

---

## STEP 10 — Deploy Admin Dashboard to the web

```bash
firebase init hosting   # select caribbean-golf-hub project, public dir = admin
firebase deploy --only hosting
```

Your admin dashboard will be live at `https://caribbean-golf-hub.web.app`

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `google-services.json not found` | Run `flutterfire configure` again |
| `Firebase not initialized` | Check `firebase_options.dart` has real values |
| `Permission denied` on Firestore | Deploy `firestore.rules` first |
| Android build fails | Run `flutter clean && flutter pub get` |
| iOS pod install fails | `cd ios && pod install --repo-update` |
| `flutter doctor` shows Xcode issues | Install Xcode from App Store + `sudo xcode-select --switch /Applications/Xcode.app` |

---

## Quick Reference — Useful Commands

```bash
flutter run -d chrome          # Run as web app
flutter run --release          # Test release build performance
flutter build apk              # Build Android APK
flutter build ios              # Build iOS (requires macOS + Xcode)
firebase deploy --only firestore   # Push rules + indexes only
firebase emulators:start       # Run Firebase locally (offline dev)
```
