/// Relationship tree node
class RelationshipNode {
  RelationshipNode(this.name);

  static Iterable<RelationshipNode> forest(Iterable<String> relationships) {
    final root = RelationshipNode('');
    relationships
        .map((rel) => rel.trim().split('.').map((e) => e.trim()))
        .forEach(root.add);
    return root.children;
  }

  /// The name of the relationship
  final String name;

  Iterable<RelationshipNode> get children => _map.values;

  final _map = <String, RelationshipNode>{};

  /// Adds the chain to the tree
  void add(Iterable<String> chain) {
    if (chain.isEmpty) return;
    final key = chain.first;
    _map[key] = (_map[key] ?? RelationshipNode(key))..add(chain.skip(1));
  }
}
