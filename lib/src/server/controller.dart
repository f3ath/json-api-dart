import 'package:http_interop/http_interop.dart' as interop;
import 'package:json_api/routing.dart';

/// JSON:API controller
abstract class Controller {
  /// Fetch a primary resource collection
  Future<interop.Response> fetchCollection(
      interop.Request request, Target target);

  /// Create resource
  Future<interop.Response> createResource(
      interop.Request request, Target target);

  /// Fetch a single primary resource
  Future<interop.Response> fetchResource(
      interop.Request request, ResourceTarget target);

  /// Updates a primary resource
  Future<interop.Response> updateResource(
      interop.Request request, ResourceTarget target);

  /// Deletes the primary resource
  Future<interop.Response> deleteResource(
      interop.Request request, ResourceTarget target);

  /// Fetches a relationship
  Future<interop.Response> fetchRelationship(
      interop.Request rq, RelationshipTarget target);

  /// Add new entries to a to-many relationship
  Future<interop.Response> addMany(
      interop.Request request, RelationshipTarget target);

  /// Updates the relationship
  Future<interop.Response> replaceRelationship(
      interop.Request request, RelationshipTarget target);

  /// Deletes the members from the to-many relationship
  Future<interop.Response> deleteMany(
      interop.Request request, RelationshipTarget target);

  /// Fetches related resource or collection
  Future<interop.Response> fetchRelated(
      interop.Request request, RelatedTarget target);
}
