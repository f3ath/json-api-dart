import 'package:json_api/src/routing/path_based_routing.dart';

abstract class RouteBuilder {
  /// Returns a URL for the primary resource collection of type [type]
  Uri collection(String type);

  /// Returns a URL for the related resource/collection.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri related(String type, String id, String relationship);

  /// Returns a URL for the relationship itself.
  /// The [type] and [id] identify the primary resource and the [relationship]
  /// is the relationship name.
  Uri relationship(String type, String id, String relationship);

  /// Returns a URL for the primary resource of type [type] with id [id]
  Uri resource(String type, String id);
}

abstract class RouteMatcher {
  /// Matches the target of the [uri]. If the target can be determined,
  /// the corresponding callback will be called with the target parameters.
  void match(Uri uri,
      {onCollection(String type),
      onResource(String type, String id),
      onRelationship(String type, String id, String relationship),
      onRelated(String type, String id, String relationship)});
}

abstract class Routing implements RouteMatcher, RouteBuilder {
  factory Routing(Uri base) => PathBasedRouting(base);
}
