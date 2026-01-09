import 'dart:convert';

class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? photoUrl;
  final List<String>? interests;
  final String? bio;
  final bool isVerified;

  UserModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    this.interests,
    this.bio,
    this.isVerified = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] is int ? map['id'] : (map['id'] != null ? int.tryParse(map['id'].toString()) : null),
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'] ?? map['photo_url'] ?? map['picture'],
      interests: (map['interests'] as List?)?.cast<String>(),
      bio: map['bio'] ?? '',
      isVerified: map['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'photoUrl': photoUrl,
      'interests': interests,
      'bio': bio,
      'isVerified': isVerified,
    };
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source));
}