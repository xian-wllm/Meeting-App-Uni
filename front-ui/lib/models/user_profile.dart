class UserProfile {
  final String id;
  final String fullname;
  final String? dateOfBirth;
  final String email;
  final List<String>? blockedUsers;
  final bool? match;
  final String? description;
  final String? faculte;
  final String? gender;
  final String? couleur;
  final String? profilePic;
  final List<String>? listePhoto;
  final List<String>? interests;
  final List<String>? centersOfInterest;

  UserProfile({
    required this.id,
    required this.fullname,
    required this.dateOfBirth,
    required this.email,
    required this.blockedUsers,
    required this.match,
    required this.description,
    required this.faculte,
    required this.gender,
    required this.couleur,
    required this.profilePic,
    required this.listePhoto,
    required this.interests,
    required this.centersOfInterest,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      fullname: json['fullname'],
      dateOfBirth: json['dateOfBirth'],
      email: json['email'],
      blockedUsers: List<String>.from(json['blockedUsers']),
      match: json['match'],
      description: json['description'],
      faculte: json['faculte'],
      gender: json['gender'],
      couleur: json['couleur'],
      profilePic: json['profilePic'],
      listePhoto: List<String>.from(json['liste_photo']),
      interests: List<String>.from(json['interests']),
      centersOfInterest: List<String>.from(json['centersOfInterest']),
    );
  }
}
