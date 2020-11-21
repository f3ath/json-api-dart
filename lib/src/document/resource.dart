import 'package:json_api/document.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/identity.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_properties.dart';

class Resource with ResourceProperties, Identity {
  Resource(this.type, this.id) {
    ArgumentError.checkNotNull(type);
    ArgumentError.checkNotNull(id);
  }

  @override
  final String type;

  @override
  final String id;

  /// Resource links
  final links = <String, Link>{};

  /// Converts the resource to its identifier
  Identifier toIdentifier() => Identifier(type, id);

  /// Returns a to-one relationship by its [name].
  /// Throws [StateError] if the relationship does not exist.
  /// Throws [StateError] if the relationship is not a to-one.
  One one(String name) => _rel<One>(name);

  /// Returns a to-many relationship by its [name].
  /// Throws [StateError] if the relationship does not exist.
  /// Throws [StateError] if the relationship is not a to-many.
  Many many(String name) => _rel<Many>(name);

  Map<String, Object> toJson() => {
        'type': type,
        'id': id,
        if (attributes.isNotEmpty) 'attributes': attributes,
        if (relationships.isNotEmpty) 'relationships': relationships,
        if (links.isNotEmpty) 'links': links,
        if (meta.isNotEmpty) 'meta': meta,
      };

  /// Returns a typed relationship by its [name].
  /// Throws [StateError] if the relationship does not exist.
  /// Throws [StateError] if the relationship is not of the given type.
  R _rel<R extends Relationship>(String name) {
    final r = relationships[name];
    if (r is R) return r;
    throw StateError(
        'Relationship $name (${r.runtimeType}) is not of type ${R}');
  }
}
