import 'package:flutter/material.dart';
import 'package:nest/db/db.dart';
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

  static Future<List<Map<String, dynamic>>> createAnccestorData(
      Drug drug) async {
    var drugList = await DrugDb.instance.readAllWithName(drug.name);
    var listOfAllDrugs = await DrugDb.instance.readAllDrugs();
    var categories = await DrugDb.instance.readAllDrugContainers();

    List<Map<String, dynamic>> container = [];

    for (var item in drugList) {
      List<Drug> anccesstors = [];
      container.add({
        "categoryId": item.categoryId,
        "categoryName": categories
            .where((element) => element.id == item.categoryId)
            .toList()
            .first
            .name,
        "itemId": item.id,
        "parentId": item.parentId,
        "itemName": item.name,
        "anccesstors":
            recurlyNestAnccesstor(item.parentId, listOfAllDrugs, anccesstors)
      });
    }

    return container;
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

List<Drug> recurlyNestAnccesstor(
    int parentId, List<Drug> listOfDrugs, List<Drug> anccesstors) {
  if (parentId > 0) {
    var drug =
        listOfDrugs.where((element) => element.id == parentId).toList().first;
    anccesstors.add(drug);
    recurlyNestAnccesstor(drug.parentId, listOfDrugs, anccesstors);
  }
  return anccesstors;
}

// var x = [
//   {_id: 35, name: Non-Selective, description: , parentId: 13, categoryId: 3, createdAt: 2021-12-01T09:44:57.495281},
//    {_id: 13, name: Agonists, description: no clues, parentId: 0, categoryId: 3, createdAt: 2021-11-30T22:58:14.728323},
//     {_id: 5, name: xyxtidtd, description: , parentId: 2, categoryId: 2, createdAt: 2021-11-29T11:46:30.000999},
//      {_id: 2, name: rursursurs, description: , parentId: 1, categoryId: 2, createdAt: 2021-11-29T11:46:02.305826},
//       {_id: 1, name: fjkghd, description: , parentId: 0, categoryId: 2, createdAt: 2021-11-29T11:44:56.599057},
//       ];