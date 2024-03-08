import 'package:flutter/foundation.dart';

class Community {
  final String id;
  final String name;
  final String banner;
  final String avatar;
  final List<String> members;
  final List<String> mods;
  final String createDate;
  final String createTime;

  Community({
    required this.id,
    required this.name,
    required this.banner,
    required this.avatar,
    required this.members,
    required this.mods,
    required this.createDate,
    required this.createTime,
  });

  Community copyWith({
    String? id,
    String? name,
    String? banner,
    String? avatar,
    List<String>? members,
    List<String>? mods,
    String? createDate,
    String? createTime,
  }) {
    return Community(
      id: id ?? this.id,
      name: name ?? this.name,
      banner: banner ?? this.banner,
      avatar: avatar ?? this.avatar,
      members: members ?? this.members,
      mods: mods ?? this.mods,
      createDate: createDate ?? this.createDate,
      createTime: createTime ?? this.createTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'banner': banner,
      'avatar': avatar,
      'members': members,
      'mods': mods,
      'createDate': createDate,
      'createTime': createTime,
    };
  }

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      banner: map['banner'] ?? '',
      avatar: map['avatar'] ?? '',
      members: List<String>.from(map['members']),
      mods: List<String>.from(map['mods']),
      createDate: map['createDate'] ?? '',
      createTime: map['createTime'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Community(id: $id, name: $name, banner: $banner, avatar: $avatar, members: $members, mods: $mods, createDate: $createDate, createTime: $createTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Community &&
        other.id == id &&
        other.name == name &&
        other.banner == banner &&
        other.avatar == avatar &&
        listEquals(other.members, members) &&
        listEquals(other.mods, mods) &&
        other.createDate == createDate &&
        other.createTime == createTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        banner.hashCode ^
        avatar.hashCode ^
        members.hashCode ^
        mods.hashCode ^
        createDate.hashCode ^
        createTime.hashCode;
  }
}
