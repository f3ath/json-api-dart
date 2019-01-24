/// Resource Identifier object
///
/// https://jsonapi.org/format/#document-resource-identifier-objects
class Identifier {
  final String type;
  final String id;

  Identifier(this.type, this.id) {
    if (type == null) throw ArgumentError.notNull('type');
    if (id == null) throw ArgumentError.notNull('id');
  }

  Identifier.of(Resource r) : this(r.type, r.id);

  bool identifies(Resource r) => r.type == type && r.id == id;
}

/// Resource object
///
/// https://jsonapi.org/format/#document-resource-objects
class Resource {
  final String type;
  final String id;
  final Map<String, Object> attributes;
  final Map<String, Identifier> toOne;
  final Map<String, List<Identifier>> toMany;

  Resource(this.type, this.id,
      {Map<String, Object> attributes = const {},
      Map<String, Identifier> toOne = const {},
      Map<String, List<Identifier>> toMany = const {}})
      : attributes = Map.unmodifiable(attributes),
        toOne = Map.unmodifiable(toOne),
        toMany = Map.unmodifiable(Map.fromIterables(toMany.keys,
            toMany.values.map((_) => List<Identifier>.unmodifiable(_)))) {
    if (type == null) throw ArgumentError.notNull('type');
    final fields = Set<String>.from(['type', 'id']);
    final unique =
        [attributes, toOne, toMany].every((_) => _.keys.every(fields.add));
    if (!unique) throw ArgumentError('Fields must be unique.');
  }
}
