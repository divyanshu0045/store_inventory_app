# Inventory Management App

This is a comprehensive, offline-first inventory management application built with Flutter. It is designed to be a robust and scalable solution for managing products, suppliers, and stock levels, with a clean architecture and a modern user interface.

## Key Features Implemented

*   **Offline-First Architecture**: The application is built using a local-first approach with a Drift (SQLite) database, allowing all core functionality to work seamlessly without an internet connection.
*   **Product Management**: Full CRUD (Create, Read, Update, Delete) functionality for products, including detailed views, search, and filtering.
*   **Supplier Management**: Full CRUD functionality for managing suppliers.
*   **Stock Control**: Record stock transactions (In, Out, Adjust) with quantities being updated atomically in the local database.
*   **Barcode Scanning**: Integrated barcode/QR code scanner for quick product lookup and data entry.
*   **Role-Based Access Control (RBAC)**: Implemented a basic RBAC system to restrict sensitive actions (e.g., editing, deleting) to authorized user roles (Admin, Staff).
*   **Reactive UI**: The UI is built with Riverpod and automatically updates in response to changes in the local database.
*   **Modern UI/UX**: The application uses Material 3 design principles and includes features like swipe-to-edit/delete gestures.

## Tech Stack

*   **Framework**: Flutter 3.x
*   **State Management**: Riverpod
*   **Local Database**: Drift (SQLite)
*   **Data Modeling**: Freezed & `json_serializable`
*   **Navigation**: GoRouter
*   **API Client**: Dio
*   **Barcode Scanning**: `mobile_scanner`
*   **Testing**: `flutter_test`, `mocktail`

---

## Getting Started

### Prerequisites

Before you begin, ensure you have the following installed on your system:
*   **Flutter SDK**: Version 3.x or higher. You can follow the official [Flutter installation guide](https://docs.flutter.dev/get-started/install).
*   **A code editor**: Such as VS Code or Android Studio, with the Flutter and Dart plugins installed.

### Development Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/divyanshu0045/store_inventory_app.git
    cd store_inventory_app
    ```

2.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```

### **IMPORTANT**: Code Generation

This project uses code generation for the database (Drift) and data models (Freezed). Before you can build or run the app, you **must** run the `build_runner` to generate the necessary files (`.g.dart`, `.freezed.dart`).

Run the following command in the root of the project:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

You will need to re-run this command whenever you make changes to:
*   Any of the database tables or DAOs in `lib/data/datasources/local/database.dart`.
*   Any of the Freezed models (files ending in `_model.dart` or `_state.dart`).

## Building the Application

To build a release version of the Android application (APK), run the following command:

```bash
flutter build apk --release
```

The generated APK file will be located in the `build/app/outputs/flutter-apk/` directory. You can then install this file on an Android device.