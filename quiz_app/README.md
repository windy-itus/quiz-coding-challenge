# Quiz App

A real-time quiz application built with Flutter that allows users to participate in quizzes and view leaderboards.

## Features

- Real-time quiz participation - Not yet
- Real-time Score Updates - Not yet
- Live leaderboard updates - Supported
- Clean and intuitive user interface - Not yet
- State management using BLoC pattern - Not yet
- Organized code structure with constants layer - Not yet

## Project Structure

```
lib/
├── blocs/           # Business Logic Components
│   ├── leaderboard/ # Leaderboard related BLoC
│   └── quiz/        # Quiz related BLoC
├── constants/       # Application constants
│   ├── route_constants.dart    # Route definitions
│   ├── string_constants.dart   # String literals
│   └── style_constants.dart    # UI styles and spacing
├── models/          # Data models
├── repositories/    # Data repositories
├── screens/         # UI screens
│   ├── home_screen.dart
│   ├── leaderboard_screen.dart
│   └── quiz_screen.dart
├── socket/          # WebSocket related code
├── utils/          # Utility functions and services
└── widgets/        # Reusable widgets
```

## Constants Layer

The application uses a dedicated constants layer to maintain consistency and improve maintainability:

- `string_constants.dart`: Contains all string literals used throughout the app
- `style_constants.dart`: Defines common styles, colors, and spacing values
- `route_constants.dart`: Centralizes route definitions for navigation

## Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Dependencies

- `flutter_bloc`: For state management
- `go_router`: For navigation
- `equatable`: For value equality
- `logger`: For logging
- `talker`: For enhanced logging capabilities

## Development

### Code Organization

- Follow the BLoC pattern for state management
- Use the constants layer for all string literals and styles
- Keep widgets small and reusable
- Maintain clean architecture principles

### Best Practices

- Use the constants layer for all string literals and styles
- Follow Flutter's style guide
- Write clean, maintainable code
- Keep the UI responsive and user-friendly

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
