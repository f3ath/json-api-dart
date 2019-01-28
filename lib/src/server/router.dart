import 'dart:async';

import 'package:json_api/src/server/route.dart';

abstract class Router<Request> {
  FutureOr<Route> parse(Request request);
}

class RouterException implements Exception {
  final String message;

  RouterException(this.message);
}

class StandardRouterRequest {
  final String method;
  final Uri uri;

  StandardRouterRequest(this.method, this.uri);
}

/// A Router following the standard conventions
class StandardRouter implements Router<StandardRouterRequest> {
  @override
  parse(StandardRouterRequest rq) {
    final seg = rq.uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionRoute(seg[0], method: rq.method);
      case 2:
        return ResourceRoute(seg[0], seg[1], method: rq.method);
      case 3:
        return RelatedRoute(seg[0], seg[1], seg[2], method: rq.method);
      case 4:
        if (seg[2] == 'relationships') {
          return RelationshipRoute(seg[0], seg[1], seg[3], method: rq.method);
        }
    }
    throw RouterException('Can not parse URI: ${rq.uri}');
  }
}
