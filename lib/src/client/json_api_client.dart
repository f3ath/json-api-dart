import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/json_api_response.dart';
import 'package:json_api/src/client/request_document_factory.dart';
import 'package:json_api/src/client/status_code.dart';
import 'package:json_api/uri_design.dart';

/// The JSON:API Client.
class JsonApiClient {
  /// Fetches a resource collection at the [uri].
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceCollectionData>> fetchCollectionAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceCollectionData.fromJson);

  /// Fetches a primary resource collection. Guesses the URI by [type].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ResourceCollectionData>> fetchCollection(String type,
          {Map<String, String> headers, QueryParameters parameters}) =>
      fetchCollectionAt(_collection(type),
          headers: headers, parameters: parameters);

  /// Fetches a related resource collection. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ResourceCollectionData>> fetchRelatedCollection(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      fetchCollectionAt(_related(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a single resource at the [uri].
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ResourceData>> fetchResourceAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ResourceData.fromJson);

  /// Fetches a primary resource. Guesses the URI by [type] and [id].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ResourceData>> fetchResource(String type, String id,
          {Map<String, String> headers, QueryParameters parameters}) =>
      fetchResourceAt(_resource(type, id),
          headers: headers, parameters: parameters);

  /// Fetches a related resource. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ResourceData>> fetchRelatedResource(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      fetchResourceAt(_related(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a to-one relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ToOne>> fetchToOneAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToOne.fromJson);

  /// Same as [fetchToOneAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ToOne>> fetchToOne(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      fetchToOneAt(_relationship(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a to-many relationship
  /// Use [headers] to pass extra HTTP headers.
  /// Use [queryParameters] to specify extra request parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<ToMany>> fetchToManyAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), ToMany.fromJson);

  /// Same as [fetchToManyAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ToMany>> fetchToMany(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      fetchToManyAt(_relationship(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Fetches a to-one or to-many relationship.
  /// The actual type of the relationship can be determined afterwards.
  /// Use [headers] to pass extra HTTP headers.
  /// Use [parameters] to specify extra query parameters, such as:
  /// - [Include] to request inclusion of related resources (@see https://jsonapi.org/format/#fetching-includes)
  /// - [Fields] to specify a sparse fieldset (@see https://jsonapi.org/format/#fetching-sparse-fieldsets)
  Future<JsonApiResponse<Relationship>> fetchRelationshipAt(Uri uri,
          {Map<String, String> headers, QueryParameters parameters}) =>
      _call(_get(uri, headers, parameters), Relationship.fromJson);

  /// Same as [fetchRelationshipAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<Relationship>> fetchRelationship(
          String type, String id, String relationship,
          {Map<String, String> headers, QueryParameters parameters}) =>
      fetchRelationshipAt(_relationship(type, id, relationship),
          headers: headers, parameters: parameters);

  /// Creates a new resource. The resource will be added to a collection
  /// according to its type.
  ///
  /// https://jsonapi.org/format/#crud-creating
  Future<JsonApiResponse<ResourceData>> createResourceAt(
          Uri uri, Resource resource, {Map<String, String> headers}) =>
      _call(_post(uri, headers, _doc.resourceDocument(resource)),
          ResourceData.fromJson);

  /// Same as [createResourceAt]. Guesses the URI by [resource].type.
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ResourceData>> createResource(Resource resource,
          {Map<String, String> headers}) =>
      createResourceAt(_collection(resource.type), resource, headers: headers);

  /// Deletes the resource.
  ///
  /// https://jsonapi.org/format/#crud-deleting
  Future<JsonApiResponse> deleteResourceAt(Uri uri,
          {Map<String, String> headers}) =>
      _call(_delete(uri, headers), null);

  /// Same as [deleteResourceAt]. Guesses the URI by [type] and [id].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse> deleteResource(String type, String id,
          {Map<String, String> headers}) =>
      deleteResourceAt(_resource(type, id), headers: headers);

  /// Updates the resource via PATCH query.
  ///
  /// https://jsonapi.org/format/#crud-updating
  Future<JsonApiResponse<ResourceData>> updateResourceAt(
          Uri uri, Resource resource, {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _doc.resourceDocument(resource)),
          ResourceData.fromJson);

  /// Same as [updateResourceAt]. Guesses the URI by [resource] type an id.
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ResourceData>> updateResource(Resource resource,
          {Map<String, String> headers}) =>
      updateResourceAt(_resource(resource.type, resource.id), resource,
          headers: headers);

  /// Updates a to-one relationship via PATCH query
  ///
  /// https://jsonapi.org/format/#crud-updating-to-one-relationships
  Future<JsonApiResponse<ToOne>> replaceToOneAt(Uri uri, Identifier identifier,
          {Map<String, String> headers}) =>
      _call(
          _patch(uri, headers, _doc.toOneDocument(identifier)), ToOne.fromJson);

  /// Same as [replaceToOneAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ToOne>> replaceToOne(
          String type, String id, String relationship, Identifier identifier,
          {Map<String, String> headers}) =>
      replaceToOneAt(_relationship(type, id, relationship), identifier,
          headers: headers);

  /// Removes a to-one relationship. This is equivalent to calling [replaceToOneAt]
  /// with id = null.
  Future<JsonApiResponse<ToOne>> deleteToOneAt(Uri uri,
          {Map<String, String> headers}) =>
      replaceToOneAt(uri, null, headers: headers);

  /// Same as [deleteToOneAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ToOne>> deleteToOne(
          String type, String id, String relationship,
          {Map<String, String> headers}) =>
      deleteToOneAt(_relationship(type, id, relationship), headers: headers);

  /// Removes the [identifiers] from the to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> deleteFromToManyAt(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_deleteWithBody(uri, headers, _doc.toManyDocument(identifiers)),
          ToMany.fromJson);

  /// Same as [deleteFromToManyAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ToMany>> deleteFromToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      deleteFromToManyAt(_relationship(type, id, relationship), identifiers,
          headers: headers);

  /// Replaces a to-many relationship with the given set of [identifiers].
  ///
  /// The server MUST either completely replace every member of the relationship,
  /// return an appropriate error response if some resources can not be found or accessed,
  /// or return a 403 Forbidden response if complete replacement is not allowed by the server.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> replaceToManyAt(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_patch(uri, headers, _doc.toManyDocument(identifiers)),
          ToMany.fromJson);

  /// Same as [replaceToManyAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ToMany>> replaceToMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      replaceToManyAt(_relationship(type, id, relationship), identifiers,
          headers: headers);

  /// Adds the given set of [identifiers] to a to-many relationship.
  ///
  /// https://jsonapi.org/format/#crud-updating-to-many-relationships
  Future<JsonApiResponse<ToMany>> addToRelationshipAt(
          Uri uri, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      _call(_post(uri, headers, _doc.toManyDocument(identifiers)),
          ToMany.fromJson);

  /// Same as [addToRelationshipAt]. Guesses the URI by [type], [id], [relationship].
  /// This method requires an instance of [UriFactory] to be specified when creating this class.
  Future<JsonApiResponse<ToMany>> addToRelationship(String type, String id,
          String relationship, Iterable<Identifier> identifiers,
          {Map<String, String> headers}) =>
      addToRelationshipAt(_relationship(type, id, relationship), identifiers,
          headers: headers);

  /// Creates an instance of JSON:API client.
  /// Pass an instance of DartHttpClient (comes with this package) or
  /// another instance of [HttpHandler].
  /// Provide the [uriFactory] to use URI guessing methods.
  /// Use a custom [documentFactory] if you want to build the outgoing
  /// documents in a special way.
  JsonApiClient(this._http,
      {RequestDocumentFactory documentFactory, UriFactory uriFactory})
      : _doc = documentFactory ?? RequestDocumentFactory(),
        _uri = uriFactory ?? const _NullUriFactory();

  final HttpHandler _http;
  final RequestDocumentFactory _doc;
  final UriFactory _uri;

  HttpRequest _get(Uri uri, Map<String, String> headers,
          QueryParameters queryParameters) =>
      HttpRequest('GET', (queryParameters ?? QueryParameters({})).addToUri(uri),
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
          });

  HttpRequest _post(Uri uri, Map<String, String> headers, Document doc) =>
      HttpRequest('POST', uri,
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
            'Content-Type': Document.contentType,
          },
          body: jsonEncode(doc));

  HttpRequest _delete(Uri uri, Map<String, String> headers) =>
      HttpRequest('DELETE', uri, headers: {
        ...headers ?? {},
        'Accept': Document.contentType,
      });

  HttpRequest _deleteWithBody(
          Uri uri, Map<String, String> headers, Document doc) =>
      HttpRequest('DELETE', uri,
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
            'Content-Type': Document.contentType,
          },
          body: jsonEncode(doc));

  HttpRequest _patch(uri, Map<String, String> headers, Document doc) =>
      HttpRequest('PATCH', uri,
          headers: {
            ...headers ?? {},
            'Accept': Document.contentType,
            'Content-Type': Document.contentType,
          },
          body: jsonEncode(doc));

  Future<JsonApiResponse<D>> _call<D extends PrimaryData>(
      HttpRequest request, D Function(Object _) decodePrimaryData) async {
    final response = await _http(request);
    final document = response.body.isEmpty ? null : jsonDecode(response.body);
    if (document == null) {
      return JsonApiResponse(response.statusCode, response.headers);
    }
    if (StatusCode(response.statusCode).isPending) {
      return JsonApiResponse(response.statusCode, response.headers,
          asyncDocument: document == null
              ? null
              : Document.fromJson(document, ResourceData.fromJson));
    }
    return JsonApiResponse(response.statusCode, response.headers,
        document: document == null
            ? null
            : Document.fromJson(document, decodePrimaryData));
  }

  Uri _collection(String type) => _uri.collectionUri(type);

  Uri _relationship(String type, String id, String relationship) =>
      _uri.relationshipUri(type, id, relationship);

  Uri _resource(String type, String id) => _uri.resourceUri(type, id);

  Uri _related(String type, String id, String relationship) =>
      _uri.relatedUri(type, id, relationship);
}

final _error =
    StateError('Provide an instance of UriFactory to use URI guesing');

class _NullUriFactory implements UriFactory {
  const _NullUriFactory();

  @override
  Uri collectionUri(String type) {
    throw _error;
  }

  @override
  Uri relatedUri(String type, String id, String relationship) {
    throw _error;
  }

  @override
  Uri relationshipUri(String type, String id, String relationship) {
    throw _error;
  }

  @override
  Uri resourceUri(String type, String id) {
    throw _error;
  }
}
