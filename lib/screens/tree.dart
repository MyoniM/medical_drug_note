import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

import 'package:nest/db/db.dart';
import 'package:nest/models/drug.dart';
import 'package:nest/models/drug_container.dart';
import 'package:nest/node/tree_node_tile.dart';
import 'package:nest/screens/details.dart';

import '../helpers/drug_helper.dart';
import '../common/common.dart';

class Tree extends StatefulWidget {
  final DrugContainer drugContainer;
  const Tree({Key? key, required this.drugContainer}) : super(key: key);
  static const routeName = "/tree";

  @override
  _TreeState createState() => _TreeState();
}

class _TreeState extends State<Tree> {
  bool _done = false;
  TreeViewController? treeController;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async => await init());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.drugContainer.name,
          overflow: TextOverflow.ellipsis,
        ),
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
        padding: const EdgeInsets.all(10),
        child: !_done
            ? const Center(child: CircularProgressIndicator())
            : Scrollbar(
                isAlwaysShown: false,
                child: TreeView(
                  controller: treeController!,
                  theme: const TreeViewTheme(),
                  // scrollController: appController.scrollController,
                  // nodeHeight: appController.nodeHeight,
                  nodeBuilder: (_, node) => InkWell(
                    onTap: () => _describeAncestors(node),
                    onDoubleTap: () {
                      _showDetails(
                        context,
                        widget.drugContainer.id!,
                        int.parse(node.id),
                        init,
                      );
                    },
                    child: const TreeNodeTile(),
                  ),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).primaryColor,
        label: const Text("ADD ROOT DRUG"),
        onPressed: () {
          _showAdd(context, widget.drugContainer.id!, init);
        },
      ),
    );
  }

  void _describeAncestors(TreeNode node) {
    final ancestors =
        node.ancestors.map((ancestor) => ancestor.label).join('/ ');

    showSnackBar(
      context,
      'Parent of "${node.label}"$ancestors',
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> init() async {
    print("calling init....................");
    final rootNode = TreeNode(id: widget.drugContainer.id!.toString());
    await generateSampleTree(rootNode, widget.drugContainer.id!);
    setState(() {
      treeController = TreeViewController(
        rootNode: rootNode,
      );
      _done = true;
    });
    treeController!.refreshNode(rootNode);
  }
}

Future<void> generateSampleTree(TreeNode parent, int id) async {
  final drugList = await DrugDb.instance.readAll(id);
  final nestList = DrugHelper.createNestedData(drugList);

  parent.addChildren(nestList);
}

void _showAdd(context, categoryId, _getDrugsFromDbAndRePopulateNodes) {
  var _data = "";
  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Enter drug name'),
      content: TextFormField(
        onChanged: (val) {
          _data = val;
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogCtx).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.of(dialogCtx).pop(true);
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
    builder: (dialogCtx) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Enter drug name'),
          IconButton(
            onPressed: () {
              Navigator.of(dialogCtx)
                  .popAndPushNamed(Details.routeName, arguments: parentId)
                  .then((value) {
                if (value == true) {
                  _getDrugsFromDbAndRePopulateNodes();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Drug deleted successfully.')));
                } else if (value == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Something went wrong.')));
                } else if (value == "true") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'This dug contains data below it. Either delete the whole category or delete drugs without childs.')));
                } else {
                  _getDrugsFromDbAndRePopulateNodes();
                }
              });
            },
            icon: const Icon(Icons.read_more_rounded),
            iconSize: 26,
            color: Colors.grey.shade600,
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
            Navigator.of(dialogCtx).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style:
              ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
          onPressed: () {
            Navigator.of(dialogCtx).pop(true);
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
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Delete category?'),
      content: const Text("All data below this category will be lost!"),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(dialogCtx).pop(false);
          },
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.red[600]),
          onPressed: () {
            Navigator.of(dialogCtx).pop(true);
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
        if (_data == null || _data == "") {
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
