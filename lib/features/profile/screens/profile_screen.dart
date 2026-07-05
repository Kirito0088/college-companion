import 'package:college_companion/features/profile/widgets/profile_app_bar.dart';
import 'package:college_companion/features/profile/widgets/profile_header_card.dart';
import 'package:college_companion/features/profile/widgets/profile_menu_list.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/models/mock_ui_state.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/shared/widgets/errors/cc_errors.dart';
import 'package:college_companion/shared/widgets/loading/cc_skeletons.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  MockUiState _uiState = MockUiState.success;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileAppBar(),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_uiState) {
      case MockUiState.loading:
        return const SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: LayoutTokens.screenPadding,
            vertical: SpacingTokens.sm,
          ),
          child: Column(
            children: [
              SkeletonProfile(),
              SizedBox(height: LayoutTokens.sectionGap),
              SkeletonList(itemCount: 4),
            ],
          ),
        );
      case MockUiState.empty:
      case MockUiState.error:
        return NetworkErrorWidget(
          onRetry: () {
            setState(() {
              _uiState = MockUiState.loading;
              Future.delayed(
                const Duration(seconds: 1),
                () => setState(() => _uiState = MockUiState.success),
              );
            });
          },
        );
      case MockUiState.success:
        return const SingleChildScrollView(
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
              SizedBox(height: LayoutTokens.sectionGap), // space-y-section-gap
              ProfileMenuList(),
              SizedBox(height: LayoutTokens.sectionGap),
              _PreviewOnboardingButton(),
              SizedBox(height: SpacingTokens.md),
              _LogoutButton(),
              SizedBox(height: SpacingTokens.huge), // bottom padding for scroll
            ],
          ),
        );
    }
  }
}

class _PreviewOnboardingButton extends StatelessWidget {
  const _PreviewOnboardingButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: ColorTokens.surfaceContainerHigh,
      borderRadius: RadiusTokens.borderRadiusXl,
      child: InkWell(
        onTap: () {
          context.push(RoutePaths.onboarding);
        },
        borderRadius: RadiusTokens.borderRadiusXl,
        hoverColor: ColorTokens.surfaceContainerHighest,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.base),
          decoration: BoxDecoration(
            border: Border.all(
              color: ColorTokens.primary.withValues(alpha: 0.3),
            ),
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          alignment: Alignment.center,
          child: Text(
            'Preview Onboarding',
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
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
