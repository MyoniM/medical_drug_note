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
              if (val == 2) {
                treeController!.collapseAll();
              }
              if (val == 3) {
                treeController!.expandAll();
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
              const PopupMenuItem(
                child: Text("Collapse all"),
                value: 2,
              ),
              const PopupMenuItem(
                child: Text("Expand all"),
                value: 3,
              ),
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: !_done
            ? const Center(child: CircularProgressIndicator())
            : Scrollbar(
                isAlwaysShown: false,
                child: TreeView(
                  controller: treeController!,
                  theme: const TreeViewTheme(lineThickness: .5, indent: 15),
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
        label: const Text("ADD ROOT CLASS"),
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
      'Parent of "${node.label}": $ancestors',
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
    treeController!.expandAll();
  }
}

Future<void> generateSampleTree(TreeNode parent, int id) async {
  final drugList = await DrugDb.instance.readAll(id);
  final nestList = DrugHelper.createNestedData(drugList);

  parent.addChildren(nestList);
}

void _showAdd(context, categoryId, _getDrugsFromDbAndRePopulateNodes) {
  var _data = "";
  int x = Colors.black.value;
  setX(y) {
    x = y;
  }

  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Enter class name'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorPicker(x, setX),
          TextFormField(
            onChanged: (val) {
              _data = val;
            },
          ),
        ],
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
              content: Text('Class name is neccessary!'),
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
              clr: x,
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
  int x = Colors.black.value;
  setX(y) {
    x = y;
  }

  showDialog(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Enter class name'),
          IconButton(
            onPressed: () {
              Navigator.of(dialogCtx)
                  .popAndPushNamed(Details.routeName, arguments: parentId)
                  .then((value) {
                if (value == true) {
                  _getDrugsFromDbAndRePopulateNodes();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Class deleted successfully.')));
                } else if (value == false) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Something went wrong.')));
                } else if (value == "true") {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'This class contains data below it. Either delete the whole category or delete classes without childs.')));
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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorPicker(x, setX),
          TextFormField(
            onChanged: (val) {
              _data = val;
            },
          ),
        ],
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
              const SnackBar(content: Text('Class name is neccessary!')));
        } else {
          DrugDb.instance.create(
            Drug(
              name: _data,
              description: "",
              categoryId: categoryId,
              parentId: parentId,
              createdAt: DateTime.now().toIso8601String(),
              clr: x,
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

class ColorPicker extends StatefulWidget {
  const ColorPicker(
    this.clr,
    this.onC, {
    Key? key,
  }) : super(key: key);

  final int clr;
  final Function onC;
  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  var _value = Colors.black.value;
  onChange(value) {
    widget.onC(value);
    setState(() {
      _value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        clr(Colors.black, Colors.black.value, _value, onChange),
        clr(Colors.orange, Colors.orange.value, _value, onChange),
        clr(Colors.green, Colors.green.value, _value, onChange),
        clr(Colors.blue, Colors.blue.value, _value, onChange),
        clr(Colors.red, Colors.red.value, _value, onChange),
      ],
    );
  }
}

class clr extends StatefulWidget {
  clr(this.color, this.value, this.groupValue, this.onChanged, {Key? key});
  final Color color;
  final int value;
  final int groupValue;
  final Function onChanged;

  @override
  State<clr> createState() => _clrState();
}

class _clrState extends State<clr> {
  @override
  Widget build(BuildContext context) {
    bool _selected = widget.value == widget.groupValue;
    return InkWell(
      onTap: () => widget.onChanged(widget.value),
      child: Container(
        width: MediaQuery.of(context).size.width * .112,
        height: 30,
        child: _selected
            ? const Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              )
            : null,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
