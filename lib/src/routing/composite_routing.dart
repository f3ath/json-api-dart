import 'package:json_api/src/routing/collection_route.dart';
import 'package:json_api/src/routing/relationship_route.dart';
import 'package:json_api/src/routing/resource_route.dart';
import 'package:json_api/src/routing/routing.dart';

class CompositeRouting implements Routing {
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

  CompositeRouting(this.collectionRoute, this.resourceRoute, this.relatedRoute,
      this.relationshipRoute);

  final CollectionRoute collectionRoute;
  final ResourceRoute resourceRoute;
  final RelationshipRoute relatedRoute;
  final RelationshipRoute relationshipRoute;

  @override
  bool matchCollection(Uri uri, void Function(String type) onMatch) =>
      collectionRoute.match(uri, onMatch);

  @override
  bool matchRelated(Uri uri,
          void Function(String type, String id, String relationship) onMatch) =>
      relatedRoute.match(uri, onMatch);

  @override
  bool matchRelationship(Uri uri,
          void Function(String type, String id, String relationship) onMatch) =>
      relationshipRoute.match(uri, onMatch);

  @override
  bool matchResource(Uri uri, void Function(String type, String id) onMatch) =>
      resourceRoute.match(uri, onMatch);
}
