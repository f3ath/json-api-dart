import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';

/// A wrapper over [JsonApiClient] making use of the given UrlFactory.
/// This wrapper reduces the boilerplate code but is not as flexible
/// as [JsonApiClient].
class UrlAwareClient {
  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<JsonApiResponse<ResourceData>> createResource(Resource resource,
          {Map<String, String> headers}) =>
      _client.createResource(_routing.collection.uri(resource.type), resource,
          headers: headers);

  /// Fetches a single resource
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceData>> fetchResource(String type, String id,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchResource(_routing.resource.uri(type, id),
          headers: headers, parameters: parameters);

  /// Fetches a resource collection .
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceCollectionData>> fetchCollection(String type,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchCollection(_routing.collection.uri(type),
          headers: headers, parameters: parameters);

  /// Fetches a related resource.
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceData>> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchResource(_routing.related.uri(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a related resource collection.
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceCollectionData>> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchCollection(_routing.related.uri(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ToOne>> fetchToOne(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchToOne(_routing.relationship.uri(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<Relationship>> fetchRelationship(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchRelationship(
          _routing.relationship.uri(type, id, relationship),
          headers: headers,
          parameters: parameters);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ToMany>> fetchToMany(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchToMany(_routing.relationship.uri(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Deletes the resource referenced by [type] and [id].
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<JsonApiResponse> deleteResource(String type, String id,
          {Map<String, String> headers}) =>
      _client.deleteResource(_routing.resource.uri(type, id), headers: headers);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOne]
  /// with id = null.
  Future<JsonApiResponse<ToOne>> deleteToOne(
          String type, String id, String relationship,
          {Map<String, String> headers}) =>
      _client.deleteToOne(_routing.relationship.uri(type, id, relationship),
          headers: headers);

  /// Removes the [identifiers] from the to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> deleteFromToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _client.deleteFromToMany(
          _routing.relationship.uri(type, id, relationship), identifiers,
          headers: headers);

  /// Updates the [resource].
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<JsonApiResponse<ResourceData>> updateResource(Resource resource,
          {Map<String, String> headers}) =>
      _client.updateResource(
          _routing.resource.uri(resource.type, resource.id), resource,
          headers: headers);

  /// Adds the given set of [identifiers] to a to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> addToRelationship(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _client.addToRelationship(
          _routing.relationship.uri(type, id, relationship), identifiers,
          headers: headers);

  /// Replaces a to-many relationship with the given set of [identifiers].
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> replaceToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _client.replaceToMany(
          _routing.relationship.uri(type, id, relationship), identifiers,
          headers: headers);

  /// Updates a to-one relationship via PATCH query
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<JsonApiResponse<ToOne>> replaceToOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers}) =>
      _client.replaceToOne(
          _routing.relationship.uri(type, id, relationship), identifier,
          headers: headers);

  /// Closes the internal client. You have to either call this method or
  /// close the client yourself.
  void close() => _client.close();

  UrlAwareClient(this._routing, {JsonApiClient jsonApiClient})
      : _client = jsonApiClient ?? JsonApiClient();
  final JsonApiClient _client;
  final Routing _routing;
}
