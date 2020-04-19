import 'package:json_api/routing.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/target.dart';

class RouteMatcher implements UriMatchHandler {
  Route _match;

  @override
  void collection(String type) {
    _match = CollectionRoute(CollectionTarget(type));
  }

  @override
  void related(String type, String id, String relationship) {
    _match = RelatedRoute(RelationshipTarget(type, id, relationship));
  }

  @override
  void relationship(String type, String id, String relationship) {
    _match = RelationshipRoute(RelationshipTarget(type, id, relationship));
  }

  @override
  void resource(String type, String id) {
    _match = ResourceRoute(ResourceTarget(type, id));
  }

  Route getMatchedRouteOrElse(Route Function() orElse) => _match ?? orElse();
}
