const String drugContainerTableName = "container";

class DrugContainerFields {
  static const String id = "_id";
  static const String name = "name";
  static const String createdAt = "createdAt";
  static const List<String> values = [id, name, createdAt];
}

class DrugContainer {
  final int? id;
  final String name;
  final String createdAt;

  DrugContainer({this.id, required this.name, required this.createdAt});

  DrugContainer.fromJson(Map<String, dynamic> json)
      : id = json[DrugContainerFields.id] as int,
        name = json[DrugContainerFields.name] as String,
        createdAt = json[DrugContainerFields.createdAt] as String;

  toMap() {
    return {
      DrugContainerFields.id: id,
      DrugContainerFields.name: name,
      DrugContainerFields.createdAt: createdAt,
    };
  }
}
