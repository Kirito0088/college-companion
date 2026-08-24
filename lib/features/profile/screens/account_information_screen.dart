import 'package:college_companion/features/profile/providers/profile_provider.dart';
import 'package:college_companion/theme/cc_tokens.dart';
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
    final cc = context.cc;
    final profile = ref.watch(userProfileProvider);
    _initControllers(profile);

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
          'Account Information',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProfileCard(context, profile),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildPersonalInformation(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAcademicInformation(context),
            const SizedBox(height: LayoutTokens.sectionGap),
            _buildAccountStatus(context, profile),
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
    final cc = context.cc;
    final initial = profile.displayName.isNotEmpty
        ? profile.displayName[0].toUpperCase()
        : 'J';

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.xl),
      decoration: BoxDecoration(
        color: cc.raise,
        borderRadius: RadiusTokens.borderRadiusXxl,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: cc.priSoft,
            child: Text(
              initial,
              style: theme.textTheme.displaySmall?.copyWith(
                color: cc.pri,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Text(
            profile.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: cc.fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(
            profile.email,
            style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
          ),
          const SizedBox(height: SpacingTokens.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SpacingTokens.md,
              vertical: SpacingTokens.xs,
            ),
            decoration: BoxDecoration(
              color: cc.raise2,
              borderRadius: RadiusTokens.borderRadiusSm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.shield_person, size: 16, color: cc.pri),
                const SizedBox(width: SpacingTokens.sm),
                Text(
                  'Signed in with Google',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cc.mut,
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
            context: context,
            label: 'Display Name (from Google)',
            controller: _displayNameController,
            readOnly: true,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            context: context,
            label: 'College Name',
            controller: _collegeNameController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            context: context,
            label: 'Branch',
            controller: _branchController,
          ),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  context: context,
                  label: 'Semester',
                  controller: _semesterController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                flex: 2,
                child: _buildTextField(
                  context: context,
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
            context: context,
            label: 'University',
            controller: _universityController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            context: context,
            label: 'Course',
            controller: _courseController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            context: context,
            label: 'Department',
            controller: _departmentController,
          ),
          const SizedBox(height: SpacingTokens.md),
          _buildTextField(
            context: context,
            label: 'Expected Graduation',
            controller: _gradYearController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(String? isoUtc) {
    if (isoUtc == null || isoUtc.isEmpty) return 'Not yet synced';
    final parsed = DateTime.tryParse(isoUtc)?.toLocal();
    if (parsed == null) return 'Not yet synced';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final hour12 = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
    final minute = parsed.minute.toString().padLeft(2, '0');
    final period = parsed.hour >= 12 ? 'PM' : 'AM';
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}, $hour12:$minute $period';
  }

  Widget _buildAccountStatus(BuildContext context, UserProfileDetails profile) {
    final cc = context.cc;
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
            cc.pri,
          ),
          Divider(height: SpacingTokens.xl, color: cc.line),
          _buildStatusRow(
            context,
            'Authentication',
            'Google Sign-In',
            Symbols.login,
            cc.mut,
          ),
          Divider(height: SpacingTokens.xl, color: cc.line),
          _buildStatusRow(
            context,
            'Account Created',
            _formatTimestamp(profile.createdAt),
            Symbols.calendar_today,
            cc.mut,
          ),
          Divider(height: SpacingTokens.xl, color: cc.line),
          _buildStatusRow(
            context,
            'Last Sync',
            _formatTimestamp(profile.updatedAt),
            Symbols.sync,
            cc.mut,
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
    final cc = context.cc;
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: SpacingTokens.md),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: cc.mut),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: cc.fg,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    final cc = context.cc;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: cc.mut),
        filled: true,
        fillColor: readOnly ? cc.raise2 : cc.bg,
        border: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(color: cc.line2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(color: cc.line2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: RadiusTokens.borderRadiusMd,
          borderSide: BorderSide(color: cc.pri, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md,
          vertical: SpacingTokens.md,
        ),
      ),
      style: TextStyle(color: cc.fg),
    );
  }

  Widget _buildSaveChangesButton(UserProfileDetails currentProfile) {
    return FilledButton(
      onPressed: () async {
        final updated = currentProfile.copyWith(
          collegeName: _collegeNameController.text.trim(),
          branch: _branchController.text.trim(),
          semester: _semesterController.text.trim(),
          studentId: _studentIdController.text.trim(),
          university: _universityController.text.trim(),
          course: _courseController.text.trim(),
          department: _departmentController.text.trim(),
          gradYear: _gradYearController.text.trim(),
        );
        try {
          await ref.read(userProfileProvider.notifier).updateProfile(updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account information updated successfully!'),
              ),
            );
          }
        } on Exception {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not save changes. Please try again.'),
              ),
            );
          }
        }
      },
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.all(SpacingTokens.lg),
        shape: const RoundedRectangleBorder(
          borderRadius: RadiusTokens.borderRadiusXl,
        ),
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
    final cc = context.cc;
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
              color: cc.fg,
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
          decoration: BoxDecoration(
            color: cc.raise,
            borderRadius: RadiusTokens.borderRadiusXxl,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}
