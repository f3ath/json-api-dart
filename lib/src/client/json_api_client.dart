import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._uri);

  final HttpHandler _http;
  final UriFactory _uri;

  /// Fetches a primary resource collection by [type].
  Future<Response<ResourceCollectionData>> fetchCollection(String type,
          {Map<String, String> headers, QueryParameters parameters}) =>
      send(
        Request.fetchCollection(parameters: parameters),
        _uri.collection(type),
        headers: headers,
      );

  /// Fetches a related resource collection. Guesses the URI by [type], [id], [relationship].
  Future<Response<ResourceCollectionData>> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      send(Request.fetchCollection(parameters: parameters),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a primary resource by [type] and [id].
  Future<Response<ResourceData>> fetchResource(String type, String id,
          {Map<String, String> headers, QueryParameters parameters}) =>
      send(Request.fetchResource(parameters: parameters),
          _uri.resource(type, id),
          headers: headers);

  /// Fetches a related resource by [type], [id], [relationship].
  Future<Response<ResourceData>> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      send(Request.fetchResource(parameters: parameters),
          _uri.related(type, id, relationship),
          headers: headers);

  /// Fetches a to-one relationship by [type], [id], [relationship].
  Future<Response<ToOne>> fetchToOne(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      send(Request.fetchToOne(parameters: parameters),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Fetches a to-many relationship by [type], [id], [relationship].
  Future<Response<ToMany>> fetchToMany(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      send(
        Request.fetchToMany(parameters: parameters),
        _uri.relationship(type, id, relationship),
        headers: headers,
      );

  /// Fetches a [relationship] of [type] : [id].
  Future<Response<Relationship>> fetchRelationship(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      send(Request.fetchRelationship(parameters: parameters),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Creates the [resource] on the server.
  Future<Response<ResourceData>> createResource(Resource resource,
          {Map<String, String> headers}) =>
      send(Request.createResource(_resourceDoc(resource)),
          _uri.collection(resource.type),
          headers: headers);

  /// Deletes the resource by [type] and [id].
  Future<Response> deleteResource(String type, String id,
          {Map<String, String> headers}) =>
      send(Request.deleteResource(), _uri.resource(type, id), headers: headers);

  /// Updates the [resource].
  Future<Response<ResourceData>> updateResource(Resource resource,
          {Map<String, String> headers}) =>
      send(Request.updateResource(_resourceDoc(resource)),
          _uri.resource(resource.type, resource.id),
          headers: headers);

  /// Replaces the to-one [relationship] of [type] : [id].
  Future<Response<ToOne>> replaceToOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers}) =>
      send(Request.replaceToOne(_toOneDoc(identifier)),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the to-one [relationship] of [type] : [id].
  Future<Response<ToOne>> deleteToOne(
          String type, String id, String relationship,
          {Map<String, String> headers}) =>
      send(Request.replaceToOne(_toOneDoc(null)),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Deletes the [identifiers] from the to-many [relationship] of [type] : [id].
  Future<Response<ToMany>> deleteFromToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      send(Request.deleteFromToMany(_toManyDoc(identifiers)),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Replaces the to-many [relationship] of [type] : [id] with the [identifiers].
  Future<Response<ToMany>> replaceToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      send(Request.replaceToMany(_toManyDoc(identifiers)),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Adds the [identifiers] to the to-many [relationship] of [type] : [id].
  Future<Response<ToMany>> addToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      send(Request.addToMany(_toManyDoc(identifiers)),
          _uri.relationship(type, id, relationship),
          headers: headers);

  /// Sends the request to the [uri] via [handler] and returns the response.
  /// Extra [headers] may be added to the request.
  Future<Response<D>> send<D extends PrimaryData>(Request<D> request, Uri uri,
          {Map<String, String> headers}) async =>
      Response(
          await _http.call(HttpRequest(
              request.method, request.parameters.addToUri(uri),
              body: request.body, headers: {...?headers, ...request.headers})),
          request.decoder);

  Document<ResourceData> _resourceDoc(Resource resource) =>
      Document(ResourceData.fromResource(resource));

  Document<ToMany> _toManyDoc(Iterable<Identifier> identifiers) =>
      Document(ToMany.fromIdentifiers(identifiers));

  Document<ToOne> _toOneDoc(Identifier identifier) =>
      Document(ToOne.fromIdentifier(identifier));
}
