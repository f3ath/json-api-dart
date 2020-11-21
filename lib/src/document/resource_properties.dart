import 'package:json_api/src/document/many.dart';
import 'package:json_api/src/document/one.dart';
import 'package:json_api/src/document/relationship.dart';

mixin ResourceProperties {
  /// Resource meta data.
  final meta = <String, Object /*?*/ >{};

  /// Resource attributes.
  ///
  /// See https://jsonapi.org/format/#document-resource-object-attributes
  final attributes = <String, Object /*?*/ >{};

  /// Resource relationships.
  ///
  /// See https://jsonapi.org/format/#document-resource-object-relationships
  final relationships = <String, Relationship>{};

}
