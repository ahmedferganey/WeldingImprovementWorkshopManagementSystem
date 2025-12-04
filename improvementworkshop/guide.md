### Flutter Dashboard: Build, Run, and Deploy Guide

#### 1️⃣ Run Locally on Emulator (Debug Mode)

1. Start your Android emulator or connect a physical device.
2. In the project root:

```bash
flutter pub get       # Install dependencies
flutter run           # Run app in debug mode on emulator
```

3. Hot reload/hot restart commands during run:

* `r` → Hot reload
* `R` → Hot restart
* `q` → Quit

✅ App runs locally and can be tested interactively.

---

#### 2️⃣ Build for Deployment (Release Mode)

##### A. Android APK

```bash
flutter build apk --release
```

* Output: `build/app/outputs/flutter-apk/app-release.apk`
* Installable on Android devices or Play Store.

##### B. Android App Bundle (AAB) for Play Store

```bash
flutter build appbundle --release
```

* Output: `build/app/outputs/bundle/release/app-release.aab`
* Recommended for Play Store distribution.

##### C. Web Deployment

```bash
flutter build web --release
```

* Output: `build/web/` folder
* Deploy to Firebase Hosting, Netlify, or any web server.
* Test locally:

```bash
flutter run -d chrome

```

* Open `http://localhost:5000` in browser.

---

#### 3️⃣ Test Release Build on Emulator

```bash
flutter install         # Installs the latest build to device/emulator
flutter run --release   # Run release version on emulator
```

---

#### 4️⃣ Optional: Clean + Build Script (All-in-One)

```bash
flutter clean
flutter pub get
flutter build apk --release
flutter run
```

* Ensures a fresh build and runs on emulator.

---

#### 5️⃣ Notes

* `_StatCard` uses `Expanded` for responsive icon + text.
* `Wrap` is used for stat cards to adapt to mobile/web.
* Charts layout changes depending on screen width via `LayoutBuilder`.
* Low Stock Table uses horizontal scrolling on small screens.
* Emulator testing allows seeing responsive behavior in real-time.
* Web build allows hosting your Flutter frontend anywhere.

✅ This setup ensures the **Flutter dashboard is fully responsive and ready for deployment** on Android and Web, while still being testable locally on an emulator.
