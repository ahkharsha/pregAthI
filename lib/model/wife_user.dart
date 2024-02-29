class WifeUserModel {
  String? name;
  String? id;
  String? phone;
  String? wifeEmail;
  String? husbandPhone;
  String? role;
  String? profilePic;
  String? hospitalPhone;
  String? week;
  String? bio;
  int? strikeCount;
  int? banCount;
  bool? isBanned;
  String? totalWeek;
  String? lastAnnouncement;
  String? weekUpdated;
  bool? readGuidelines;

  WifeUserModel({
    this.name,
    this.wifeEmail,
    this.id,
    this.husbandPhone,
    this.phone,
    this.role,
    this.profilePic,
    this.hospitalPhone,
    this.week,
    this.bio,
    this.strikeCount,
    this.banCount,
    this.isBanned,
    this.totalWeek,
    this.lastAnnouncement,
    this.weekUpdated,
    this.readGuidelines,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'id': id,
        'wifeEmail': wifeEmail,
        'husbandPhone': husbandPhone,
        'role': role,
        'profilePic': profilePic,
        'hospitalPhone': hospitalPhone,
        'week': week,
        'bio': bio,
        'strikeCount': strikeCount,
        'banCount': banCount,
        'isBanned': isBanned,
        'totalWeek': totalWeek,
        'lastAnnouncement': lastAnnouncement,
        'weekUpdated': weekUpdated,
        'readGuidelines': readGuidelines,
      };
}
