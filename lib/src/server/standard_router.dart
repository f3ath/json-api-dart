import 'package:json_api/src/server/contracts/router.dart';

/// StandardRouting implements the recommended URL design schema:
///
/// /photos - for a collection
/// /photos/1 - for a resource
/// /photos/1/relationships/author - for a relationship
/// /photos/1/author - for a related resource
///
/// See https://jsonapi.org/recommendations/#urls
class StandardRouter implements Router {
  final Uri base;

  StandardRouter(this.base) {
    ArgumentError.checkNotNull(base, 'base');
  }

  Uri collection(String type) => _path([type]);

  Uri relatedResource(String type, String id, String relationship) =>
      _path([type, id, relationship]);

  Uri relationship(String type, String id, String relationship) =>
      _path([type, id, 'relationships', relationship]);

  Uri resource(String type, String id) => _path([type, id]);

  R getRoute<R>(Uri uri, RouteFactory<R> route) {
    final _ = uri.pathSegments;
    switch (_.length) {
      case 1:
        return route.collection(_[0]);
      case 2:
        return route.resource(_[0], _[1]);
      case 3:
        return route.related(_[0], _[1], _[2]);
      case 4:
        if (_[2] == 'relationships') {
          return route.relationship(_[0], _[1], _[3]);
        }
    }
    return route.unmatched();
  }

  Uri _path(List<String> segments) =>
      base.replace(pathSegments: base.pathSegments + segments);
}
