import 'package:json_api/src/document/new_identifier.dart';
import 'package:json_api/src/document/new_relationship.dart';
import 'package:json_api/src/document/new_to_many.dart';
import 'package:json_api/src/document/new_to_one.dart';
import 'package:json_api/src/document/relationship.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/to_many.dart';
import 'package:json_api/src/document/to_one.dart';

/// A set of properties for a to-be-created resource which does not have the id yet.
class NewResource {
  NewResource(this.type, {this.id, this.lid});

  /// Resource type
  final String type;

  /// Resource id.
  final String? id;

  /// Local resource id.
  final String? lid;

  /// Resource meta data.
  final meta = <String, Object?>{};

  /// Resource attributes.
  ///
  /// See https://jsonapi.org/format/#document-resource-object-attributes
  final attributes = <String, Object?>{};

  /// Resource relationships.
  ///
  /// See https://jsonapi.org/format/#document-resource-object-relationships
  final relationships = <String, NewRelationship>{};

  Map<String, Object> toJson() => {
        'type': type,
        if (id != null) 'id': id!,
        if (lid != null) 'lid': lid!,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };

  /// Converts this to a real [Resource] object, assigning the id if necessary.
  Resource toResource(String Function() getId) {
    final resource = Resource(type, id ?? getId());
    resource.attributes.addAll(attributes);
    resource.relationships.addAll(_toRelationships(resource.id));
    resource.meta.addAll(meta);
    return resource;
  }

  Map<String, Relationship> _toRelationships(String id) => relationships
      .map((k, v) => MapEntry(k, _toRelationship(v, id)..meta.addAll(v.meta)));

  Relationship _toRelationship(NewRelationship r, String id) {
    if (r is NewToOne) {
      return ToOne(_toIdentifierOrNull(r.identifier, id));
    }
    if (r is NewToMany) {
      return ToMany(r.map((identifier) => _toIdentifier(identifier, id)));
    }
    throw StateError('Unexpected relationship type: ${r.runtimeType}');
  }

  Identifier? _toIdentifierOrNull(NewIdentifier? identifier, String id) {
    if (identifier == null) return null;
    return _toIdentifier(identifier, id);
  }

  Identifier _toIdentifier(NewIdentifier identifier, String id) {
    switch (identifier) {
      case Identifier():
        return identifier;
      case LocalIdentifier():
        if (identifier.type == type && identifier.lid == lid) {
          return identifier.toIdentifier(id);
        }
        throw StateError(
            'Unmatched local id: "${identifier.lid}". Expected "$lid".');
    }
  }
}
