import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/string_constants.dart';

class BackToHomeButton extends StatelessWidget {
  const BackToHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => context.go('/'),
      child: const Text(StringConstants.backToHome),
    );
  }
}
