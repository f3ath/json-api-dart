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

  Uri collection(String type, {Map<String, String> parameters = const {}}) {
    final combined = <String, String>{}
      ..addAll(base.queryParameters)
      ..addAll(parameters);
    return base.replace(
        pathSegments: base.pathSegments + [type],
        queryParameters: combined.isNotEmpty ? combined : null);
  }

  Uri related(String type, String id, String relationship,
          {Map<String, String> parameters = const {}}) =>
      base.replace(pathSegments: base.pathSegments + [type, id, relationship]);

  Uri relationship(String type, String id, String relationship,
          {Map<String, String> parameters = const {}}) =>
      base.replace(
          pathSegments:
              base.pathSegments + [type, id, 'relationships', relationship]);

  Uri resource(String type, String id,
          {Map<String, String> parameters = const {}}) =>
      base.replace(pathSegments: base.pathSegments + [type, id]);

  R getRoute<R>(Uri uri, RouteFactory<R> route) {
    final segments = uri.pathSegments;
    switch (segments.length) {
      case 1:
        return route.collection(segments[0]);
      case 2:
        return route.resource(segments[0], segments[1]);
      case 3:
        return route.related(segments[0], segments[1], segments[2]);
      case 4:
        if (segments[2] == 'relationships') {
          return route.relationship(segments[0], segments[1], segments[3]);
        }
    }
    return route.unmatched();
  }
}
