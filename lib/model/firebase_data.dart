class FirebaseData {
  final String imageUrl;
  final String title;
  
  FirebaseData({
    required this.imageUrl,
    required this.title,
    
  });

  FirebaseData copyWith({
    String? imageUrl,
    String? title,
    
  }) {
    return FirebaseData(
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      
    };
  }

  factory FirebaseData.fromMap(Map<String, dynamic> map) {
    return FirebaseData(
      imageUrl: map['iamgeUrl'] ?? '',
      title: map['title'] ?? '',
      
    );
  }

  @override
  String toString() {
    return 'FirebaseData(imageUrl: $imageUrl, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is FirebaseData &&
        other.imageUrl == imageUrl &&
        other.title == title;
        
  }

  @override
  int get hashCode {
    return imageUrl.hashCode ^
        title.hashCode;
       
  }
}
