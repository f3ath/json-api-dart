import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/server/json_api_response.dart';

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
  FutureOr<JsonApiResponse> fetchCollection(FetchCollection request);

  /// Finds an returns a primary resource.
  /// Use [JsonApiResponse.resource] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchResource(FetchResource request);

  /// Finds an returns a related resource or a collection of related resources.
  /// Use [JsonApiResponse.relatedResource] or [JsonApiResponse.relatedCollection] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource or the relationship does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-resources
  FutureOr<JsonApiResponse> fetchRelated(FetchRelated request);

  /// Finds an returns a relationship of a primary resource.
  /// Use [JsonApiResponse.toOne] or [JsonApiResponse.toMany] to return a successful response.
  /// Use [JsonApiResponse.notFound] if the resource or the relationship does not exist.
  ///
  /// See https://jsonapi.org/format/#fetching-relationships
  FutureOr<JsonApiResponse> fetchRelationship(FetchRelationship request);

  /// Deletes the resource.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  /// Use [JsonApiResponse.notFound] if the resource does not exist.
  ///
  /// See https://jsonapi.org/format/#crud-deleting
  FutureOr<JsonApiResponse> deleteResource(DeleteResource request);

  /// Creates a new resource in the collection.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  /// Use [JsonApiResponse.notFound] if the collection does not exist.
  /// Use [JsonApiResponse.forbidden] if the server does not support this operation.
  /// Use [JsonApiResponse.conflict] if the resource already exists or the collection
  /// does not match the [resource] type..
  ///
  /// See https://jsonapi.org/format/#crud-creating
  FutureOr<JsonApiResponse> createResource(CreateResource request);

  /// Updates the resource.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.resource].
  ///
  /// See https://jsonapi.org/format/#crud-updating
  FutureOr<JsonApiResponse> updateResource(UpdateResourceRequest request);

  /// Replaces the to-one relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toOne].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-one-relationships
  FutureOr<JsonApiResponse> replaceToOne(ReplaceToOne request);

  /// Replaces the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> replaceToMany(ReplaceToMany request);

  /// Removes the given identifiers from the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> deleteFromRelationship(
      DeleteFromRelationship request);

  /// Adds the given identifiers to  the to-many relationship.
  /// A successful response may be one of [JsonApiResponse.accepted], [JsonApiResponse.noContent], or [JsonApiResponse.toMany].
  ///
  /// See https://jsonapi.org/format/#crud-updating-to-many-relationships
  FutureOr<JsonApiResponse> addToRelationship(AddToRelationship request);
}



abstract class JsonApiRequest {
  FutureOr<JsonApiResponse> call(JsonApiController c);
}

abstract class QueryParameters {
  Map<String, List<String>> get queryParameters;

  Include get include => Include.fromQueryParameters(queryParameters);
}

class PredefinedResponse implements JsonApiRequest {
  final JsonApiResponse response;

  PredefinedResponse(this.response);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => response;
}

class FetchCollection with QueryParameters implements JsonApiRequest {
  final String type;

  @override
  final Map<String, List<String>> queryParameters;

  FetchCollection(this.queryParameters, this.type);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) =>
      c.fetchCollection(this);
}

class CreateResource implements JsonApiRequest {
  final String type;

  final Resource resource;

  CreateResource(this.type, this.resource);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => c.createResource(this);
}

class UpdateResourceRequest implements JsonApiRequest {
  final String type;
  final String id;

  final Resource resource;

  UpdateResourceRequest(this.type, this.id, this.resource);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => c.updateResource(this);
}

class DeleteResource implements JsonApiRequest {
  final String type;

  final String id;

  DeleteResource(this.type, this.id);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => c.deleteResource(this);
}

class FetchResource with QueryParameters implements JsonApiRequest {
  final String type;
  final String id;

  @override
  final Map<String, List<String>> queryParameters;

  FetchResource(this.type, this.id, this.queryParameters);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => c.fetchResource(this);
}

class FetchRelated with QueryParameters implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;

  @override
  final Map<String, List<String>> queryParameters;

  FetchRelated(this.type, this.id, this.relationship, this.queryParameters);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => c.fetchRelated(this);
}

class FetchRelationship with QueryParameters implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;

  @override
  final Map<String, List<String>> queryParameters;

  FetchRelationship(
      this.type, this.id, this.relationship, this.queryParameters);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) =>
      c.fetchRelationship(this);
}

class DeleteFromRelationship implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;
  final Iterable<Identifiers> identifiers;

  DeleteFromRelationship(
      this.type, this.id, this.relationship, this.identifiers);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) =>
      c.deleteFromRelationship(this);
}

class ReplaceToOne implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;
  final Identifiers identifier;

  ReplaceToOne(this.type, this.id, this.relationship, this.identifier);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => c.replaceToOne(this);
}

class ReplaceToMany implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;
  final Iterable<Identifiers> identifiers;

  ReplaceToMany(this.type, this.id, this.relationship, this.identifiers);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) => c.replaceToMany(this);
}

class AddToRelationship implements JsonApiRequest {
  final String type;
  final String id;
  final String relationship;
  final Iterable<Identifiers> identifiers;

  AddToRelationship(this.type, this.id, this.relationship, this.identifiers);

  @override
  FutureOr<JsonApiResponse> call(JsonApiController c) =>
      c.addToRelationship(this);
}
