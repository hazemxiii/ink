import 'dart:ui';

import 'package:ink/core/extensions/color.ext.dart';
import 'package:ink/core/extensions/string.ext.dart';
import 'package:ink/features/lists/data/models/ink_list.dart';

class InkListSummary {
  InkListSummary({
    required this._id,
    required this._name,
    this._color,
    required this._notesIds,
    required this._createdAt,
    required this._updatedAt,
  });
  factory InkListSummary.fromJson(Map<String, dynamic> json) {
    return InkListSummary(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      color: json['color']?.toString().toColor,
      notesIds: List<String>.from(json['notesIds'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now().toUtc(),
    );
  }

  factory InkListSummary.fromParent(InkList parent) {
    return InkListSummary(
      id: parent.id,
      name: parent.name,
      color: parent.color,
      notesIds: parent.notes.map((note) => note.id).toList(),
      createdAt: parent.createdAt,
      updatedAt: parent.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'color': _color?.toHex,
      'notesIds': _notesIds,
      'createdAt': _createdAt.toIso8601String(),
      'updatedAt': _updatedAt.toIso8601String(),
    };
  }

  final String _id;
  final String _name;
  final Color? _color;
  final List<String> _notesIds;
  final DateTime _createdAt;
  final DateTime _updatedAt;

  String get id => _id;
  String get name => _name;
  Color? get color => _color;
  List<String> get notesIds => _notesIds;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
}
