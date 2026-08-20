import 'package:college_companion/features/profile/providers/profile_provider.dart';
import 'package:college_companion/theme/color_tokens.dart';
import 'package:college_companion/theme/radius_tokens.dart';
import 'package:college_companion/theme/spacing_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AccountInformationScreen extends ConsumerStatefulWidget {
  const AccountInformationScreen({super.key});

  @override
  ConsumerState<AccountInformationScreen> createState() =>
      _AccountInformationScreenState();
}

class _AccountInformationScreenState
    extends ConsumerState<AccountInformationScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _collegeNameController;
  late final TextEditingController _branchController;
  late final TextEditingController _semesterController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _universityController;
  late final TextEditingController _courseController;
  late final TextEditingController _departmentController;
  late final TextEditingController _gradYearController;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _collegeNameController = TextEditingController();
    _branchController = TextEditingController();
    _semesterController = TextEditingController();
    _studentIdController = TextEditingController();
    _universityController = TextEditingController();
    _courseController = TextEditingController();
    _departmentController = TextEditingController();
    _gradYearController = TextEditingController();
  }

  void _initControllers(UserProfileDetails profile) {
    if (_initialized) return;
    _initialized = true;
    _displayNameController.text = profile.displayName;
    _collegeNameController.text = profile.collegeName;
    _branchController.text = profile.branch;
    _semesterController.text = profile.semester;
    _studentIdController.text = profile.studentId;
    _universityController.text = profile.university;
    _courseController.text = profile.course;
    _departmentController.text = profile.department;
    _gradYearController.text = profile.gradYear;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _collegeNameController.dispose();
    _branchController.dispose();
    _semesterController.dispose();
    _studentIdController.dispose();
    _universityController.dispose();
    _courseController.dispose();
    _departmentController.dispose();
    _gradYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(userProfileProvider);
    _initControllers(profile);

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
          'Account Information',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(context, profile),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildPersonalInformation(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAcademicInformation(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAccountStatus(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildSaveChangesButton(profile),
            const SizedBox(height: SpacingTokens.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserProfileDetails profile) {
    final theme = Theme.of(context);
    final initial = profile.displayName.isNotEmpty
        ? profile.displayName[0].toUpperCase()
        : 'J';

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      decoration: const BoxDecoration(
        color: ColorTokens.surfaceContainer,
        borderRadius: RadiusTokens.borderRadiusXl,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: ColorTokens.primaryContainer,
            child: Text(
              initial,
              style: theme.textTheme.displaySmall?.copyWith(
                color: ColorTokens.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            profile.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            profile.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.xs,
            ),
            decoration: const BoxDecoration(
              color: ColorTokens.surfaceContainerHigh,
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Symbols.shield_person,
                  size: 16,
                  color: ColorTokens.primary,
                ),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Signed in with Google',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: ColorTokens.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation(BuildContext context) {
    return _buildSectionContainer(
      context: context,
      title: 'Personal Information',
      child: Column(
        children: [
          _buildTextField(
            label: 'Display Name',
            controller: _displayNameController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            label: 'College Name',
            controller: _collegeNameController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(label: 'Branch', controller: _branchController),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Semester',
                  controller: _semesterController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  label: 'Student ID',
                  controller: _studentIdController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInformation(BuildContext context) {
    return _buildSectionContainer(
      context: context,
      title: 'Academic Information',
      child: Column(
        children: [
          _buildTextField(
            label: 'University',
            controller: _universityController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(label: 'Course', controller: _courseController),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            label: 'Department',
            controller: _departmentController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            label: 'Expected Graduation',
            controller: _gradYearController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatus(BuildContext context) {
    return _buildSectionContainer(
      context: context,
      title: 'Account Status',
      child: Column(
        children: [
          _buildStatusRow(
            context,
            'Status',
            'Verified',
            Symbols.verified,
            ColorTokens.primary,
          ),
          const Divider(
            height: SpacingTokens.xl,
            color: ColorTokens.outlineVariant,
          ),
          _buildStatusRow(
            context,
            'Authentication',
            'Google Sign-In',
            Symbols.login,
            ColorTokens.onSurfaceVariant,
          ),
          const Divider(
            height: SpacingTokens.xl,
            color: ColorTokens.outlineVariant,
          ),
          _buildStatusRow(
            context,
            'Account Created',
            '12 June 2026',
            Symbols.calendar_today,
            ColorTokens.onSurfaceVariant,
          ),
          const Divider(
            height: SpacingTokens.xl,
            color: ColorTokens.outlineVariant,
          ),
          _buildStatusRow(
            context,
            'Last Sync',
            'Today, 9:30 AM',
            Symbols.sync,
            ColorTokens.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: ColorTokens.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: ColorTokens.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: ColorTokens.onSurfaceVariant),
        filled: true,
        fillColor: ColorTokens.surface,
        border: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(
            color: ColorTokens.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(
            color: ColorTokens.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(color: ColorTokens.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
      ),
      style: const TextStyle(color: ColorTokens.onSurface),
    );
  }

  Widget _buildSaveChangesButton(UserProfileDetails currentProfile) {
    return FilledButton(
      onPressed: () async {
        final updated = currentProfile.copyWith(
          displayName: _displayNameController.text.trim(),
          collegeName: _collegeNameController.text.trim(),
          branch: _branchController.text.trim(),
          semester: _semesterController.text.trim(),
          studentId: _studentIdController.text.trim(),
          university: _universityController.text.trim(),
          course: _courseController.text.trim(),
          department: _departmentController.text.trim(),
          gradYear: _gradYearController.text.trim(),
        );
        await ref.read(userProfileProvider.notifier).updateProfile(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account information updated successfully!'),
            ),
          );
        }
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: const Text(
        'Save Changes',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.sm,
            bottom: SpacingTokens.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: ColorTokens.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: LayoutTokens.cardPadding,
            vertical: LayoutTokens.cardPadding + 4,
          ),
          decoration: const BoxDecoration(
            color: ColorTokens.surfaceContainer,
            borderRadius: RadiusTokens.borderRadiusXl,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}
