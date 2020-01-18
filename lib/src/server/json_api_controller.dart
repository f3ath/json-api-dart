import 'dart:async';

import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_response.dart';

/// The Controller consolidates all possible requests a JSON:API server
/// may handle. The controller is agnostic to the request, therefore it is
/// generalized with `<R>`. Each of the methods is expected to return a
/// [JsonApiResponse] object or a [Future] of it.
///
/// The response may either be a successful or an error.
abstract class JsonApiController<R> {
  /// Finds an returns a primary  resource collection of the given [type].
  /// Use [JsonApiResponse.collection] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the collection does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchCollection(R request, String type);

  /// Finds an returns a primary resource of the given [type] and [id].
  /// Use [JsonApiResponse.resource] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchResource(R request, String type, String id);

  /// Finds an returns a related resource or a collection of related resources.
  /// Use [JsonApiResponse.relatedResource] or [JsonApiResponse.relatedCollection] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource or the relationship does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchRelated(
      R request, String type, String id, String relationship);

  /// Finds an returns a relationship of a primary resource identified by [type] and [id].
  /// Use [JsonApiResponse.toOne] or [JsonApiResponse.toMany] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource or the relationship does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-relationships
  FutureOr<JsonApiResponse> fetchRelationship(
      R request, String type, String id, String relationship);

  /// Deletes the resource identified by [type] and [id].
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  /// Use [JsonApiResponse.notFound] if the resource does not exist.
  ///
  /// See https://jsonapi.org/format/#crud-deleting
  FutureOr<JsonApiResponse> deleteResource(R request, String type, String id);

  /// Creates a new [resource] in the collection of the given [type].
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  /// Use [JsonApiResponse.notFound] if the collection does not exist.
  /// Use [JsonApiResponse.forbidden] if the server does not support this operation.
  /// Use [JsonApiResponse.conflict] if the resource already exists or the collection
  /// does not match the [resource] type..
  ///
  /// See https://jsonapi.org/format/#crud-creating
  FutureOr<JsonApiResponse> createResource(
      R request, String type, Resource resource);

  /// Updates the resource identified by [type] and [id]. The [resource] argument
  /// contains the data to update/replace.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  ///
  /// See https://jsonapi.org/format/#crud-updating
  FutureOr<JsonApiResponse> updateResource(
      R request, String type, String id, Resource resource);

  /// Replaces the to-one relationship with the given [identifier].
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toOne].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  FutureOr<JsonApiResponse> replaceToOne(R request, String type, String id,
      String relationship, Identifier identifier);

  /// Replaces the to-many relationship with the given [identifiers].
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> replaceToMany(R request, String type, String id,
      String relationship, Iterable<Identifier> identifiers);

  /// Removes the given [identifiers] from the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> deleteFromRelationship(R request, String type,
      String id, String relationship, Iterable<Identifier> identifiers);

  /// Adds the given [identifiers] to  the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> addToRelationship(R request, String type, String id,
      String relationship, Iterable<Identifier> identifiers);
}
