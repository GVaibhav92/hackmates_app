import 'dart:io';

class SignupDataModel {

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String confirmPassword;

  final List<String> interests;
  final String bio;
  final File? profilePhoto;


  const SignupDataModel({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.interests = const [],
    this.bio = '',
    this.profilePhoto,
  });

  /// Copy with method for immutable updates
  SignupDataModel copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? confirmPassword,
    File? profilePhoto,
    List<String>? interests,
    String? bio,
    bool clearPhoto = false,
  }) {
    return SignupDataModel(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      interests: interests ?? this.interests,
      bio: bio ?? this.bio,
      profilePhoto: clearPhoto ? null : (profilePhoto ?? this.profilePhoto),
    );
  }

  /// Validation methods

  /// Validate Step 1 (Basic Info)
  bool isStep1Valid() {
    return firstName.trim().isNotEmpty &&
        lastName.trim().isNotEmpty &&
        email.trim().isNotEmpty &&
        _isValidEmail(email) &&
        password.isNotEmpty &&
        password.length >= 8 &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword;
  }

  /// Validate Step 3 (Additional Info)
  bool isStep3Valid() {
    return interests.isNotEmpty; // At least one interest required
    // Bio is optional, so we don't check it
  }

  /// Check if email format is valid
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Get validation errors for Step 1
  String? getStep1Error() {
    if (firstName.trim().isEmpty) return 'First name is required';
    if (lastName.trim().isEmpty) return 'Last name is required';
    if (email.trim().isEmpty) return 'Email is required';
    if (!_isValidEmail(email)) return 'Invalid email format';
    if (password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    if (confirmPassword.isEmpty) return 'Please confirm your password';
    if (password != confirmPassword) return 'Passwords do not match';
    return null; // No errors
  }

  /// Get validation errors for Step 3
  String? getStep3Error() {
    if (interests.isEmpty) return 'Please select at least one interest';
    return null;
  }

  /// Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'email': email.trim(),
      'password': password,
      'interests': interests,
      'bio': bio.trim(),
      // Note: profilePhoto will be uploaded separately if needed
    };
  }

  @override
  String toString() {
    return 'SignupData(name: $firstName $lastName, email: $email, interests: $interests)';
  }
}

/// Hardcoded interest categories (will be replaced with backend API later)
class InterestCategories {
  static const List<String> all = [
    // Tech & Development
    'Flutter',
    'React',
    'Python',
    'JavaScript',
    'Machine Learning',
    'AI',
    'Blockchain',
    'Web3',
    'Cloud Computing',
    'DevOps',

    // Design
    'UI/UX Design',
    'Graphic Design',
    'Product Design',
    'Animation',
    '3D Modeling',

    // Business
    'Entrepreneurship',
    'Marketing',
    'Sales',
    'Product Management',
    'Finance',

    // Creative
    'Content Writing',
    'Video Editing',
    'Photography',
    'Music Production',
    'Game Development',

    // Data & Analytics
    'Data Science',
    'Data Analytics',
    'Business Intelligence',
    'Statistics',

    // Other
    'Open Source',
    'Hackathons',
    'Mentoring',
    'Networking',
    'Public Speaking',
  ];

  /// Get interests by category (for future organization)
  static Map<String, List<String>> getByCategory() {
    return {
      'Tech & Development': [
        'Flutter',
        'React',
        'Python',
        'JavaScript',
        'Machine Learning',
        'AI',
        'Blockchain',
        'Web3',
        'Cloud Computing',
        'DevOps',
      ],
      'Design': [
        'UI/UX Design',
        'Graphic Design',
        'Product Design',
        'Animation',
        '3D Modeling',
      ],
      'Business': [
        'Entrepreneurship',
        'Marketing',
        'Sales',
        'Product Management',
        'Finance',
      ],
      'Creative': [
        'Content Writing',
        'Video Editing',
        'Photography',
        'Music Production',
        'Game Development',
      ],
      'Data & Analytics': [
        'Data Science',
        'Data Analytics',
        'Business Intelligence',
        'Statistics',
      ],
      'Other': [
        'Open Source',
        'Hackathons',
        'Mentoring',
        'Networking',
        'Public Speaking',
      ],
    };
  }
}