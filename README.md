# Flutter Translation Management Assignment

This repository contains a boilerplate for a Flutter-based translation management system.
It includes:
- A Flutter Web application (`admin_web_app`) for managing translation strings.
- A Flutter Mobile application (`mobile_app`) that dynamically loads and displays these translations.
- A shared Flutter package (`packages/translation_domain`) for common data models.

## Prerequisites

- Flutter SDK (version 3.x.x or later recommended). Verify with `flutter --version`.
- An editor like VS Code or Android Studio with Flutter plugins.
- A web browser (like Chrome) for running the Flutter Web app.
- An emulator/simulator or a physical device for running the Flutter Mobile app.

## Setup Instructions

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd flutter_translation_assignment
    ```

2.  **Get dependencies for all projects:**
    You need to run `flutter pub get` in each of the Flutter projects/packages:

    ```bash
    # For the shared domain package
    cd packages/translation_domain
    flutter pub get
    cd ../..

    # For the admin web app
    cd admin_web_app
    flutter pub get
    cd ..

    # For the mobile app
    cd mobile_app
    flutter pub get
    cd ..
    ```
    *Tip: If you have `melos` installed, you could configure it to bootstrap all packages at once.*

3.  **Initial translation files for Mobile App:**
    The mobile app uses local JSON files as a fallback or for initial load. Ensure these exist:
    - `mobile_app/assets/translations/en.json`
    - `mobile_app/assets/translations/es.json`
    - `mobile_app/assets/translations/fr.json`

    Example `en.json`:
    ```json
    {
        "greeting": "Hello from Asset",
        "farewell": "Goodbye from Asset",
        "appTitle": "My App",
        "refresh_translations_button": "Refresh Translations"
    }
    ```
    Make sure you add `assets/translations/` to `mobile_app/pubspec.yaml` under `flutter.assets`.

## Running the Applications

### 1. Admin Web App

Navigate to the `admin_web_app` directory and run:

```bash
cd admin_web_app
flutter run -d chrome
```
This will compile and launch the web application in your Chrome browser. You should see an interface to add, edit, and delete translation strings. Initially, these are stored in-memory in the MockAdminTranslationService.


### 2. Mobile App 
Navigate to the mobile_app directory. Ensure an emulator is running or a device is connected. Then run:

```bash
cd mobile_app
flutter run
```

This will build and install the app on your selected device/emulator. The app will display some text. It includes a language switcher and a "Refresh Translations" button. Initially, it fetches translations from MockMobileTranslationService or loads from local assets.
