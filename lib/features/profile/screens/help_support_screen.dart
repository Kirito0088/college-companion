import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/shared/widgets/cc_list_row.dart';
import 'package:college_companion/shared/widgets/cc_section.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Scaffold(
      backgroundColor: cc.bg,
      appBar: AppBar(
        backgroundColor: cc.bg,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back),
          color: cc.fg,
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help & Support',
          style: theme.textTheme.titleLarge?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LayoutTokens.screenPadding,
          vertical: SpacingTokens.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBox(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            CCSection(
              title: 'Contact Us',
              children: [
                CCListRow(
                  icon: Symbols.chat,
                  label: 'Chat with Support',
                  subtitle: 'Usually responds in 5 minutes',
                  showBorder: true,
                  onTap: () {},
                ),
                CCListRow(
                  icon: Symbols.mail,
                  label: 'Email Us',
                  subtitle: 'support@collegecompanion.app',
                  showBorder: false,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: LayoutTokens.sectionGap),
            Padding(
              padding: const EdgeInsets.only(
                left: SpacingTokens.sm,
                bottom: SpacingTokens.sm,
              ),
              child: Text(
                'Frequently Asked Questions',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: cc.mut,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.1,
                ),
              ),
            ),
            _buildFaqSection(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            CCSection(
              title: 'Community & Feedback',
              children: [
                CCListRow(
                  icon: Symbols.bug_report,
                  label: 'Report a Bug',
                  showBorder: true,
                  onTap: () {},
                ),
                CCListRow(
                  icon: Symbols.feedback,
                  label: 'Send Feedback',
                  showBorder: true,
                  onTap: () {},
                ),
                CCListRow(
                  icon: Symbols.forum,
                  label: 'Join Discord Community',
                  showBorder: false,
                  trailing: Icon(Symbols.open_in_new, color: cc.mut, size: 20),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: SpacingTokens.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search help articles...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: cc.mut),
        prefixIcon: Icon(Symbols.search, color: cc.mut),
        filled: true,
        fillColor: cc.raise,
        border: const OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusLg,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: SpacingTokens.md,
          horizontal: SpacingTokens.md,
        ),
      ),
    );
  }

  Widget _buildFaqSection(BuildContext context) {
    final faqs = [
      {
        'q': 'How is my attendance calculated?',
        'a':
            'Attendance is calculated based on the total number of lectures attended out of the total lectures held for a specific module.',
      },
      {
        'q': 'Can I edit a past attendance entry?',
        'a':
            'Yes, you can navigate to the Calendar screen, select the date, and edit your attendance history for any past lecture.',
      },
      {
        'q': 'How does the Safe Bunk feature work?',
        'a':
            'The Safe Bunk calculator uses your current attendance percentage to determine exactly how many upcoming classes you can miss while keeping your percentage above the required threshold (usually 75%).',
      },
    ];

    return Column(
      children: faqs.map((faq) {
        return Padding(
          padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
          child: _FaqCard(question: faq['q']!, answer: faq['a']!),
        );
      }).toList(),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return CCCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              question,
              style: theme.textTheme.titleSmall?.copyWith(
                color: cc.fg,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconColor: cc.pri,
            collapsedIconColor: cc.mut,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: LayoutTokens.cardPadding,
              vertical: SpacingTokens.xs,
            ),
            childrenPadding: const EdgeInsets.only(
              left: LayoutTokens.cardPadding,
              right: LayoutTokens.cardPadding,
              bottom: LayoutTokens.cardPadding,
            ),
            children: [
              Text(
                answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cc.mut,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
