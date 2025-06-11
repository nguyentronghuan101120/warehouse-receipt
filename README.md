# Warehouse Receipt Management System

A Flutter application for managing warehouse receipts and inventory tracking.

## Features

- Create and manage warehouse receipts
- View receipt details and history
- Real-time data synchronization with Firebase
- Material Design 3 UI with modern aesthetics
- Responsive layout for various screen sizes

## Prerequisites

- Flutter SDK (version 3.6.0 or higher)
- Dart SDK (version 3.6.0 or higher)
- Firebase account and project setup
- Android Studio / VS Code with Flutter extensions

## Getting Started

1. Clone the repository:

```bash
git clone https://github.com/yourusername/warehouse_receipt.git
```

2. Navigate to the project directory:

```bash
cd warehouse_receipt
```

3. Install dependencies:

```bash
flutter pub get
```

4. Configure Firebase:

   - Create a new Firebase project
   - Add your Android/iOS app to the Firebase project
   - Download and add the configuration files:
     - `google-services.json` for Android
     - `GoogleService-Info.plist` for iOS
   - Enable Firestore in your Firebase console

5. Run the app:

```bash
flutter run
```

## Project Structure

```
lib/
├── constants/     # App-wide constants and configurations
├── data/         # Data layer (repositories, data sources)
├── providers/    # State management using Provider
├── screens/      # UI screens
└── utils/        # Utility functions and helpers
```

## Dependencies

- `firebase_core`: ^2.24.2 - Firebase core functionality
- `cloud_firestore`: ^4.14.0 - Cloud Firestore database
- `provider`: ^6.1.5 - State management
- `intl`: ^0.20.2 - Internationalization and formatting
- `uuid`: ^4.5.1 - Unique ID generation

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please open an issue in the GitHub repository or contact the development team.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors who have helped shape this project
