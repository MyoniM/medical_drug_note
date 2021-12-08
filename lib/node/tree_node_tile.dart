import 'package:flutter/material.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';

part '_title.dart';

const RoundedRectangleBorder kRoundedRectangleBorder = RoundedRectangleBorder(
  borderRadius: BorderRadius.all(Radius.circular(12)),
);

class TreeNodeTile extends StatefulWidget {
  const TreeNodeTile({Key? key}) : super(key: key);

  @override
  _TreeNodeTileState createState() => _TreeNodeTileState();
}

class _TreeNodeTileState extends State<TreeNodeTile> {
  @override
  Widget build(BuildContext context) {
    final nodeScope = TreeNodeScope.of(context);

    return Row(
      children: [
        const LinesWidget(),
        const SizedBox(width: 4),
        const SizedBox(width: 8),
        const Expanded(child: _NodeTitle()),
        TextButton(
          onPressed: () => nodeScope.toggleExpanded(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(nodeScope.node.children.length.toString()),
              const SizedBox(width: 7),
              nodeScope.isExpanded
                  ? const Text("-", style: TextStyle(fontSize: 20))
                  : const Text("+", style: TextStyle(fontSize: 16)),
            ],
          ),
        )
      ],
    );
  }
}
