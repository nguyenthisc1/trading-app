# Trading

A TradingView-inspired Flutter trading app with realtime charts, watchlist, and technical indicators.

## Features

- 📈 Real-time candlestick charts using [candlesticks](https://pub.dev/packages/candlesticks) and [fl_chart](https://pub.dev/packages/fl_chart)
- 📜 Watchlist for favorite assets
- 🛠 Technical indicators support
- 🔒 Authentication with Firebase (Email, Google)
- ☁️ Cloud Firestore for user data and watchlist
- 🚀 Fast networking with `dio` and `retrofit`
- 💾 Local storage for preferences

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart 3.11+)
- [Firebase CLI](https://firebase.google.com/docs/cli) if you plan to use Firebase features

### Clone the project

```bash
git clone https://github.com/your-username/trading.git
cd trading
```

### Install dependencies

```bash
flutter pub get
```

### Run the app

```bash
flutter run
```

## Project Structure

- `lib/` - Main app codebase
- `lib/charts/` - Charts and indicator widgets
- `lib/services/` - Networking, Firebase, storage APIs
- `lib/models/` - Data models (using Freezed + JsonSerializable)
- `lib/features/` - UI features, screens, and state management

## Configuration

- To enable Firebase, set up your own Firebase project and add the appropriate config files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS).
- Update `pubspec.yaml` for additional dependencies as needed.

## Contributing

Pull requests are welcome! For significant changes, please open an issue first to discuss what you would like to change or add.

## License

[MIT](LICENSE)
