import 'package:college_companion/theme/color_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class OpenSourceLicensesScreen extends StatelessWidget {
  const OpenSourceLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LicensePage(
      applicationName: 'College Companion',
      applicationVersion: '1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: ColorTokens.primaryContainer,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: const Center(
            child: Icon(Symbols.school, size: 40, color: ColorTokens.primary),
          ),
        ),
      ),
      applicationLegalese: '© 2026 College Companion',
    );
  }
}
