import 'package:json_api/src/server/routing/collection_route.dart';
import 'package:json_api/src/server/routing/invalid_route.dart';
import 'package:json_api/src/server/routing/related_route.dart';
import 'package:json_api/src/server/routing/relationship_route.dart';
import 'package:json_api/src/server/routing/resource_route.dart';
import 'package:json_api/src/server/routing/route.dart';
import 'package:json_api/url_design.dart';

class RouteMapper implements TargetMapper<Route> {
  const RouteMapper();

  @override
  collection(CollectionTarget target) => CollectionRoute(target);

  @override
  related(RelationshipTarget target) => RelatedRoute(target);

  @override
  relationship(RelationshipTarget target) => RelationshipRoute(target);

  @override
  resource(ResourceTarget target) => ResourceRoute(target);

  @override
  unmatched() => InvalidRoute();
}
