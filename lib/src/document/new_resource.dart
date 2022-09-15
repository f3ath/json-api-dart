import 'package:json_api/src/document/resource_properties.dart';

/// A set of properties for a to-be-created resource which does not have the id yet.
class NewResource with ResourceProperties {
  NewResource(this.type, {this.id, this.lid});

  /// Resource type
  final String type;

  /// Resource id.
  final String? id;

  /// Local resource id.
  final String? lid;

  Map<String, Object> toJson() => {
        'type': type,
        if (id != null) 'id': id!,
        if (lid != null) 'lid': lid!,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
