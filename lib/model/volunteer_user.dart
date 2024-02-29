class VolunteerUserModel {
  String? name;
  String? id;
  String? phone;
  String? volunteerEmail;
  String? role;
  String? profilePic;
  String? token;
  String? lastAnnouncement;

  VolunteerUserModel({
    this.name,
    this.volunteerEmail,
    this.id,
    this.phone,
    this.role,
    this.profilePic,
    this.token,
    this.lastAnnouncement,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'volunteerEmail': volunteerEmail,
        'role': role,
        'profilePic': profilePic,
        'token': token,
        'lastAnnouncement': lastAnnouncement,
      };
}
