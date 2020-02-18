import 'dart:async';

import 'package:json_api/http.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/target.dart';

/// The Controller consolidates all possible requests a JSON:API server
/// may handle. Each of the methods is expected to return a
/// [JsonApiResponse] object or a [Future] of it.
///
/// The response may either be a successful or an error.
abstract class JsonApiController {
  /// Finds an returns a primary resource collection.
  /// Use [JsonApiResponse.collection] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the collection does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchCollection(
      HttpRequest request, CollectionTarget target);

  /// Finds an returns a primary resource.
  /// Use [JsonApiResponse.resource] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchResource(
      HttpRequest request, ResourceTarget target);

  /// Finds an returns a related resource or a collection of related resources.
  /// Use [JsonApiResponse.relatedResource] or [JsonApiResponse.relatedCollection] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource or the relationship does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchRelated(
      HttpRequest request, RelatedTarget target);

  /// Finds an returns a relationship of a primary resource.
  /// Use [JsonApiResponse.toOne] or [JsonApiResponse.toMany] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource or the relationship does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-relationships
  FutureOr<JsonApiResponse> fetchRelationship(
      HttpRequest request, RelationshipTarget target);

  /// Deletes the resource.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  /// Use [JsonApiResponse.notFound] if the resource does not exist.
  ///
  /// See https://jsonapi.org/format/#crud-deleting
  FutureOr<JsonApiResponse> deleteResource(
      HttpRequest request, ResourceTarget target);

  /// Creates a new resource in the collection.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  /// Use [JsonApiResponse.notFound] if the collection does not exist.
  /// Use [JsonApiResponse.forbidden] if the server does not support this operation.
  /// Use [JsonApiResponse.conflict] if the resource already exists or the collection
  /// does not match the [resource] type..
  ///
  /// See https://jsonapi.org/format/#crud-creating
  FutureOr<JsonApiResponse> createResource(
      HttpRequest request, CollectionTarget target, Resource resource);

  /// Updates the resource.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  ///
  /// See https://jsonapi.org/format/#crud-updating
  FutureOr<JsonApiResponse> updateResource(
      HttpRequest request, ResourceTarget target, Resource resource);

  /// Replaces the to-one relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toOne].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  FutureOr<JsonApiResponse> replaceToOne(
      HttpRequest request, RelationshipTarget target, Identifier identifier);

  /// Replaces the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> replaceToMany(HttpRequest request,
      RelationshipTarget target, Iterable<Identifier> identifiers);

  /// Removes the given identifiers from the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> deleteFromRelationship(HttpRequest request,
      RelationshipTarget target, Iterable<Identifier> identifiers);

  /// Adds the given identifiers to  the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> addToRelationship(HttpRequest request,
      RelationshipTarget target, Iterable<Identifier> identifiers);
}
