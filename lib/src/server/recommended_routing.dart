import 'package:collection/collection.dart';
import 'package:json_api/document.dart';
import 'package:json_api/src/server/routing.dart';

/// Roting according to the recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
class RecommendedRouting implements LinkFactory, RequestFactory {
  static const relationships = 'relationships';
  final Uri base;

  RecommendedRouting(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  collectionLink(String type, {Map<String, String> params}) => Link(base
      .replace(
          pathSegments: base.pathSegments + [type],
          queryParameters: nonEmpty(
              CombinedMapView([base.queryParameters, params ?? {}])))
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

  createRequest(Uri uri, String method) {
    final seg = uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionRequest(seg[0], method: method);
//      case 2:
//        return ResourceRequest(seg[0], seg[1], method: method);
//      case 3:
//        return RelatedRequest(seg[0], seg[1], seg[2], method: method);
//      case 4:
//        if (seg[2] == relationships) {
//          return RelationshipRequest(seg[0], seg[1], seg[3], method: method);
//        }
    }
    throw 'Can not parse URI: ${uri}';
  }
}

Map<K, V> nonEmpty<K, V>(Map<K, V> map) => map.isEmpty ? null : map;
