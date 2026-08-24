import 'package:college_companion/features/authentication/models/auth_state.dart';
import 'package:college_companion/features/authentication/providers/auth_provider.dart';
import 'package:college_companion/features/profile/providers/profile_provider.dart';
import 'package:college_companion/features/profile/widgets/profile_app_bar.dart';
import 'package:college_companion/features/profile/widgets/profile_header_card.dart';
import 'package:college_companion/features/profile/widgets/profile_menu_list.dart';
import 'package:college_companion/routing/app_router.dart';
import 'package:college_companion/shared/widgets/dialogs/cc_dialogs.dart';
import 'package:college_companion/theme/cc_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cc = context.cc;
    final authState = ref.watch(authStateProvider);
    final profile = ref.watch(userProfileProvider);

    String name = profile.displayName;
    String email = profile.email;
    if (authState is AuthAuthenticated) {
      name = authState.user.displayName.isNotEmpty
          ? authState.user.displayName
          : name;
      email = authState.user.email.isNotEmpty ? authState.user.email : email;
    }

    return Scaffold(
      backgroundColor: cc.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ProfileAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: LayoutTokens.screenPadding,
                  vertical: SpacingTokens.sm,
                ),
                child: Column(
                  children: [
                    ProfileHeaderCard(
                      name: name,
                      email: email,
                      semester: 'SEM ${profile.semester}',
                      course: profile.branch,
                    ),
                    const SizedBox(height: LayoutTokens.sectionGap),
                    const ProfileMenuList(),
                    const SizedBox(height: LayoutTokens.sectionGap),
                    const _PreviewOnboardingButton(),
                    const SizedBox(height: SpacingTokens.md),
                    const _LogoutButton(),
                    const SizedBox(height: SpacingTokens.huge),
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

class _PreviewOnboardingButton extends StatelessWidget {
  const _PreviewOnboardingButton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Material(
      color: cc.raise2,
      borderRadius: RadiusTokens.borderRadiusXxl,
      child: InkWell(
        onTap: () {
          context.push(RoutePaths.onboarding);
        },
        borderRadius: RadiusTokens.borderRadiusXxl,
        hoverColor: cc.raise,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.base),
          decoration: BoxDecoration(
            border: Border.all(color: cc.pri.withValues(alpha: 0.3)),
            borderRadius: RadiusTokens.borderRadiusXxl,
          ),
          alignment: Alignment.center,
          child: Text(
            'Preview Onboarding',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.pri,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cc = context.cc;

    return Material(
      color: cc.raise,
      borderRadius: RadiusTokens.borderRadiusXxl,
      child: InkWell(
        onTap: () async {
          final confirm = await CCDialogs.showLogoutConfirmation(context);
          if (confirm == true) {
            final authService = ref.read(authServiceProvider);
            await authService.signOut();
          }
        },
        borderRadius: RadiusTokens.borderRadiusXxl,
        hoverColor: cc.raise2,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.base),
          decoration: BoxDecoration(
            border: Border.all(color: cc.line),
            borderRadius: RadiusTokens.borderRadiusXxl,
          ),
          alignment: Alignment.center,
          child: Text(
            'Logout',
            style: theme.textTheme.titleMedium?.copyWith(
              color: cc.risk,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
