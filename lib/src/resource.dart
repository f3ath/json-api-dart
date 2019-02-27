import 'package:json_api/src/identifier.dart';

/// The core of the Resource object
/// https://jsonapi.org/format/#document-resource-objects
class Resource {
  /// Resource type
  final String type;

  /// Resource id
  ///
  /// May be null for resources to be created on the cars_server
  final String id;

  /// Resource attributes
  final attributes = <String, Object>{};

  /// to-one relationships
  final toOne = <String, Identifier>{};

  /// to-many relationships
  final toMany = <String, List<Identifier>>{};

  Resource(this.type, this.id,
      {Map<String, Object> attributes,
      Map<String, Identifier> toOne,
      Map<String, List<Identifier>> toMany}) {
    ArgumentError.checkNotNull(type, 'type');
    this.attributes.addAll(attributes ?? {});
    this.toOne.addAll(toOne ?? {});
    this.toMany.addAll(toMany ?? {});
  }
}
