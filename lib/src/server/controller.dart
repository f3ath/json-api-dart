import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';

/// JSON:API controller
abstract class Controller {
  /// Fetch a primary resource collection
  Future<Response> fetchCollection(Request request, Target target);

  /// Create resource
  Future<Response> createResource(Request request, Target target);

  /// Fetch a single primary resource
  Future<Response> fetchResource(Request request, ResourceTarget target);

  /// Updates a primary resource
  Future<Response> updateResource(Request request, ResourceTarget target);

  /// Deletes the primary resource
  Future<Response> deleteResource(Request request, ResourceTarget target);

  /// Fetches a relationship
  Future<Response> fetchRelationship(Request rq, RelationshipTarget target);

  /// Add new entries to a to-many relationship
  Future<Response> addMany(Request request, RelationshipTarget target);

  /// Updates the relationship
  Future<Response> replaceRelationship(
      Request request, RelationshipTarget target);

  /// Deletes the members from the to-many relationship
  Future<Response> deleteMany(Request request, RelationshipTarget target);

  /// Fetches related resource or collection
  Future<Response> fetchRelated(Request request, RelatedTarget target);
}
