import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/route_resolver.dart';
import 'package:json_api/src/server/uri_builder.dart';

/// Routing defines the design of URLs.
abstract class Routing implements UriBuilder, RouteResolver {}

/// StandardRouting implements the recommended URL design schema:
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

  collection(String type, {Map<String, String> params = const {}}) {
    final combined = <String, String>{}
      ..addAll(base.queryParameters)
      ..addAll(params);
    return base.replace(
        pathSegments: base.pathSegments + [type],
        queryParameters: combined.isNotEmpty ? combined : null);
  }

  related(String type, String id, String relationship,
          {Map<String, String> params = const {}}) =>
      base.replace(pathSegments: base.pathSegments + [type, id, relationship]);

  relationship(String type, String id, String relationship,
          {Map<String, String> params = const {}}) =>
      base.replace(
          pathSegments:
              base.pathSegments + [type, id, 'relationships', relationship]);

  resource(String type, String id, {Map<String, String> params = const {}}) =>
      base.replace(pathSegments: base.pathSegments + [type, id]);

  JsonApiRoute getRoute(Uri uri) {
    final segments = uri.pathSegments;
    switch (segments.length) {
      case 1:
        return CollectionRoute(segments[0]);
      case 2:
        return ResourceRoute(segments[0], segments[1]);
      case 3:
        return RelatedRoute(segments[0], segments[1], segments[2]);
      case 4:
        if (segments[2] == 'relationships') {
          return RelationshipRoute(segments[0], segments[1], segments[3]);
        }
    }
    return null; // TODO: replace with a null-object
  }
}
