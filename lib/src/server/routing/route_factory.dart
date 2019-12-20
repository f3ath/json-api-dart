import 'package:json_api/src/server/routing/route.dart';
import 'package:json_api/url_design.dart';

class RouteFactory implements MatchCase<Route> {
  const RouteFactory();

  @override
  Route unmatched() => InvalidRoute();

  @override
  Route collection(String type) => CollectionRoute(type);

  @override
  Route related(String type, String id, String relationship) =>
      RelatedRoute(type, id, relationship);

  @override
  Route relationship(String type, String id, String relationship) =>
      RelationshipRoute(type, id, relationship);

  @override
  Route resource(String type, String id) => ResourceRoute(type, id);
}
