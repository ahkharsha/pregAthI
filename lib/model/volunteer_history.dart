class VolunteerHistory {
  String? name;
  String? id;
  String? phone;
  String? husbandPhone;
  String? wifeEmail;
  String? location;
  String? date;
  String? time;
  String? locality;
  String? postal;
  String? profilePic;

  VolunteerHistory({
    this.name,
    this.wifeEmail,
    this.id,
    this.phone,
    this.location,
    this.date,
    this.time,
    this.locality,
    this.postal,
    this.profilePic,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'wifeEmail': wifeEmail,
        'location': location,
        'date': date,
        'time': time,
        'locality': locality,
        'postal': postal,
        'profilePic': profilePic,
      };
}
