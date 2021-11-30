import 'package:flutter/material.dart';
import 'package:nest/models/drug.dart';
import 'package:nest/models/nest.dart';

class DrugHelper {
  static List<Nest> createNestedData(List<Drug> listOfDrugs) {
    if (listOfDrugs.isEmpty) return [];

    // ! get the nodes
    final rootItems =
        listOfDrugs.where((element) => element.parentId == 0).toList();
    // ! conver to Nest
    final rootNestList = rootItems
        .map((e) => Nest(
              key: e.id!,
              label: e.name,
              icon: Icons.ac_unit,
              expanded: true,
              children: [],
            ))
        .toList();
    // ! insert to nest

    recurlyNest(rootNestList, listOfDrugs);

    return rootNestList;
  }
}

recurlyNest(List<Nest> list, List<Drug> listOfDrugs) {
  if (list.isEmpty) return;
  for (var nest in list) {
    nest.children.addAll(
      listOfDrugs
          .where((element) => element.parentId == nest.key)
          .toList()
          .map((e) => Nest(
                key: e.id!,
                label: e.name,
                icon: Icons.ac_unit,
                expanded: true,
                children: [],
              ))
          .toList(),
    );
    recurlyNest(nest.children, listOfDrugs);
  }
}
// fjkghd -- parent 0 -- id 1
//      rursursurs parent 1 -- id 2
//          rusurrus parent 2 -- id 4
//          xyxtidtd parent 2 -- id 5

//      ursr7ar7a parent 1 -- id 3
//          zrjzrhzrusu parent 3 -- id 6
//          rusursurs parent 3 -- id 7

// Nest(
// label: name,
// key: _id,
// icon: Icons.input,
// children: [],
// )