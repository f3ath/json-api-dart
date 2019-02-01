import 'package:collection/collection.dart';
import 'package:json_api/document.dart';

abstract class Links {
  Link collection(String type, {Map<String, String> params});

  Link resource(String type, String id);

  Link related(String type, String id, String name);

  Link relationship(String type, String id, String name);
}

/// Recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
///
/// See https://jsonapi.org/recommendations/#urls
class StandardLinks implements Links {
  final Uri base;

  StandardLinks(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  collection(String type, {Map<String, String> params}) => Link(base
      .replace(
          pathSegments: base.pathSegments + [type],
          queryParameters:
              _nonEmpty(CombinedMapView([base.queryParameters, params ?? {}])))
      .toString());

  related(String type, String id, String name) => Link(base
      .replace(pathSegments: base.pathSegments + [type, id, name])
      .toString());

  relationship(String type, String id, String name) => Link(base
      .replace(
          pathSegments: base.pathSegments + [type, id, 'relationships', name])
      .toString());

  resource(String type, String id) => Link(
      base.replace(pathSegments: base.pathSegments + [type, id]).toString());

  Map<K, V> _nonEmpty<K, V>(Map<K, V> map) => map.isEmpty ? null : map;
}
