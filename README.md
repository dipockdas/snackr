# Snackr Flutter

A Flutter rewrite of the Snackr RSS ticker, originally developed as an Adobe AIR application.

## About

Snackr is an RSS feed ticker that displays feed items in a scrolling ticker on your desktop. This project is a Flutter-based reimplementation of the original Snackr app, designed to run on macOS using Flutter's desktop support.

## Features

- RSS feed parsing and display
- Scrolling ticker interface for feed items
- Feed item detail view
- Mark items as read/starred
- Customizable ticker position, size and appearance
- InfoQ feed integration

## Architecture

The application is built with a clean architecture approach:

- **Domain Layer**: Contains business entities, repository interfaces, and use cases
- **Data Layer**: Implements repositories, data sources, and models
- **Presentation Layer**: Contains UI components and state management

### State Management

The application uses Riverpod for state management:

- **Providers**: Dependency injection and state management
- **Notifiers**: Business logic and state mutation
- **Repository Pattern**: Data access layer abstraction

### Database

SQLite is used for local storage of:

- Feeds
- Feed items
- App settings
- Categories

## Differences from Original Snackr

- Uses Flutter instead of Adobe AIR
- Modern architecture with clean separation of concerns
- Uses SQLite directly instead of AIR's local storage
- Replaces Google Reader integration (now defunct) with direct RSS parsing
- Native macOS window management

## Development

This project uses Flutter for macOS. To get started:

1. Ensure you have Flutter installed with macOS desktop support enabled
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run -d macos` to launch the application

### Implementation Notes

- The application uses a clean architecture approach with domain-driven design
- Features are implemented incrementally, with an initial focus on core functionality
- The prototype includes:
  - A basic RSS feed parser (simplified for demonstration)
  - SQLite database for feed and item storage
  - Desktop window management with positioning
  - Ticker UI with scrolling items
  - Ability to add feeds

## Recent Improvements

- Slowed down ticker speed with configurable duration (default: 200 seconds)
- Added pause-on-hover functionality to allow interaction with ticker items
- Fixed HTML entity display issues (e.g., &apos; now displays as ' properly)
- Implemented true multi-window system for dialogs and article details
- Windows now have correct dimensions and are not constrained by the ticker window
- Added proper window management (focusing, closing, tracking)
- Improved styling and readability of article detail view

## Future Improvements

- OPML import/export
- Feed categories
- Multiple ticker support
- Additional platform support (Windows, Linux)
- Better RSS parsing with a dedicated RSS/Atom parsing library
- More robust error handling
- Unit and integration tests

## Running

To run the application in debug mode:
```bash
flutter run -d macos
```

To build a release version:
```bash
flutter build macos
```

Alternatively, use the provided startup script:
```bash
./start_snackr.sh
```

## Troubleshooting

If you encounter issues running the application, please see the [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) file for common problems and solutions.

Recent fixes include:
- Fixed network permission issues by adding `com.apple.security.network.client` entitlement
- Added multiple fallback feeds when primary feeds fail to load
- Implemented a manual feed addition dialog with suggested feeds
- Improved database initialization and error handling
- Added comprehensive logging throughout the application
- Resolved window management platform message issues
- Created a simplified window implementation
- Fixed dialog constraint issues by implementing true multi-window support
- Resolved HTML entity encoding problems that affected text display
- Fixed RenderFlex overflow errors by using separate OS-level windows for dialogs

## Speed Adjustment

The ticker speed can be adjusted by modifying the `tickerScrollDurationSeconds` value in the `ticker.dart` file. The default setting is now 200 seconds for a full scroll cycle. Higher values result in slower scrolling.

For quick speed adjustment, you can also use the provided shell script:
```bash
./reset_speed.sh
```

See [SPEED_ADJUSTMENT.md](./SPEED_ADJUSTMENT.md) for more details about customizing the ticker speed.
