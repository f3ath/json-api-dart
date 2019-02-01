import 'package:collection/collection.dart';
import 'package:json_api/document.dart';
import 'package:json_api/src/server/routing.dart';

/// Roting according to the recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
///
/// See https://jsonapi.org/recommendations/#urls
class RecommendedRouting implements Routing {
  static const relationships = 'relationships';
  final Uri base;

  RecommendedRouting(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  collectionLink(String type, {Map<String, String> params}) => Link(base
      .replace(
          pathSegments: base.pathSegments + [type],
          queryParameters:
              _nonEmpty(CombinedMapView([base.queryParameters, params ?? {}])))
      .toString());

  relatedLink(String type, String id, String name) => Link(base
      .replace(pathSegments: base.pathSegments + [type, id, name])
      .toString());

  relationshipLink(String type, String id, String name) => Link(base
      .replace(
          pathSegments: base.pathSegments + [type, id, relationships, name])
      .toString());

  resourceLink(String type, String id) => Link(
      base.replace(pathSegments: base.pathSegments + [type, id]).toString());

  Operation resolveOperation(Uri uri, String method) {
    if (uri.path.toString().startsWith(base.path.toString())) {
      final seg = uri.pathSegments.sublist(base.pathSegments.length);
      switch (seg.length) {
        case 1:
          return CollectionOperation(seg[0], method: method);
        case 2:
          return ResourceOperation(seg[0], seg[1], method: method);
        case 3:
          return RelatedOperation(seg[0], seg[1], seg[2], method: method);
        case 4:
          if (seg[2] == relationships) {
            return RelationshipOperation(seg[0], seg[1], seg[3],
                method: method);
          }
      }
    }
  }

  Map<K, V> _nonEmpty<K, V>(Map<K, V> map) => map.isEmpty ? null : map;
}
