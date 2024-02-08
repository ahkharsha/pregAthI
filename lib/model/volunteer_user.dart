class VolunteerUserModel {
  String? name;
  String? id;
  String? phone;
  String? volunteerEmail;
  String? role;
  String? profilePic;
  String? token;

  VolunteerUserModel({
    this.name,
    this.volunteerEmail,
    this.id,
    this.phone,
    this.role,
    this.profilePic,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'volunteerEmail': volunteerEmail,
        'role': role,
        'profilePic': profilePic,
        'token':token,
      };

}
