import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Privacy Policy',
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
              'Purpose of the App',
              'College Companion is built specifically for engineering students to manage their academic life. We believe in providing an offline-first, private, and secure environment to track attendance, assignments, schedules, and academic progress without compromising personal data.',
            ),
            _buildSection(
              context,
              'Offline-First Architecture & Storage',
              'To ensure maximum reliability during classes and in low-connectivity areas, College Companion uses an offline-first architecture. All your academic data—including attendance records, timetables, and assignments—is stored locally on your device using an encrypted SQLite database. This means your data remains accessible to you at all times.',
            ),
            _buildSection(
              context,
              'Supabase Cloud Synchronization',
              'To provide a seamless experience across multiple devices and prevent data loss, College Companion optionally synchronizes your local data with our secure cloud infrastructure powered by Supabase. Synchronization only occurs when you are authenticated and connected to the internet.',
            ),
            _buildSection(
              context,
              'Google Authentication',
              'We use Google Authentication to verify your identity. We only request the minimum information necessary, such as your email address and basic profile details, to create and secure your College Companion account. We do not have access to your Google password or other Google services.',
            ),
            _buildSection(
              context,
              'Information Collected',
              '• Academic Information: Timetables, attendance records, assignment details, internal marks, and study resources you explicitly input.\n• User Profile Information: Name, semester, branch/course, and email address.\n• Usage Analytics: Anonymous interactions to help us improve the app\'s UX.\n• Crash Reporting: Automated, anonymized crash logs to help identify and fix software bugs.',
            ),
            _buildSection(
              context,
              'User Privacy & Data Ownership',
              'You own your academic data. We do not sell your personal or academic information to third parties, advertisers, or educational institutions. The data you enter is used exclusively to provide you with the College Companion experience.',
            ),
            _buildSection(
              context,
              'Data Deletion & Security',
              'You have the right to request the deletion of your account and all associated data at any time from the app settings. All data transfers between your device and Supabase are encrypted in transit using industry-standard protocols (HTTPS).',
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions or concerns about this Privacy Policy or how your data is handled, please reach out to us at privacy@collegecompanion.app.',
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
