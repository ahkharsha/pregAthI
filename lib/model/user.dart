class UserModel {
  String? name;
  String? id;
  String? phone;
  String? wifeEmail;
  String? husbandEmail;
  String? role;
  String? profilePic;

  UserModel({
    this.name,
    this.wifeEmail,
    this.id,
    this.husbandEmail,
    this.phone,
    this.role,
    this.profilePic,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'wifeEmail': wifeEmail,
        'husbandEmail': husbandEmail,
        'role': role,
        'profilePic': profilePic,
      };
}
