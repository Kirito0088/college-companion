import 'package:college_companion/shared/widgets/cc_card.dart';
import 'package:college_companion/theme/color_tokens.dart';
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
          'Help & Support',
          style: theme.textTheme.titleLarge?.copyWith(
            color: ColorTokens.onSurface,
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
            _buildSectionTitle(context, 'Contact Us'),
            _buildContactOptions(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSectionTitle(context, 'Frequently Asked Questions'),
            _buildFaqSection(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSectionTitle(context, 'Community & Feedback'),
            _buildCommunityFeedbackOptions(context),
            const SizedBox(height: SpacingTokens.huge),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search help articles...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(
          color: ColorTokens.onSurfaceVariant,
        ),
        prefixIcon: const Icon(
          Symbols.search,
          color: ColorTokens.onSurfaceVariant,
        ),
        filled: true,
        fillColor: ColorTokens.surfaceContainer,
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: SpacingTokens.sm,
        bottom: SpacingTokens.sm,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: ColorTokens.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildContactOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        children: [
          _ActionRow(
            icon: Symbols.chat,
            label: 'Chat with Support',
            subtitle: 'Usually responds in 5 minutes',
            showBorder: true,
          ),
          _ActionRow(
            icon: Symbols.mail,
            label: 'Email Us',
            subtitle: 'support@collegecompanion.app',
            showBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityFeedbackOptions(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
        border: Border.all(
          color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        children: [
          _ActionRow(
            icon: Symbols.bug_report,
            label: 'Report a Bug',
            showBorder: true,
          ),
          _ActionRow(
            icon: Symbols.feedback,
            label: 'Send Feedback',
            showBorder: true,
          ),
          _ActionRow(
            icon: Symbols.forum,
            label: 'Join Discord Community',
            showBorder: false,
            trailingIcon: Symbols.open_in_new,
          ),
        ],
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

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.showBorder,
    this.trailingIcon = Symbols.chevron_right,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final bool showBorder;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        hoverColor: ColorTokens.surfaceContainerHigh,
        child: Container(
          padding: const EdgeInsets.all(LayoutTokens.cardPadding),
          decoration: BoxDecoration(
            border: showBorder
                ? Border(
                    bottom: BorderSide(
                      color: ColorTokens.outlineVariant.withValues(alpha: 0.3),
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: ColorTokens.onSurfaceVariant),
              const SizedBox(width: SpacingTokens.base),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: ColorTokens.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: ColorTokens.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: SpacingTokens.sm),
              Icon(trailingIcon, color: ColorTokens.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
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
                color: ColorTokens.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            iconColor: ColorTokens.primary,
            collapsedIconColor: ColorTokens.onSurfaceVariant,
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
                  color: ColorTokens.onSurfaceVariant,
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
