class Note {
  Note({
    required this._id,
    required this._title,
    required this._content,
    required this._createdAt,
    required this._updatedAt,
  });

  factory Note.empty() {
    return Note(
      id: '',
      title: '',
      content: '',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
  }

  factory Note.fromJson(dynamic json) {
    json = Map<String, dynamic>.from(json);
    return Note(
      id: json['id'] ?? json['_id'],
      title: json['title'],
      content: json['content'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now().toUtc(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now().toUtc(),
    );
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? _id,
      title: title ?? _title,
      content: content ?? _content,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'title': _title,
      'content': _content,
      'createdAt': _createdAt.toIso8601String(),
      'updatedAt': _updatedAt.toIso8601String(),
    };
  }

  final String _id;
  final String _title;
  final String _content;
  final DateTime _createdAt;
  final DateTime _updatedAt;

  String get id => _id;
  String get title => _title;
  String get content => _content;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
}
