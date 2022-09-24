import 'package:json_api/src/document/relationship.dart';
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
  final relationships = <String, Relationship>{};

  Map<String, Object> toJson() => {
        'type': type,
        if (id != null) 'id': id!,
        if (lid != null) 'lid': lid!,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };

  /// Converts this to a real [Resource] object, assigning the id if necessary.
  Resource toResource(String Function() getId) => Resource(type, id ?? getId())
    ..attributes.addAll(attributes)
    ..relationships.addAll(relationships)
    ..meta.addAll(meta);
}
