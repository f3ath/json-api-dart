import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/many.dart';
import 'package:json_api/src/document/one.dart';
import 'package:json_api/src/document/relationship.dart';

class Resource {
  Resource(this.type, this.id);

  /// Resource type.
  final String type;

  /// Resource id.
  final String id;

  /// Resource links
  final links = <String, Link>{};

  /// Resource meta data.
  final meta = <String, Object?>{};

  /// Resource attributes.
  ///
  /// See https://jsonapi.org/format/#document-resource-object-attributes
  final attributes = <String, Object?>{};

  /// Resource relationships.
  ///
  /// See https://jsonapi.org/format/#document-resource-object-relationships
  final relationships = <String, Relationship>{};

  /// Returns a to-one relationship by its [name].
  ToOne? one(String name) => _rel<ToOne>(name);

  /// Returns a to-many relationship by its [name].
  ToMany? many(String name) => _rel<ToMany>(name);

  /// Returns a typed relationship by its [name].
  R? _rel<R extends Relationship>(String name) {
    final r = relationships[name];
    if (r is R) return r;
    return null;
  }

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
