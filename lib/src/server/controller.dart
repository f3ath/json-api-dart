import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

abstract class JsonApiController<T> {
  /// Fetch a primary resource collection
  T fetchCollection(HttpRequest request, CollectionTarget target);

  /// Create resource
  T createResource(HttpRequest request, CollectionTarget target);

  /// Fetch a single primary resource
  T fetchResource(HttpRequest request, ResourceTarget target);

  /// Updates a primary resource
  T updateResource(HttpRequest request, ResourceTarget target);

  /// Deletes the primary resource
  T deleteResource(HttpRequest request, ResourceTarget target);

  /// Fetches a relationship
  T fetchRelationship(HttpRequest rq, RelationshipTarget target );

  /// Add new entries to a to-many relationship
  T addMany(HttpRequest request, RelationshipTarget target);

  /// Updates the relationship
  T replaceRelationship(HttpRequest request, RelationshipTarget target);

  /// Deletes the members from the to-many relationship
  T deleteMany(HttpRequest request, RelationshipTarget target);
}
