import 'package:collection/collection.dart';
import 'package:json_api/src/server/request.dart';

abstract class Routing {
  Uri collection(String type, {Map<String, String> params});

  Uri resource(String type, String id);

  Uri related(String type, String id, String name);

  Uri relationship(String type, String id, String name);

  Future<JsonApiRequest> resolve(String method, Uri uri, String body);
}

/// Recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
///
/// See https://jsonapi.org/recommendations/#urls
class StandardRouting implements Routing {
  final Uri base;

  StandardRouting(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  collection(String type, {Map<String, String> params}) => base.replace(
      pathSegments: base.pathSegments + [type],
      queryParameters:
          _nonEmpty(CombinedMapView([base.queryParameters, params ?? {}])));

  related(String type, String id, String name) =>
      base.replace(pathSegments: base.pathSegments + [type, id, name]);

  relationship(String type, String id, String name) => base.replace(
      pathSegments: base.pathSegments + [type, id, 'relationships', name]);

  resource(String type, String id) =>
      base.replace(pathSegments: base.pathSegments + [type, id]);

  Future<JsonApiRequest> resolve(String method, Uri uri, String body) async {
    final seg = uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionRequest(method, seg[0],
            body: body, params: uri.queryParameters);
//      case 2:
//        return ResourceRequest(seg[0], seg[1]);
      case 3:
        return RelatedRequest(seg[0], seg[1], seg[2]);
//      case 4:
//        if (seg[2] == 'relationships') {
//          return RelationshipRequest(method, seg[0], seg[1], seg[3],
//              body: body);
//        }
    }
    return null;
  }

  Map<K, V> _nonEmpty<K, V>(Map<K, V> map) => map.isEmpty ? null : map;
}
