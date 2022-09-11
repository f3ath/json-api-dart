import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_properties.dart';

class Resource with ResourceProperties {
  Resource(this.type, this.id);

  final String type;
  final String id;

  String get key => '$type:$id';

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
