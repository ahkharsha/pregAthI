class VolunteerUserModel {
  String? name;
  String? id;
  String? phone;
  String? email;
  String? role;
  String? profilePic;

  VolunteerUserModel({
    this.name,
    this.email,
    this.id,
    this.phone,
    this.role,
    this.profilePic,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'email': email,
        'role': role,
        'profilePic': profilePic,
      };
}
