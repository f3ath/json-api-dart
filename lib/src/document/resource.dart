import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identity.dart';

/// Resource
///
/// Together with [Identifier] forms the core of the Document model.
/// Resources are passed between the server and the client in the form
/// of [ResourceObject]s.
class Resource with Identity {
  /// Creates an instance of [Resource].
  /// The [type] can not be null.
  /// The [id] may be null for the resources to be created on the server.
  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany})
      : toOne = Map.unmodifiable(toOne ?? const {}),
        toMany = Map.unmodifiable(
            (toMany ?? {}).map((k, v) => MapEntry(k, Set.of(v).toList()))) {
    ArgumentError.notNull(type);
    this.attributes.addAll(attributes ?? {});
  }

  /// Resource type
  @override
  final String type;

  /// Resource id
  ///
  /// May be null for resources to be created on the server
  @override
  final String id;

  /// The map of attributes
  final attributes = <String, Object>{};

  /// Unmodifiable map of to-one relationships
  final Map<String, Identifier> toOne;

  /// Unmodifiable map of to-many relationships
  final Map<String, List<Identifier>> toMany;

  /// All related resource identifiers.
  Iterable<Identifier> get related =>
      toOne.values.followedBy(toMany.values.expand((_) => _));

  /// True for resources without attributes and relationships
  bool get isEmpty => attributes.isEmpty && toOne.isEmpty && toMany.isEmpty;

  bool hasOne(String key) => toOne.containsKey(key);

  bool hasMany(String key) => toMany.containsKey(key);

  Resource withId(String newId) {
    // TODO: move to NewResource()
    if (id != null) throw StateError('Should not change id');
    return Resource(type, newId,
        attributes: attributes, toOne: toOne, toMany: toMany);
  }

  @override
  String toString() => 'Resource($key)';
}

/// Resource to be created on the server. Does not have the id yet
class NewResource extends Resource {
  NewResource(String type,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany})
      : super(type, null, attributes: attributes, toOne: toOne, toMany: toMany);
}
