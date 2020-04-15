import 'package:json_api/routing.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/target.dart';

class RouteMatcher implements UriMatchHandler {
  Route route;

  @override
  void collection(String type) {
    route = CollectionRoute(CollectionTarget(type));
  }

  @override
  void related(String type, String id, String relationship) {
    route = RelatedRoute(RelationshipTarget(type, id, relationship));
  }

  @override
  void relationship(String type, String id, String relationship) {
    route = RelationshipRoute(RelationshipTarget(type, id, relationship));
  }

  @override
  void resource(String type, String id) {
    route = ResourceRoute(ResourceTarget(type, id));
  }
}
