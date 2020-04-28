import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identity.dart';
import 'package:json_api/src/document/links.dart';
import 'package:json_api/src/document/meta.dart';
import 'package:json_api/src/document/relationship.dart';

/// Resource
///
/// Together with [Identifier] forms the core of the Document model.
/// Resources are passed between the server and the client in the form
/// of [ResourceObject]s.
class Resource with Meta, Links, Identity {
  /// Creates an instance of [Resource].
  /// The [type] can not be null.
  /// The [id] may be null for the resources to be created on the server.
  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Object> meta,
      Map<String, Link> links,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany}) {
    ArgumentError.notNull(type);
    this.attributes.addAll(attributes ?? {});
    this.meta.addAll(meta ?? {});
    this.links.addAll(links ?? {});
    toOne?.forEach((k, v) => this._toOne[k] = ToOne.fromNullable(v));
    toMany?.forEach((k, v) => this._toMany[k] = ToMany(v));
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

  /// The map of to-one relationships
  final _toOne = <String, ToOne>{};

  /// The map of to-many relationships
  final _toMany = <String, ToMany>{};

  /// All related resource identifiers.
  List<Identifier> get related => _toOne.values
      .map((_) => _.toList())
      .followedBy(_toMany.values.map((_) => _.toList()))
      .expand((_) => _)
      .toList();

  List<Identifier> relatedByKey(String key) {
    if (hasOne(key)) {
      return _toOne[key].toList();
    }
    if (hasMany(key)) {
      return _toMany[key].toList();
    }
    return [];
  }

  /// True for resources without attributes and relationships
  bool get isEmpty => attributes.isEmpty && _toOne.isEmpty && _toMany.isEmpty;

  bool hasOne(String key) => _toOne.containsKey(key);

  ToOne one(String key) =>
      _toOne[key] ?? (throw StateError('No such relationship'));

  ToMany many(String key) =>
      _toMany[key] ?? (throw StateError('No such relationship'));

  bool hasMany(String key) => _toMany.containsKey(key);

  void addAll(Resource other) {
    attributes.addAll(other.attributes);
    _toOne.addAll(other._toOne);
    _toMany.addAll(other._toMany);
  }

  Resource withId(String newId) {
    // TODO: move to NewResource()
    if (id != null) throw StateError('Should not change id');
    return Resource(type, newId, attributes: attributes)
      .._toOne.addAll(_toOne)
      .._toMany.addAll(_toMany);
  }

  Map<String, RelationshipObject> get relationships => {
        ..._toOne.map((k, v) => MapEntry(
            k, v.mapIfExists((_) => ToOneObject(_), () => ToOneObject(null)))),
        ..._toMany.map((k, v) => MapEntry(k, ToManyObject(v.toList())))
      };

  @override
  String toString() => 'Resource($key)';

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (meta.isNotEmpty) 'meta': meta,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (links.isNotEmpty) 'links': links,
      };
}

/// Resource to be created on the server. Does not have the id yet
class NewResource extends Resource {
  NewResource(String type, {Map<String, Object> attributes})
      : super(type, null, attributes: attributes);
}
