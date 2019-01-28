import 'dart:async';

import 'package:json_api/src/server/route.dart';

abstract class Controller<Request, Response> {
  FutureOr<Response> fetchCollection(CollectionRoute route, Request request);

  FutureOr<Response> fetchResource(ResourceRoute r, Request request);

  FutureOr<Response> fetchRelated(RelatedRoute r, Request request);

  FutureOr<Response> fetchRelationship(RelationshipRoute r, Request request);
}
