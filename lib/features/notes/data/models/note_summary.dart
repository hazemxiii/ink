import 'package:ink/features/notes/data/models/note.dart';

class NoteSummary {
  NoteSummary({
    required this._id,
    required this._title,
    required this._content,
    required this._listId,
  });

  factory NoteSummary.fromJson(Map<String, dynamic> json) {
    return NoteSummary(
      id: json['id'] ?? json['_id'],
      title: json['title'],
      content: json['content'],
      listId: json['listId'],
    );
  }

  factory NoteSummary.fromNote(Note note, {required String listId}) {
    return NoteSummary(
      id: note.id,
      title: note.title,
      content: note.content,
      listId: listId,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': _id, 'title': _title, 'content': _content, 'listId': _listId};
  }

  final String _id;
  final String _title;
  final String _content;
  final String _listId;

  String get id => _id;
  String get title => _title;
  String get content => _content;
  String get listId => _listId;
}
