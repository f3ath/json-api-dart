import 'package:http_interop/http_interop.dart' as http;
import 'package:json_api/routing.dart';

/// JSON:API controller
abstract class Controller {
  /// Fetch a primary resource collection
  Future<http.Response> fetchCollection(http.Request request, Target target);

  /// Create resource
  Future<http.Response> createResource(http.Request request, Target target);

  /// Fetch a single primary resource
  Future<http.Response> fetchResource(
      http.Request request, ResourceTarget target);

  /// Updates a primary resource
  Future<http.Response> updateResource(
      http.Request request, ResourceTarget target);

  /// Deletes the primary resource
  Future<http.Response> deleteResource(
      http.Request request, ResourceTarget target);

  /// Fetches a relationship
  Future<http.Response> fetchRelationship(
      http.Request rq, RelationshipTarget target);

  /// Add new entries to a to-many relationship
  Future<http.Response> addMany(
      http.Request request, RelationshipTarget target);

  /// Updates the relationship
  Future<http.Response> replaceRelationship(
      http.Request request, RelationshipTarget target);

  /// Deletes the members from the to-many relationship
  Future<http.Response> deleteMany(
      http.Request request, RelationshipTarget target);

  /// Fetches related resource or collection
  Future<http.Response> fetchRelated(
      http.Request request, RelatedTarget target);
}
