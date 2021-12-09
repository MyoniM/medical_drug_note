import 'package:flutter/material.dart';

const String tableName = "drugs";

class DrugFields {
  static const String id = "_id";
  static const String name = "name";
  static const String description = "description";
  static const String parentId = "parentId";
  static const String categoryId = "categoryId";
  static const String createdAt = "createdAt";
  static const String clr = "clr";
  static const List<String> values = [
    id,
    name,
    description,
    parentId,
    categoryId,
    createdAt,
    clr
  ];
}

class Drug {
  final int? id;
  final String name;
  final String description;
  final int parentId;
  final int categoryId;
  final String createdAt;
  final int clr;

  Drug({
    this.id,
    required this.name,
    required this.description,
    required this.parentId,
    required this.categoryId,
    required this.createdAt,
    required this.clr,
  });

  Drug.fromJson(Map<String, dynamic> json)
      : id = json[DrugFields.id] as int,
        name = json[DrugFields.name] as String,
        description = json[DrugFields.description] as String,
        parentId = json[DrugFields.parentId] as int,
        categoryId = json[DrugFields.categoryId] as int,
        createdAt = json[DrugFields.createdAt] as String,
        clr = json[DrugFields.clr] ?? Colors.black.value;

  toMap() {
    return {
      DrugFields.id: id,
      DrugFields.name: name,
      DrugFields.description: description,
      DrugFields.parentId: parentId,
      DrugFields.categoryId: categoryId,
      DrugFields.createdAt: createdAt,
      DrugFields.clr: clr,
    };
  }
}
