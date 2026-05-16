# NamNam

Restaurant and Food Review Application
4ITH | Bunyi, Taloyo, Viaña

## Introduction and Background

Food is personal. And yet, finding a great place to eat in Metro Manila often feels like a hit or miss. You either rely on a friend's recommendation or scroll endlessly through outdated listings hoping something looks good. NamNam was built to change that. 

The name comes from the Filipino word for delicious and that is exactly what this app is about. NamNam is a community-driven restaurant discovery and review platform designed for Metro Manila diners who want honest recommendations before they decide where to eat. Inspired by platforms like Yelp, Zomato, and Google Maps, NamNam was developed as an academic project that tackles a very real, everyday problem: where should I eat today? Built using Flutter and Firebase, the app brings together restaurant browsing, community reviews, and a bookmarking system in one clean and simple experience.

## About the Application

NamNam is a mobile application that lets users discover local restaurants, read and write reviews, save their favorite spots, and manage a personal profile, all in one place. Every restaurant page shows its location, average rating, and community reviews at a glance, giving users everything they need to decide where to eat before they even step out the door. 

The app is built around six core features:

- **Restaurant Discovery**: Browse a live feed of restaurants filterable by category. NamNam greets you by name and surfaces places near you the moment you open the app.
- **Smart Search**: Find exactly what you are craving using three filter modes: search by restaurant name, filter by food category, or set a minimum star rating. Use all three at once for a more specific search.
- **Community Reviews**: Read and write reviews with a star rating, a text description, and an optional photo. Every new review automatically updates the restaurant's average rating in real time.
- **Bookmarks**: Save any restaurant with a single tap. Saved places are always one screen away whenever you need them.
- **Personal Profile**: Track your dining history, see your total reviews, average rating, and saved places all in one dashboard. You can update your name and upload a profile photo.
- **Real Time Data**: Powered by Firebase, all restaurant data, reviews, and user profiles update live without requiring app refreshes.

## Tech Stack

- **Frontend**: Flutter
- **Backend Services**: Firebase
  - Firebase Authentication (Google & Email/Password Sign-In)
  - Cloud Firestore (Real-time NoSQL Database for Restaurants, Reviews, Users, and Saved items)
  - Firebase Storage (Hosting for Profile Pictures and Food Images)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- A connected device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ItsyBinsy/namnam.git
   cd namnam
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a Firebase project at Firebase Console.
   - Add your Android/iOS apps within the Firebase project.
   - Download the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them in the corresponding directories.
   - Run `flutterfire configure` to generate the `firebase_options.dart` file.

4. **Run the App**
   ```bash
   flutter run
   ```
