import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';

import 'package:nest/db/db.dart';
import 'package:nest/models/drug.dart';
import 'package:nest/models/drug_container.dart';
import 'package:nest/screens/details.dart';

import '../helpers/drug_helper.dart';

class Tree extends StatefulWidget {
  final DrugContainer drugContainer;
  const Tree({Key? key, required this.drugContainer}) : super(key: key);
  static const routeName = "/tree";

  @override
  _TreeState createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  TreeViewController? _treeViewController;
  List<Node>? _nodes;
  bool docsOpen = true;
  String? _selectedNode;

  // ! theme
  final ExpanderPosition _expanderPosition = ExpanderPosition.start;
  final ExpanderType _expanderType = ExpanderType.caret;
  final ExpanderModifier _expanderModifier = ExpanderModifier.none;

  @override
  void initState() {
    _nodes = [const Node(key: "1", label: "Loading data")];
    _treeViewController = TreeViewController(
      children: _nodes!,
      selectedKey: _selectedNode,
    );
    _getDrugsFromDbAndRePopulateNodes();
    super.initState();
  }

  _getDrugsFromDbAndRePopulateNodes() async {
    final drugList = await DrugDb.instance.readAll(widget.drugContainer.id!);
    final nestList = DrugHelper.createNestedData(drugList);
    final nestJsonList = nestList.map((e) => e.toMap()).toList();

    setState(() {
      _treeViewController =
          _treeViewController!.loadJSON(json: jsonEncode(nestJsonList));
    });
    print(
        "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[FAKKKKK???????????????????????????????]");
  }

  @override
  Widget build(BuildContext context) {
    var mq = MediaQuery.of(context).size;
    // ! theme
    TreeViewTheme _treeViewTheme = TreeViewTheme(
      expanderTheme: ExpanderThemeData(
        type: _expanderType,
        modifier: _expanderModifier,
        position: _expanderPosition,
        size: 20,
        color: Colors.blue,
      ),
      labelStyle: const TextStyle(
        fontSize: 16,
        letterSpacing: 0.3,
      ),
      parentLabelStyle: TextStyle(
        fontSize: 16,
        letterSpacing: 0.1,
        fontWeight: FontWeight.w800,
        color: Colors.blue.shade700,
      ),
      iconTheme: IconThemeData(
        size: 18,
        color: Colors.grey.shade800,
      ),
      colorScheme: Theme.of(context).colorScheme,
    );
    // ! theme

    print(
        "[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[[FAKKKKK]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.drugContainer.name),
        actions: [
          PopupMenuButton(
            onSelected: (val) {
              if (val == 0) {
                _showUpdate(context, widget.drugContainer);
              }
              if (val == 1) {
                _showDelete(context, widget.drugContainer.id);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                child: Text("Update"),
                value: 0,
              ),
              const PopupMenuItem(
                child: Text("Delete"),
                value: 1,
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: TreeView(
          controller: _treeViewController!,
          // ! slows response. expects  double tap
          supportParentDoubleTap: true,
          onExpansionChanged: (key, expanded) => _expandNode(key, expanded),
          onNodeDoubleTap: (key) {
            _showDetails(
              context,
              widget.drugContainer.id!,
              int.parse(key),
              _getDrugsFromDbAndRePopulateNodes,
            );
          },
          // onNodeTap: (key) {
          //   debugPrint(key);
          //   setState(() {
          //     _selectedNode = key;
          //     _treeViewController =
          //         _treeViewController!.copyWith(selectedKey: key);
          //   });
          // },
          theme: _treeViewTheme,
        ),
      ),

      // return const Center(child: CircularProgressIndicator());

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text("ADD ROOT DRUG"),
        onPressed: () {
          _showAdd(context, widget.drugContainer.id!,
              _getDrugsFromDbAndRePopulateNodes);
        },
      ),
    );
  }

  _expandNode(String key, bool expanded) {
    String msg = '${expanded ? "Expanded" : "Collapsed"}: $key';
    debugPrint(msg);
    Node node = _treeViewController!.getNode(key)!;
    if (node != null) {
      List<Node> updated;
      if (key == 'docs') {
        updated = _treeViewController!.updateNode(
            key,
            node.copyWith(
              expanded: expanded,
              icon: expanded ? Icons.folder_open : Icons.folder,
            ));
      } else {
        updated = _treeViewController!
            .updateNode(key, node.copyWith(expanded: expanded));
      }
      setState(() {
        if (key == 'docs') docsOpen = expanded;
        _treeViewController = _treeViewController!.copyWith(children: updated);
      });
    }
  }
}

void _showAdd(context, categoryId, _getDrugsFromDbAndRePopulateNodes) {
  var _data = "";
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Enter drug name'),
      content: TextFormField(
        onChanged: (val) {
          _data = val;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('ADD'),
        ),
      ],
    ),
  ).then(
    (value) {
      if (value == true) {
        if (_data == "" || _data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Drug name is neccessary!'),
            ),
          );
        } else {
          DrugDb.instance.create(
            Drug(
              name: _data,
              description: "",
              categoryId: categoryId,
              parentId: 0,
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
          _getDrugsFromDbAndRePopulateNodes();
        }
      }
    },
  );
}

void _showDetails(
  context,
  categoryId,
  int parentId,
  _getDrugsFromDbAndRePopulateNodes,
) {
  var _data = "";
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Enter drug name'),
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .popAndPushNamed(Details.routeName, arguments: parentId)
                  .then((value) {
                if (value == true) {
                  _getDrugsFromDbAndRePopulateNodes();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Drug deleted successfully.')));
                } else if (value == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Something went wrong.')));
                } else {
                  _getDrugsFromDbAndRePopulateNodes();
                }
              });
            },
            icon: const Icon(Icons.read_more_rounded),
            iconSize: 26,
            color: Colors.blueAccent,
            padding: const EdgeInsets.all(0),
          )
        ],
      ),
      content: TextFormField(
        onChanged: (val) {
          _data = val;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('ADD'),
        ),
      ],
    ),
  ).then(
    (value) {
      if (value == true) {
        if (_data == "" || _data.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Drug name is neccessary!')));
        } else {
          DrugDb.instance.create(
            Drug(
              name: _data,
              description: "",
              categoryId: categoryId,
              parentId: parentId,
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
          _getDrugsFromDbAndRePopulateNodes();
        }
      }
    },
  );
}

void _showDelete(context, categoryId) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Delete category?'),
      content: const Text("All data below this category will be lost!"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.red[600]),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('DELETE'),
        ),
      ],
    ),
  ).then(
    (value) async {
      if (value == true) {
        final count = await DrugDb.instance.deleteDrugContainer(categoryId);
        if (count > 0) {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).pop(false);
        }
      }
    },
  );
}

void _showUpdate(context, DrugContainer drugContainer) {
  String? _data;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Category name'),
      content: TextFormField(
        initialValue: drugContainer.name,
        onChanged: (val) {
          _data = val;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.green[600]),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('UPDATE'),
        ),
      ],
    ),
  ).then(
    (value) async {
      if (value == true) {
        if (_data == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Category name is neccessary!'),
            ),
          );
        } else {
          final count = await DrugDb.instance.updateDrugContainer(
            DrugContainer(
                id: drugContainer.id,
                name: _data!,
                createdAt: drugContainer.createdAt),
          );
          if (count > 0) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pop(false);
          }
        }
      }
    },
  );
}
