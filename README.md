# Mathe mit Katzen — adaptive learning for Android and iOS

I have further developed the learning app from my [Matura project](https://github.com/markosaraf/mathe_lern_app), adding adaptive learning, learner profiles, statistics and cat rewards. This version is designed for Android and iPhone/iPad. My original Matura version remains unchanged.

## Implemented features

- **Local profiles and persistent progress:** Names, answers, mistakes, response times, points and cats are saved across app restarts. Profiles can be created, switched, renamed and deleted.
- **Adaptive exercises:** Questions answered incorrectly or slowly are repeated more often. When a learner struggles, practice temporarily uses a smaller number range. Challenge timing adapts to previous response times.
- **Progress and statistics:** Accuracy, response times, progress in each arithmetic group, activity over the past seven days and practice history.
- **Points and cat food:** Correct answers earn points, which can be spent on food for unlocked cats.
- **All nine original groups:** Addition, subtraction and multiplication with numbers up to 10, 20 and 100. Ten consecutive correct answers within the challenge time unlock the corresponding cat. There is no limit on attempts.
- **Additional learning support:** Untimed practice, a nine-question initial assessment, a recommended learning path, short explanations and feedback. Every group remains freely selectable.
- **German and English**, an on-screen number pad, pause controls and automatic pausing when leaving the app.

The relationship to my original project documents and the adaptation rules are documented in [docs/IMPLEMENTIERUNG.md](docs/IMPLEMENTIERUNG.md).

## Run locally

Tested with Flutter **3.50.0 stable** and Dart **3.14.0**. This Flutter version uses the `material_ui` package for Material components. `pubspec.lock` is committed.

```sh
flutter pub get
flutter run
```

Android requires the Android SDK and a compatible Java installation. iOS requires macOS and Xcode. Minimum platform versions are defined in the Android configuration and set to iOS 15.0 for Apple devices.

```sh
flutter analyze
flutter test
flutter build apk --release
flutter build ios --simulator --debug
flutter build ios --release --no-codesign
```

The Android APK is generated at `build/app/outputs/flutter-apk/app-release.apk`. It is currently **signed with a debug key for local testing**, not for store distribution. Configure a dedicated upload key before publishing. An iOS device build must be signed with the appropriate Apple team and provisioning before installation. The simulator build runs only in the simulator.

On my development Mac, Flutter is installed separately at `~/development/matura-modern/flutter`. If iCloud adds Finder metadata to frameworks in the Documents folder and Xcode consequently refuses to sign them, copy the project outside iCloud before building, for example to `~/development/matura-adaptiv-build`.

## Data and privacy

The app works offline, without an online account, server or tracking. Learner profiles are local and are not password-protected. Anyone with access to the same app installation can switch profiles. A nickname is sufficient.

Data is stored in `learning-v1.json` in the private application data directory. Writes are serialized and files are replaced atomically. A local backup allows recovery from a corrupted file. Storage errors are displayed in the app. Uninstalling the app may remove local data. There is no synchronization between devices.

## Project structure

- `lib/domain/learning.dart`: Exercises, learning statistics, adaptation rules and practice sessions
- `lib/data/store.dart`: Profiles and local storage
- `lib/ui/app.dart`: Learning overview, cats, progress and practice screens
- `test/`: Behaviour, storage and interaction tests at phone and tablet sizes
- `android/`, `ios/`: Native app projects
- `lib/images/`: The original nine cat images

The adaptation rules use transparent heuristics. The short initial assessment provides guidance and is not a standardized achievement test.
