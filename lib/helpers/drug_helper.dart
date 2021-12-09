import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:nest/db/db.dart';
import 'package:nest/models/drug.dart';
import 'package:nest/models/drug_container.dart';

class DrugHelper {
  static List<TreeNode> createNestedData(List<Drug> listOfDrugs) {
    if (listOfDrugs.isEmpty) return [];

    // ! get the nodes
    final rootItems =
        listOfDrugs.where((element) => element.parentId == 0).toList();
    // ! conver to Nest
    final rootNestList = rootItems
        .map((e) => TreeNode(
              id: e.id!.toString(),
              label: e.name,
              data: e.clr,
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

  static Future<int> exportData() async {
    String fileName = "nested_data.json";
    File jsonFile = File("/storage/emulated/0/Download/" + fileName);
    bool fileExists = jsonFile.existsSync();

    Map<String, dynamic> fileContent = {};
    var listOfAllDrugs = await DrugDb.instance.readAllDrugs();
    var listOfAllCategories = await DrugDb.instance.readAllDrugContainers();

    fileContent["drugs"] = listOfAllDrugs.map((e) => e.toMap()).toList();
    fileContent["categories"] =
        listOfAllCategories.map((e) => e.toMap()).toList();

    try {
      if (fileExists) {
        writeToFile(fileContent, jsonFile);
      } else {
        jsonFile.createSync();
        fileExists = true;
        writeToFile(fileContent, jsonFile);
      }
    } catch (e) {
      return 0;
    }
    return 1;
  }

  static Future<int> importData(PlatformFile file) async {
    File _file = File(file.path!);
    try {
      Map<String, dynamic> jsonFileContent =
          json.decode(_file.readAsStringSync());

      List<dynamic> jsonDrugList = jsonFileContent["drugs"];
      List<dynamic> jsonDrugContainers = jsonFileContent["categories"];

      List<Drug> ld = jsonDrugList.map((e) => Drug.fromJson(e)).toList();
      List<DrugContainer> lc =
          jsonDrugContainers.map((e) => DrugContainer.fromJson(e)).toList();

      await DrugDb.instance.createBulk(ld, lc);
    } catch (e) {
      return 0;
    }
    return 1;
  }
}

void writeToFile(Map<String, dynamic> content, File file) {
  file.writeAsStringSync(json.encode(content), flush: true);
}

recurlyNest(List<TreeNode> list, List<Drug> listOfDrugs) {
  if (list.isEmpty) return;
  for (var nest in list) {
    nest.addChildren(
      listOfDrugs
          .where((element) => element.parentId == int.parse(nest.id))
          .toList()
          .map((e) => TreeNode(
                id: e.id!.toString(),
                label: e.name,
                data: e.clr,
              ))
          .toList(),
    );

    recurlyNest(nest.children.toList(), listOfDrugs);
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
