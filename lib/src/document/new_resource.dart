import 'package:json_api/document.dart';
import 'package:json_api/src/document/local_identifier.dart';
import 'package:json_api/src/document/new_relationship.dart';
import 'package:json_api/src/document/resource.dart';

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

  Map<String, Object> toJson() =>
      {
        'type': type,
        if (id != null) 'id': id!,
        if (lid != null) 'lid': lid!,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };

  /// Converts this to a real [Resource] object, assigning the id if necessary.
  Resource toResource(String Function() getId) {
    final resourceId = id ?? getId();
    return Resource(type, resourceId)
      ..attributes.addAll(attributes)
      ..relationships.addAll(
          relationships.map((key, value) =>
              MapEntry(
                  key, _toReal(value, type, lid ?? resourceId, resourceId))))
      ..meta.addAll(meta);
  }

  Relationship _toReal(NewRelationship r, String type, String lid, String id) {
    if (r is NewToOne) {
      return ToOne(_toIdentifier(r.identifier, type, lid, id))
        ..meta.addAll(meta);
    }
    if (r is NewToMany) {
      return ToMany(r.map((identifier) {
        if (identifier is Identifier) return identifier;
        if (identifier is LocalIdentifier) {
          if (identifier.type == type && identifier.lid == lid) {
            return identifier.toIdentifier(id);
          }
          throw StateError('Unexpected local id: ${identifier.lid}');
        }
        throw StateError(
            'Unexpected implementation: ${identifier.runtimeType}');
      }));
    }
    throw StateError('Unexpected relationship type: ${r.runtimeType}');
  }

  Identifier? _toIdentifier(NewIdentifier? identifier, String  type, String lid, String id) {
    if (identifier == null) return null;
    if (identifier is Identifier) return identifier;
    if (identifier is LocalIdentifier) {
      if (identifier.type == type && identifier.lid == lid) {
        return identifier.toIdentifier(id);
      }
      throw StateError('Unexpected local id: ${identifier.lid}');
    }
    throw StateError('Unexpected implementation: ${identifier.runtimeType}');
  }
}
