import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/document/resource_object.dart';

/// Represents a single resource or a single related resource of a to-one relationship\\\\\\\\
class ResourceData extends PrimaryData {
  final ResourceObject resourceObject;

  /// For Compound Documents this member contains the included resources
  final List<ResourceObject> included;

  ResourceData(this.resourceObject,
      {Link self, Iterable<ResourceObject> included})
      : this.included =
            (included == null || included.isEmpty ? null : List.from(included)),
        super(self: self);

  @override
  Map<String, Object> toJson() {
    final json = <String, Object>{'data': resourceObject};
    if (included != null && included.isNotEmpty) {
      json['included'] = included;
    }

    final links = toLinks();
    if (links.isNotEmpty) json['links'] = links;
    return json;
  }

  Resource toResource() => resourceObject.toResource();
}
