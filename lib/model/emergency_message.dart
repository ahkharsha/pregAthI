class EmergencyMessageModel {
  String? name;
  String? id;
  String? phone;
  String? husbandPhone;
  String? wifeEmail;
  String? location;
  String? date;
  String? time;

  EmergencyMessageModel({
    this.name,
    this.wifeEmail,
    this.id,
    this.phone,
    this.location,
    this.date,
    this.time,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'wifeEmail': wifeEmail,
        'location': location,
        'date':date,
        'time':time,
      };
}
