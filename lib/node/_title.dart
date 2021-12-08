part of 'tree_node_tile.dart';

class _NodeTitle extends StatelessWidget {
  const _NodeTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nodeScope = TreeNodeScope.of(context);

    return Text(
      nodeScope.node.label,
      style: TextStyle(fontSize: 16, color: nodeScope.node.data as Color),
      overflow: TextOverflow.ellipsis,
    );
  }
}
