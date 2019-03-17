import 'package:json_api/src/server/route_resolver.dart';
import 'package:json_api/src/server/standard_routing.dart';
import 'package:json_api/src/server/uri_builder.dart';

/// Routing defines the design of URLs.
abstract class Routing implements UriBuilder, RouteResolver {
  factory Routing(Uri base) {
    return StandardRouting(base);
  }
}
