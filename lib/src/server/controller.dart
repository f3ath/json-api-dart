import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';

/// JSON:API controller
abstract class Controller {
  /// Fetch a primary resource collection
  Future<HttpResponse> fetchCollection(HttpRequest request, Target target);

  /// Create resource
  Future<HttpResponse> createResource(HttpRequest request, Target target);

  /// Fetch a single primary resource
  Future<HttpResponse> fetchResource(
      HttpRequest request, ResourceTarget target);

  /// Updates a primary resource
  Future<HttpResponse> updateResource(
      HttpRequest request, ResourceTarget target);

  /// Deletes the primary resource
  Future<HttpResponse> deleteResource(
      HttpRequest request, ResourceTarget target);

  /// Fetches a relationship
  Future<HttpResponse> fetchRelationship(
      HttpRequest rq, RelationshipTarget target);

  /// Add new entries to a to-many relationship
  Future<HttpResponse> addMany(HttpRequest request, RelationshipTarget target);

  /// Updates the relationship
  Future<HttpResponse> replaceRelationship(
      HttpRequest request, RelationshipTarget target);

  /// Deletes the members from the to-many relationship
  Future<HttpResponse> deleteMany(
      HttpRequest request, RelationshipTarget target);

  /// Fetches related resource or collection
  Future<HttpResponse> fetchRelated(HttpRequest request, RelatedTarget target);
}
