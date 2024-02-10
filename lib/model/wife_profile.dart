class WifeProfile {
  final String name;
  final String id;
  final String profilePic;
  final String week;
  final String bio;

  WifeProfile({
    required this.name,
    required this.id,
    required this.profilePic,
    required this.week,
    required this.bio,
  });

  WifeProfile copyWith({
    String? name,
    String? id,
    String? profilePic,
    String? week,
    String? bio,
  }) {
    return WifeProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
      week: week ?? this.week,
      bio: bio ?? this.bio,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profilePic': profilePic,
      'week':week,
      'bio':bio,
    };
  }

  factory WifeProfile.fromMap(Map<String, dynamic> map) {
    return WifeProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      week: map['week'] ?? '',
      bio: map['bio'] ?? ''
    );
  }
}
