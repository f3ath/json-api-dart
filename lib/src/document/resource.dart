import 'package:json_api/src/document/identity.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_properties.dart';

class Resource with ResourceProperties, Identity {
  Resource(this.type, this.id);

  @override
  final String type;
  @override
  final String id;

  /// Resource links
  final links = <String, Link>{};

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
