import 'package:flutter/cupertino.dart';

class Nest {
  final int key;
  final String label;
  final IconData icon;
  final bool expanded;
  final List<Nest> children;

  Nest({
    required this.key,
    required this.label,
    required this.icon,
    required this.expanded,
    required this.children,
  });

  Map<String, dynamic> toMap() {
    return {
      'key': key.toString(),
      'label': label.toString(),
      'icon': icon.codePoint.toString(),
      'expanded': expanded.toString(),
      'children': children.map((x) => x.toMap()).toList(),
    };
  }

  factory Nest.fromJson(Map<String, dynamic> map) {
    return Nest(
      key: map['key'],
      label: map['label'],
      expanded: map['expanded'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      children: List<Nest>.from(map['children']?.map((x) => Nest.fromJson(x))),
    );
  }
}
