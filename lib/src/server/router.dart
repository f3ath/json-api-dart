import 'package:json_api/src/server/request_target.dart';

/// URL Design defines the design of URLs used by the server.
/// It works both ways:
/// - Creates a URL for a given [RequestTarget]
/// - Detects the target of a request by its URL
abstract class URLDesign {
  /// Builds a URL for a resource collection
  Uri collection(CollectionTarget target);

  /// Builds a URL for a single resource
  Uri resource(ResourceTarget target);

  /// Builds a URL for a related resource
  Uri related(RelatedTarget target);

  /// Builds a URL for a relationship object
  Uri relationship(RelationshipTarget target);

  /// This function must return either:
  /// - [CollectionTarget]
  /// - [ResourceTarget]
  /// - [RelationshipTarget]
  /// - [RelatedTarget]
  /// - null if the target can not be determined
  RequestTarget getTarget(Uri uri);
}
