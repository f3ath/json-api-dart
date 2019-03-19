import 'dart:async';

abstract class UriBuilder {
  /// Builds a URI for a resource collection
  Uri collection(String type);

  /// Builds a URI for a single resource
  Uri resource(String type, String id);

  /// Builds a URI for a related resource
  Uri relatedResource(String type, String id, String relationship);

  /// Builds a URI for a relationship object
  Uri relationship(String type, String id, String relationship);
}

/// Route resolver detects the type of the route by [Uri]
abstract class RouteResolver {
  /// Resolves HTTP request to route object.
  /// This function should call one of the methods of the [factory] object depending on the
  /// detected route and return the result back. If the route can be matched
  /// to neither Collection, Resource, Related Resource nor Relationship,
  /// this method should return the Unmatched route.
  FutureOr<R> getRoute<R>(Uri uri, RouteFactory<R> factory);
}

abstract class RouteFactory<R> {
  /// Returns a Resource Collection route
  R collection(String type);

  /// Returns a Resource route
  R resource(String type, String id);

  /// Returns a Relationship route
  R relationship(String type, String id, String relationship);

  /// Returns a Related Resource route
  R related(String type, String id, String relationship);

  /// Returns the Unmatched route (neither of the above)
  R unmatched();
}

/// Routing defines the design of URLs.
abstract class Router implements UriBuilder, RouteResolver {}
