import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

abstract class Controller<T> {
  /// Fetch a primary resource collection
  Future<T> fetchCollection(HttpRequest request, CollectionTarget target);

  /// Create resource
  Future<T> createResource(HttpRequest request, CollectionTarget target);

  /// Fetch a single primary resource
  Future<T> fetchResource(HttpRequest request, ResourceTarget target);

  /// Updates a primary resource
  Future<T> updateResource(HttpRequest request, ResourceTarget target);

  /// Deletes the primary resource
  Future<T> deleteResource(HttpRequest request, ResourceTarget target);

  /// Fetches a relationship
  Future<T> fetchRelationship(HttpRequest rq, RelationshipTarget target);

  /// Add new entries to a to-many relationship
  Future<T> addMany(HttpRequest request, RelationshipTarget target);

  /// Updates the relationship
  Future<T> replaceRelationship(HttpRequest request, RelationshipTarget target);

  /// Deletes the members from the to-many relationship
  Future<T> deleteMany(HttpRequest request, RelationshipTarget target);

  /// Fetches related resource or collection
  Future<T> fetchRelated(HttpRequest request, RelatedTarget target);
}
