class CollectionTarget {
  final String type;

  const CollectionTarget(this.type);

  @override
  bool operator ==(other) => other is CollectionTarget && other.type == type;
}
