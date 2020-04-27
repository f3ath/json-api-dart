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
    toOne?.forEach((k, v) => this.toOne[k] = ToOne.fromNullable(v));
    toMany?.forEach((k, v) => this.toMany[k] = ToMany(v));
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
  final toOne = <String, ToOne>{};

  /// The map of to-many relationships
  final toMany = <String, ToMany>{};

  /// All related resource identifiers.
  List<Identifier> get related => toOne.values
      .map((_) => _.toList())
      .followedBy(toMany.values.map((_) => _.toList()))
      .expand((_) => _)
      .toList();

  List<Identifier> relatedByKey(String key) {
    if (hasOne(key)) {
      return toOne[key].toList();
    }
    if (hasMany(key)) {
      return toMany[key].toList();
    }
    return [];
  }

  /// True for resources without attributes and relationships
  bool get isEmpty => attributes.isEmpty && toOne.isEmpty && toMany.isEmpty;

  bool hasOne(String key) => toOne.containsKey(key);

  bool hasMany(String key) => toMany.containsKey(key);

  void addAll(Resource other) {
    attributes.addAll(other.attributes);
    toOne.addAll(other.toOne);
    toMany.addAll(other.toMany);
  }

  Resource withId(String newId) {
    // TODO: move to NewResource()
    if (id != null) throw StateError('Should not change id');
    return Resource(type, newId, attributes: attributes)
      ..toOne.addAll(toOne)
      ..toMany.addAll(toMany);
  }

  Map<String, RelationshipObject> get relationships => {
        ...toOne.map((k, v) => MapEntry(
            k, v.mapIfExists((_) => ToOneObject(_), () => ToOneObject(null)))),
        ...toMany.map((k, v) => MapEntry(k, ToManyObject(v.toList())))
      };

  @override
  String toString() => 'Resource($key)';
}

/// Resource to be created on the server. Does not have the id yet
class NewResource extends Resource {
  NewResource(String type, {Map<String, Object> attributes})
      : super(type, null, attributes: attributes);
}
