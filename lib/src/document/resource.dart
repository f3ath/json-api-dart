import 'package:json_api/core.dart';
import 'package:json_api/document.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_properties.dart';

class Resource with ResourceProperties {
  Resource(this.ref);

  final Ref ref;

  /// Resource links
  final links = <String, Link>{};

  Map<String, Object> toJson() => {
        'type': ref.type,
        'id': ref.id,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };
}
