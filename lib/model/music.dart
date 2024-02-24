class Music {
  final String title;
  final String artist;
  final String imageUrl;
  final String url;

  Music({
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.url,
  });

  Music copyWith({
    String? title,
    String? artist,
    String? imageUrl,
    String? url,
  }) {
    return Music(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      imageUrl: imageUrl ?? this.imageUrl,
      url: url ?? this.url,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'imageUrl': imageUrl,
      'url': url,
    };
  }

  factory Music.fromMap(Map<String, dynamic> map) {
    return Music(
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      url: map['url'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Music(title: $title, artist: $artist, imageUrl: $imageUrl, url: $url)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Music &&
        other.title == title &&
        other.artist == artist &&
        other.imageUrl == imageUrl &&
        other.url == url;
  }

  @override
  int get hashCode {
    return title.hashCode ^ artist.hashCode ^ imageUrl.hashCode ^ url.hashCode;
  }
}
