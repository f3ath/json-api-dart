import 'package:json_api/src/server/route.dart';

abstract class RouteResolver {
  /// Resolves HTTP request to [JsonAiRequest] object
  JsonApiRoute getRoute(Uri uri);
}
