import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ink/core/extensions/color.ext.dart';
import 'package:ink/core/extensions/string.ext.dart';
import 'package:ink/features/notes/data/models/note.dart';

class InkList {
  InkList({
    required this._id,
    required this._name,
    this._color,
    required this._notes,
    required this._createdAt,
    required this._updatedAt,
  });

  factory InkList.empty() => InkList(
    id: "",
    name: "",
    notes: [],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  factory InkList.fromJson(dynamic json) {
    json = Map<String, dynamic>.from(json);
    final notes = <Note>[];
    for (var noteJson in List<dynamic>.from(json['notes'])) {
      notes.add(Note.fromJson(noteJson));
    }
    return InkList(
      id: json['id'] ?? json['_id'],
      name: json['name'],
      color: json['color']?.toString().toColor,
      notes: notes,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  final String _id;
  final String _name;
  final Color? _color;
  final List<Note> _notes;
  final DateTime _createdAt;
  final DateTime _updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': _id,
      'name': _name,
      'color': _color?.toHex,
      'notes': _notes.map((note) => note.toJson()).toList(),
      'createdAt': _createdAt.toIso8601String(),
      'updatedAt': _updatedAt.toIso8601String(),
    };
  }

  InkList copyWith({
    String? id,
    String? name,
    Color? color,
    List<Note>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InkList(
      id: id ?? _id,
      name: name ?? _name,
      color: color ?? _color,
      notes: notes ?? _notes,
      createdAt: createdAt ?? _createdAt,
      updatedAt: updatedAt ?? _updatedAt,
    );
  }

  String get id => _id;
  String get name => _name;
  Color? get color => _color;
  List<Note> get notes => _notes;
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;
}
