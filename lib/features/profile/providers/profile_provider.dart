import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileDetails {
  const UserProfileDetails({
    this.displayName = 'Jayesh Patil',
    this.email = 'jayeshpatil@gmail.com',
    this.collegeName = 'ABC College of Engineering',
    this.branch = 'Computer Science',
    this.semester = '6',
    this.studentId = '12345678',
    this.university = 'Mumbai University',
    this.course = 'Bachelor of Engineering',
    this.department = 'Computer Science (AI & ML)',
    this.gradYear = '2028',
  });

  final String displayName;
  final String email;
  final String collegeName;
  final String branch;
  final String semester;
  final String studentId;
  final String university;
  final String course;
  final String department;
  final String gradYear;

  UserProfileDetails copyWith({
    String? displayName,
    String? email,
    String? collegeName,
    String? branch,
    String? semester,
    String? studentId,
    String? university,
    String? course,
    String? department,
    String? gradYear,
  }) {
    return UserProfileDetails(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      collegeName: collegeName ?? this.collegeName,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      studentId: studentId ?? this.studentId,
      university: university ?? this.university,
      course: course ?? this.course,
      department: department ?? this.department,
      gradYear: gradYear ?? this.gradYear,
    );
  }
}

class UserProfileNotifier extends StateNotifier<UserProfileDetails> {
  UserProfileNotifier() : super(const UserProfileDetails()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    state = UserProfileDetails(
      displayName: prefs.getString('profile_displayName') ?? 'Jayesh Patil',
      email: prefs.getString('profile_email') ?? 'jayeshpatil@gmail.com',
      collegeName: prefs.getString('profile_collegeName') ?? 'ABC College of Engineering',
      branch: prefs.getString('profile_branch') ?? 'Computer Science',
      semester: prefs.getString('profile_semester') ?? '6',
      studentId: prefs.getString('profile_studentId') ?? '12345678',
      university: prefs.getString('profile_university') ?? 'Mumbai University',
      course: prefs.getString('profile_course') ?? 'Bachelor of Engineering',
      department: prefs.getString('profile_department') ?? 'Computer Science (AI & ML)',
      gradYear: prefs.getString('profile_gradYear') ?? '2028',
    );
  }

  Future<void> updateProfile(UserProfileDetails details) async {
    state = details;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_displayName', details.displayName);
    await prefs.setString('profile_email', details.email);
    await prefs.setString('profile_collegeName', details.collegeName);
    await prefs.setString('profile_branch', details.branch);
    await prefs.setString('profile_semester', details.semester);
    await prefs.setString('profile_studentId', details.studentId);
    await prefs.setString('profile_university', details.university);
    await prefs.setString('profile_course', details.course);
    await prefs.setString('profile_department', details.department);
    await prefs.setString('profile_gradYear', details.gradYear);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfileDetails>((ref) {
  return UserProfileNotifier();
});
