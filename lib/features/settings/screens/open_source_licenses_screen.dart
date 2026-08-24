import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class OpenSourceLicensesScreen extends StatelessWidget {
  const OpenSourceLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cc = context.cc;
    return LicensePage(
      applicationName: 'College Companion',
      applicationVersion: '1.0.0',
      applicationIcon: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: cc.priSoft,
            borderRadius: RadiusTokens.borderRadiusXxl,
          ),
          child: Center(child: Icon(Symbols.school, size: 40, color: cc.pri)),
        ),
      ),
      applicationLegalese: '© 2026 College Companion',
    );
  }
}
