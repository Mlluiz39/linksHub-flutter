class SocialLink {
  final int? id;
  final String platform;
  final String username;
  final String url;
  final String name; // Nome do link
  final DateTime createdAt;
  final DateTime updatedAt;

  SocialLink({
    this.id,
    required this.platform,
    required this.username,
    required this.url,
    required this.name, // Nome do link
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'platform': platform,
      'username': username,
      'url': url,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory SocialLink.fromMap(Map<String, dynamic> map) {
    return SocialLink(
      id: map['id'],
      platform: map['platform'],
      username: map['username'],
      url: map['url'],
      name: map['name'] ?? map['platform'], // Usa a plataforma como nome padrão se não houver nome
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  SocialLink copyWith({
    int? id,
    String? platform,
    String? username,
    String? url,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SocialLink(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      username: username ?? this.username,
      url: url ?? this.url,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
