class EmergencyMessageModel {
  String? name;
  String? id;
  String? phone;
  String? wifeEmail;
  String? location;

  EmergencyMessageModel(
      {this.name,
      this.wifeEmail,
      this.id,
      this.phone,
      this.location,});

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'wifeEmail': wifeEmail,
        'role':location,
      };
}