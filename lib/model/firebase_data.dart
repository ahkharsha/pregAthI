class FirebaseData {
  final String imageUrl;
  final String url;
  final String title;
  final String description;
  final String date;
  final String time;
  
  FirebaseData({
    required this.imageUrl,
    required this.url,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
  });

  FirebaseData copyWith({
    String? imageUrl,
    String? url,
    String? title,
    String? description,
    String? date,
    String? time,
  }) {
    return FirebaseData(
      imageUrl: imageUrl ?? this.imageUrl,
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'url': url,
      'title': title,
      'description': description,
      'date': date,
      'time': time,
    };
  }

  factory FirebaseData.fromMap(Map<String, dynamic> map) {
    return FirebaseData(
      imageUrl: map['imageUrl'] ?? '',
      url: map['url'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
    );
  }

  @override
  String toString() {
    return 'FirebaseData(imageUrl: $imageUrl, title: $title, url: $url, description: $description, date: $date, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FirebaseData &&
        other.imageUrl == imageUrl &&
        other.url == url &&
        other.description == description &&
        other.title == title &&
        other.date == date &&
        other.time == time;
  }

  @override
  int get hashCode {
    return imageUrl.hashCode ^
        url.hashCode ^
        description.hashCode ^
        title.hashCode ^
        date.hashCode ^
        time.hashCode;
  }
}
