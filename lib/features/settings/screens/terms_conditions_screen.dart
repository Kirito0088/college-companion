import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: ColorTokens.onSurface,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Terms of Service',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Last updated: October 2026',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: ColorTokens.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            _buildSection(
              context,
              '1. Acceptable Use',
              'College Companion is designed to assist engineering students with managing their academic responsibilities. You agree to use the application strictly for its intended personal and academic productivity purposes. You must not attempt to compromise the app\'s security, reverse-engineer its synchronization logic, or use it for any illegal activities.',
            ),
            _buildSection(
              context,
              '2. Academic Data Accuracy',
              'The application provides tools to track attendance, assignments, and grades. However, you are solely responsible for verifying the accuracy of the academic data you enter. College Companion is an organizational tool, not an official university record. We are not liable for academic consequences resulting from missed assignments, incorrect attendance calculations, or misconfigured alerts.',
            ),
            _buildSection(
              context,
              '3. Offline Functionality & Synchronization',
              'College Companion operates primarily offline. While we strive to ensure seamless synchronization via Supabase when connectivity is available, we do not guarantee immediate or continuous sync availability. You are responsible for ensuring your data is synchronized regularly before switching devices or clearing local storage.',
            ),
            _buildSection(
              context,
              '4. User Responsibilities',
              'You are responsible for maintaining the confidentiality of your Google Authentication credentials. Any activity occurring under your account is your responsibility. Ensure that you do not input sensitive institutional data that violates your university\'s code of conduct.',
            ),
            _buildSection(
              context,
              '5. Intellectual Property & Open Source',
              'The College Companion software, including its design language, architecture, and original code, is protected by intellectual property laws. The application incorporates various open-source software libraries; these are provided under their respective licenses, accessible via the Open Source Licenses section in the app settings.',
            ),
            _buildSection(
              context,
              '6. Service Availability & Updates',
              'We reserve the right to modify, suspend, or discontinue any feature of the application at any time. We also periodically release updates to improve functionality, security, and the Material 3 design system. It is your responsibility to keep the application updated to the latest version.',
            ),
            _buildSection(
              context,
              '7. Limitation of Liability',
              'To the maximum extent permitted by law, College Companion and its developers shall not be liable for any direct, indirect, incidental, or consequential damages arising from the use or inability to use the application, including but not limited to lost academic data, hardware malfunction, or academic performance issues.',
            ),
            const SizedBox(height: SpacingTokens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurface,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
