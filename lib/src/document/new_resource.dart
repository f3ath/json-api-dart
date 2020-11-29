import 'package:json_api/src/document/resource_properties.dart';

/// A set of properties for a to-be-created resource which does not have the id yet.
class NewResource with ResourceProperties {
  NewResource(this.type, [this.id]) {
    ArgumentError.checkNotNull(type);
  }

  /// Resource type
  final String type;

  /// Nullable. Resource id.
  final String? id;

  Map<String, Object> toJson() => {
        'type': type,
        if (id != null) 'id': id!,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
