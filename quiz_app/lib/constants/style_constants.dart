import 'package:flutter/material.dart';

class StyleConstants {
  // Text Styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 20,
  );

  static const TextStyle questionNumberStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle errorStyle = TextStyle(
    color: Colors.red,
    fontSize: 16,
  );

  static const TextStyle pointsStyle = TextStyle(
    fontWeight: FontWeight.bold,
  );

  // Spacing
  static const double defaultPadding = 16.0;
  static const double largeSpacing = 32.0;
  static const double mediumSpacing = 24.0;
  static const double smallSpacing = 16.0;
}
