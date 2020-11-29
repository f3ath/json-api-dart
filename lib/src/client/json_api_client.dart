import 'package:json_api/client.dart';
import 'package:json_api/core.dart';
import 'package:json_api/document.dart';
import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/request.dart';
import 'package:json_api/src/client/response/collection_response.dart';
import 'package:json_api/src/client/response/fetch_collection_response.dart';
import 'package:json_api/src/client/response/fetch_primary_resource_response.dart';
import 'package:json_api/src/client/response/fetch_resource_response.dart';
import 'package:json_api/src/client/response/new_resource_response.dart';
import 'package:json_api/src/client/response/relationship_response.dart';
import 'package:json_api/src/client/response/request_failure.dart';
import 'package:json_api/src/client/response/resource_response.dart';
import 'package:json_api/src/client/response/response.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(
    this._http,
    this._uriFactory,
  );

  final Handler<HttpRequest, HttpResponse> _http;
  final UriFactory _uriFactory;

  /// Adds [identifiers] to a to-many relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  Future<RelationshipResponse<ToMany>> addMany(
    String type,
    String id,
    String relationship,
    List<Identifier> identifiers, {
    Map<String, String> headers = const {},
  }) async =>
      RelationshipResponse.decodeMany(await send(Request(
          'post', RelationshipTarget(Ref(type, id), relationship),
          document: OutboundDataDocument.many(ToMany(identifiers)))
        ..headers.addAll(headers)));

  /// Creates a new resource in the collection of type [type].
  /// The server is responsible for assigning the resource id.
  ///
  /// Optional arguments:
  /// - [attributes] - resource attributes
  /// - [one] - resource to-one relationships
  /// - [many] - resource to-many relationships
  /// - [meta] - resource meta data
  /// - [resourceType] - resource type (if different from collection [type])
  /// - [headers] - any extra HTTP headers
  Future<NewResourceResponse> createNew(
    String type, {
    Map<String, Object?> attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object?> meta = const {},
    String? resourceType,
    Map<String, String> headers = const {},
  }) async =>
      NewResourceResponse.decode(await send(Request(
          'post', CollectionTarget(type),
          document:
              OutboundDataDocument.newResource(NewResource(resourceType ?? type)
                ..attributes.addAll(attributes)
                ..relationships.addAll({
                  ...one.map((key, value) => MapEntry(key, ToOne(value))),
                  ...many.map((key, value) => MapEntry(key, ToMany(value))),
                })
                ..meta.addAll(meta)))
        ..headers.addAll(headers)));

  /// Deletes [identifiers] from a to-many relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  Future<RelationshipResponse<ToMany>> deleteFromToMany(
    String type,
    String id,
    String relationship,
    List<Identifier> identifiers, {
    Map<String, String> headers = const {},
  }) async =>
      RelationshipResponse.decode(await send(Request(
          'delete', RelationshipTarget(Ref(type, id), relationship),
          document: OutboundDataDocument.many(ToMany(identifiers)))
        ..headers.addAll(headers)));

  /// Fetches  a primary collection of type [type].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - any extra query parameters
  /// - [page] - pagination options
  /// - [filter] - filtering options
  /// - [include] - request to include related resources
  /// - [sort] - collection sorting options
  /// - [fields] - sparse fields options
  Future<CollectionResponse> fetchCollection(
    String type, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, String> page = const {},
    Map<String, String> filter = const {},
    Iterable<String> include = const [],
    Iterable<String> sort = const [],
    Map<String, Iterable<String>> fields = const {},
  }) async =>
      CollectionResponse.decode(await send(
          Request('get', CollectionTarget(type))
            ..headers.addAll(headers)
            ..query.addAll(query)
            ..page.addAll(page)
            ..filter.addAll(filter)
            ..include.addAll(include)
            ..sort.addAll(sort)
            ..fields.addAll(fields)));

  /// Fetches a related resource collection
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - any extra query parameters
  /// - [page] - pagination options
  /// - [filter] - filtering options
  /// - [include] - request to include related resources
  /// - [sort] - collection sorting options
  /// - [fields] - sparse fields options
  Future<FetchCollectionResponse> fetchRelatedCollection(
    String type,
    String id,
    String relationship, {
    Map<String, String> headers = const {},
    Map<String, String> page = const {},
    Map<String, String> filter = const {},
    Iterable<String> include = const [],
    Iterable<String> sort = const [],
    Map<String, Iterable<String>> fields = const {},
    Map<String, String> query = const {},
  }) async =>
      FetchCollectionResponse.decode(await send(
          Request('get', RelatedTarget(Ref(type, id), relationship))
            ..headers.addAll(headers)
            ..query.addAll(query)
            ..page.addAll(page)
            ..filter.addAll(filter)
            ..include.addAll(include)
            ..sort.addAll(sort)
            ..fields.addAll(fields)));

  Future<RelationshipResponse<ToOne>> fetchToOne(
    String type,
    String id,
    String relationship, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
  }) async =>
      RelationshipResponse.decodeOne(await send(
          Request('get', RelationshipTarget(Ref(type, id), relationship))
            ..headers.addAll(headers)
            ..query.addAll(query)));

  Future<RelationshipResponse<ToMany>> fetchToMany(
    String type,
    String id,
    String relationship, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
  }) async =>
      RelationshipResponse.decodeMany(await send(
          Request('get', RelationshipTarget(Ref(type, id), relationship))
            ..headers.addAll(headers)
            ..query.addAll(query)));

  Future<FetchRelatedResourceResponse> fetchRelatedResource(
    String type,
    String id,
    String relationship, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, String> filter = const {},
    Iterable<String> include = const [],
    Map<String, Iterable<String>> fields = const {},
  }) async =>
      FetchRelatedResourceResponse.decode(await send(
          Request('get', RelatedTarget(Ref(type, id), relationship))
            ..headers.addAll(headers)
            ..query.addAll(query)
            ..filter.addAll(filter)
            ..include.addAll(include)
            ..fields.addAll(fields)));

  Future<FetchPrimaryResourceResponse> fetchResource(
    String type,
    String id, {
    Map<String, String> headers = const {},
    Map<String, String> filter = const {},
    Iterable<String> include = const [],
    Map<String, Iterable<String>> fields = const {},
    Map<String, String> query = const {},
  }) async =>
      FetchPrimaryResourceResponse.decode(await send(
          Request('get', ResourceTarget(Ref(type, id)))
            ..headers.addAll(headers)
            ..query.addAll(query)
            ..filter.addAll(filter)
            ..include.addAll(include)
            ..fields.addAll(fields)));

  Future<ResourceResponse> updateResource(String type, String id,
          {Map<String, Object /*?*/ > attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, Object /*?*/ > meta = const {},
          Map<String, String> headers = const {}}) async =>
      ResourceResponse.decode(
          await send(Request('patch', ResourceTarget(Ref(type, id)),
              document: OutboundDataDocument.resource(Resource(Ref(type, id))
                ..attributes.addAll(attributes)
                ..relationships.addAll({
                  ...one.map((key, value) => MapEntry(key, ToOne(value))),
                  ...many.map((key, value) => MapEntry(key, ToMany(value))),
                })
                ..meta.addAll(meta)))
            ..headers.addAll(headers)));

  /// Creates a new resource with the given id on the server.
  Future<ResourceResponse> create(
    String type,
    String id, {
    Map<String, Object /*?*/ > attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object /*?*/ > meta = const {},
    Map<String, String> headers = const {},
  }) async =>
      ResourceResponse.decode(await send(Request('post', CollectionTarget(type),
          document: OutboundDataDocument.resource(Resource(Ref(type, id))
            ..attributes.addAll(attributes)
            ..relationships.addAll({
              ...one.map((k, v) => MapEntry(k, ToOne(v))),
              ...many.map((k, v) => MapEntry(k, ToMany(v))),
            })
            ..meta.addAll(meta)))
        ..headers.addAll(headers)));

  Future<RelationshipResponse<ToOne>> replaceToOne(
    String type,
    String id,
    String relationship,
    Identifier identifier, {
    Map<String, String> headers = const {},
  }) async =>
      RelationshipResponse.decodeOne(await send(Request(
          'patch', RelationshipTarget(Ref(type, id), relationship),
          document: OutboundDataDocument.one(ToOne(identifier)))
        ..headers.addAll(headers)));

  Future<RelationshipResponse<ToMany>> replaceToMany(
    String type,
    String id,
    String relationship,
    Iterable<Identifier> identifiers, {
    Map<String, String> headers = const {},
  }) async =>
      RelationshipResponse.decodeMany(await send(Request(
          'patch', RelationshipTarget(Ref(type, id), relationship),
          document: OutboundDataDocument.many(ToMany(identifiers)))
        ..headers.addAll(headers)));

  Future<RelationshipResponse<ToOne>> deleteToOne(
          String type, String id, String relationship,
          {Map<String, String> headers = const {}}) async =>
      RelationshipResponse.decodeOne(await send(Request(
          'patch', RelationshipTarget(Ref(type, id), relationship),
          document: OutboundDataDocument.one(ToOne.empty()))
        ..headers.addAll(headers)));

  Future<Response> deleteResource(String type, String id) async =>
      Response.decode(
          await send(Request('delete', ResourceTarget(Ref(type, id)))));

  /// Sends the [request] to the server.
  /// Throws a [RequestFailure] if the server responds with an error.
  Future<HttpResponse> send(Request request) async {
    final query = {
      ...Include(request.include).asQueryParameters,
      ...Sort(request.sort).asQueryParameters,
      ...Fields(request.fields).asQueryParameters,
      ...Page(request.page).asQueryParameters,
      ...Filter(request.filter).asQueryParameters,
      ...request.query
    };

    final baseUri = request.target.map(_uriFactory);
    final uri =
        query.isEmpty ? baseUri : baseUri.replace(queryParameters: query);

    final headers = {
      'Accept': MediaType.jsonApi,
      if (request.body.isNotEmpty) 'Content-Type': MediaType.jsonApi,
      ...request.headers
    };

    final response = await _http.call(
        HttpRequest(request.method, uri, body: request.body)
          ..headers.addAll(headers));

    if (response.isFailed) {
      throw RequestFailure(response,
          errors: response.hasDocument
              ? InboundDocument.decode(response.body).errors
              : []);
    }
    return response;
  }
}
