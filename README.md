# Task Manager Tracker – Flutter + Firebase + Provider

Built for Flutter 3.47.4. The app demonstrates:
- Firebase Email/Password authentication
- Persistent authentication protection
- Cloud Firestore real-time CRUD
- User-owned tasks under `users/{uid}/tasks/{taskId}`
- Provider state management
- Dynamic Light/Dark mode
- Modular models/services/providers/screens/theme structure

## Before running
This ZIP intentionally does not contain `firebase_options.dart` because that file is generated for your own Firebase project.

From the project root:

```powershell
flutter pub get
flutterfire configure
flutter run -d chrome
```

Choose your Firebase project and platforms. This creates `lib/firebase_options.dart`.

## Firebase Console setup
1. Open Firebase Console and select the same project used by `flutterfire configure`.
2. Authentication → Sign-in method → enable **Email/Password**.
3. Firestore Database → Create database.
4. Use the following rules (replace with these rules for the assignment):

```text
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/tasks/{taskId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Architecture
- `models/` – Task model
- `services/` – Firebase Auth and Firestore API calls
- `providers/` – Auth, Task, and Theme state
- `theme/` – Light/Dark ThemeData
- `screens/` – Login, Sign Up, Home, Task Form, Settings
- `main.dart` – Firebase initialization, Provider setup, AuthGate

## CRUD mapping
- Create → Add Task
- Read → Firestore `snapshots()` real-time stream
- Update → Edit Task / completion checkbox
- Delete → Delete menu + confirmation dialog

## Important
If you already ran `flutterfire configure` in your existing project, copy your generated `firebase_options.dart` into `lib/` of this project, then run `flutter pub get` and `flutter run`.
