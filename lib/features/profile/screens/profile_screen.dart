import 'package:college_companion/features/profile/widgets/profile_app_bar.dart';
import 'package:college_companion/features/profile/widgets/profile_header_card.dart';
import 'package:college_companion/features/profile/widgets/profile_menu_list.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: const SafeArea(
        child: Column(
          children: [
            ProfileAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: LayoutTokens.screenPadding,
                  vertical: SpacingTokens.sm, // py-2
                ),
                child: Column(
                  children: [
                    ProfileHeaderCard(
                      name: 'Jayesh Patil',
                      email: 'jayeshpatil@gmail.com',
                      semester: 'SEM 5',
                      course: 'CSE (AI & ML)',
                    ),
                    SizedBox(
                      height: LayoutTokens.sectionGap,
                    ), // space-y-section-gap
                    ProfileMenuList(),
                    SizedBox(height: LayoutTokens.sectionGap),
                    _LogoutButton(),
                    SizedBox(
                      height: SpacingTokens.huge,
                    ), // bottom padding for scroll
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: ColorTokens.surfaceContainer,
      borderRadius: RadiusTokens.borderRadiusXl,
      child: InkWell(
        onTap: () async {
          final confirm = await CCDialogs.showLogoutConfirmation(context);
          if (confirm == true) {
            // TODO: Implement actual logout logic here
          }
        },
        borderRadius: RadiusTokens.borderRadiusXl,
        hoverColor: ColorTokens.surfaceContainerHigh,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: SpacingTokens.base,
          ), // py-4
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorTokens.outlineVariant.withValues(alpha: 0.2),
            ),
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          alignment: Alignment.center,
          child: Text(
            'Logout',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
