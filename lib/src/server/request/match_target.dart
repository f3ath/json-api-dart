import 'package:json_api/src/routing/routing.dart';
import 'package:json_api/src/server/request/target.dart';

RequestTarget matchTarget(RouteMatcher matcher, Uri uri) {
  RequestTarget target = InvalidTarget();
  matcher.match(
    uri,
    onCollection: (type) => target = CollectionTarget(type),
    onResource: (type, id) => target = ResourceTarget(type, id),
    onRelationship: (type, id, relationship) =>
        target = RelationshipTarget(type, id, relationship),
    onRelated: (type, id, relationship) =>
        target = RelatedTarget(type, id, relationship),
  );
  return target;
}
