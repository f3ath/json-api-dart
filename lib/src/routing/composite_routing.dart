import 'package:json_api/src/routing/route_matcher.dart';
import 'package:json_api/src/routing/routes.dart';
import 'package:json_api/src/routing/routing.dart';

/// URI design composed of independent routes.
class CompositeRouting implements Routing {
  CompositeRouting(this.collectionRoute, this.resourceRoute, this.relatedRoute,
      this.relationshipRoute);

  final CollectionRoute collectionRoute;
  final ResourceRoute resourceRoute;
  final RelatedRoute relatedRoute;
  final RelationshipRoute relationshipRoute;

  @override
  Uri collection(String type) => collectionRoute.uri(type);

  @override
  Uri related(String type, String id, String relationship) =>
      relatedRoute.uri(type, id, relationship);

  @override
  Uri relationship(String type, String id, String relationship) =>
      relationshipRoute.uri(type, id, relationship);

  @override
  Uri resource(String type, String id) => resourceRoute.uri(type, id);

  @override
  bool match(Uri uri, MatchHandler handler) =>
      collectionRoute.match(uri, handler.collection) ||
      resourceRoute.match(uri, handler.resource) ||
      relatedRoute.match(uri, handler.related) ||
      relationshipRoute.match(uri, handler.relationship);
}
