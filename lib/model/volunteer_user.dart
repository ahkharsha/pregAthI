class VolunteerUserModel {
  String? name;
  String? id;
  String? phone;
  String? volunteerEmail;
  String? role;
  String? profilePic;

  VolunteerUserModel({
    this.name,
    this.volunteerEmail,
    this.id,
    this.phone,
    this.role,
    this.profilePic,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'volunteerEmail': volunteerEmail,
        'role': role,
        'profilePic': profilePic,
      };
}
