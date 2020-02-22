import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';

import 'response.dart';

/// This is a wrapper over [JsonApiClient] capable of building the
/// request URIs by itself.
class RoutingClient {
  RoutingClient(this._client, this._routing);

  final JsonApiClient _client;
  final RouteFactory _routing;

  /// Fetches a primary resource collection by [type].
  Future<Response<ResourceCollectionData>> fetchCollection(String type,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchCollectionAt(_collection(type),
          headers: headers, parameters: parameters);

  /// Fetches a related resource collection. Guesses the URI by [type], [id], [relationship].
  Future<Response<ResourceCollectionData>> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchCollectionAt(_related(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a primary resource by [type] and [id].
  Future<Response<ResourceData>> fetchResource(String type, String id,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchResourceAt(_resource(type, id),
          headers: headers, parameters: parameters);

  /// Fetches a related resource by [type], [id], [relationship].
  Future<Response<ResourceData>> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchResourceAt(_related(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a to-one relationship by [type], [id], [relationship].
  Future<Response<ToOne>> fetchToOne(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchToOneAt(_relationship(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a to-many relationship by [type], [id], [relationship].
  Future<Response<ToMany>> fetchToMany(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchToManyAt(_relationship(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a [relationship] of [type] : [id].
  Future<Response<Relationship>> fetchRelationship(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _client.fetchRelationshipAt(_relationship(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Creates the [resource] on the server.
  Future<Response<ResourceData>> createResource(Resource resource,
          {Map<String, String> headers}) =>
      _client.createResourceAt(_collection(resource.type), resource,
          headers: headers);

  /// Deletes the resource by [type] and [id].
  Future<Response> deleteResource(String type, String id,
          {Map<String, String> headers}) =>
      _client.deleteResourceAt(_resource(type, id), headers: headers);

  /// Updates the [resource].
  Future<Response<ResourceData>> updateResource(Resource resource,
          {Map<String, String> headers}) =>
      _client.updateResourceAt(_resource(resource.type, resource.id), resource,
          headers: headers);

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<Response<ToOne>> replaceToOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers}) =>
      _client.replaceToOneAt(_relationship(type, id, relationship), identifier,
          headers: headers);

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<Response<ToOne>> deleteToOne(
          String type, String id, String relationship,
          {Map<String, String> headers}) =>
      _client.deleteToOneAt(_relationship(type, id, relationship),
          headers: headers);

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<Response<ToMany>> deleteFromToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _client.deleteFromToManyAt(
          _relationship(type, id, relationship), identifiers,
          headers: headers);

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<Response<ToMany>> replaceToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _client.replaceToManyAt(
          _relationship(type, id, relationship), identifiers,
          headers: headers);

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<Response<ToMany>> addToRelationship(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _client.addToRelationshipAt(
          _relationship(type, id, relationship), identifiers,
          headers: headers);

  Uri _collection(String type) => _routing.collection(type);

  Uri _relationship(String type, String id, String relationship) =>
      _routing.relationship(type, id, relationship);

  Uri _resource(String type, String id) => _routing.resource(type, id);

  Uri _related(String type, String id, String relationship) =>
      _routing.related(type, id, relationship);
}
