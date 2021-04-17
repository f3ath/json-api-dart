import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/client.dart';
import 'package:json_api/src/client/request.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/response/collection_fetched.dart';
import 'package:json_api/src/client/response/related_resource_fetched.dart';
import 'package:json_api/src/client/response/relationship_fetched.dart';
import 'package:json_api/src/client/response/relationship_updated.dart';
import 'package:json_api/src/client/response/resource_created.dart';
import 'package:json_api/src/client/response/resource_fetched.dart';
import 'package:json_api/src/client/response/resource_updated.dart';

/// A routing JSON:API client
class RoutingClient {
  RoutingClient(this._uri, {Client client = const Client()})
      : _client = client;

  final Client _client;
  final UriDesign _uri;

  /// Adds [identifiers] to a to-many relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  Future<RelationshipUpdated<ToMany>> addMany(
    String type,
    String id,
    String relationship,
    List<Identifier> identifiers, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.send(
        _uri.relationship(type, id, relationship),
        Request.post(OutboundDataDocument.many(ToMany(identifiers)))
          ..headers.addAll(headers));
    return RelationshipUpdated.many(response.http, response.json);
  }

  /// Creates a new resource in the collection of type [type].
  /// The server is responsible for assigning the resource id.
  ///
  /// Optional arguments:
  /// - [attributes] - resource attributes
  /// - [one] - resource to-one relationships
  /// - [many] - resource to-many relationships
  /// - [meta] - resource meta data
  /// - [headers] - any extra HTTP headers
  Future<ResourceCreated> createNew(
    String type, {
    Map<String, Object?> attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object?> meta = const {},
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.send(
        _uri.collection(type),
        Request.post(OutboundDataDocument.newResource(NewResource(type)
          ..attributes.addAll(attributes)
          ..relationships.addAll({
            ...one.map((key, value) => MapEntry(key, ToOne(value))),
            ...many.map((key, value) => MapEntry(key, ToMany(value))),
          })
          ..meta.addAll(meta)))
          ..headers.addAll(headers));

    return ResourceCreated(
        response.http, response.json ?? (throw FormatException()));
  }

  /// Deletes [identifiers] from a to-many relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  Future<RelationshipUpdated> deleteFromMany(
    String type,
    String id,
    String relationship,
    List<Identifier> identifiers, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.send(
        _uri.relationship(type, id, relationship),
        Request.delete(OutboundDataDocument.many(ToMany(identifiers)))
          ..headers.addAll(headers));

    return RelationshipUpdated.many(response.http, response.json);
  }

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
  Future<CollectionFetched> fetchCollection(
    String type, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, String> page = const {},
    Map<String, String> filter = const {},
    Iterable<String> include = const [],
    Iterable<String> sort = const [],
    Map<String, Iterable<String>> fields = const {},
  }) async {
    final response = await _client.send(
        _uri.collection(type),
        Request.get()
          ..headers.addAll(headers)
          ..query.addAll(query)
          ..page(page)
          ..filter(filter)
          ..include(include)
          ..sort(sort)
          ..fields(fields));
    return CollectionFetched(
        response.http, response.json ?? (throw FormatException()));
  }

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
  Future<CollectionFetched> fetchRelatedCollection(
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
  }) async {
    final response = await _client.send(
        _uri.related(type, id, relationship),
        Request.get()
          ..headers.addAll(headers)
          ..query.addAll(query)
          ..page(page)
          ..filter(filter)
          ..include(include)
          ..sort(sort)
          ..fields(fields));
    return CollectionFetched(
        response.http, response.json ?? (throw FormatException()));
  }

  Future<RelationshipFetched<ToOne>> fetchToOne(
    String type,
    String id,
    String relationship, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
  }) async {
    final response = await _client.send(
        _uri.relationship(type, id, relationship),
        Request.get()..headers.addAll(headers)..query.addAll(query));
    return RelationshipFetched.one(
        response.http, response.json ?? (throw FormatException()));
  }

  Future<RelationshipFetched<ToMany>> fetchToMany(
    String type,
    String id,
    String relationship, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
  }) async {
    final response = await _client.send(
        _uri.relationship(type, id, relationship),
        Request.get()..headers.addAll(headers)..query.addAll(query));
    return RelationshipFetched.many(
        response.http, response.json ?? (throw FormatException()));
  }

  Future<RelatedResourceFetched> fetchRelatedResource(
    String type,
    String id,
    String relationship, {
    Map<String, String> headers = const {},
    Map<String, String> query = const {},
    Map<String, String> filter = const {},
    Iterable<String> include = const [],
    Map<String, Iterable<String>> fields = const {},
  }) async {
    final response = await _client.send(
        _uri.related(type, id, relationship),
        Request.get()
          ..headers.addAll(headers)
          ..query.addAll(query)
          ..filter(filter)
          ..include(include)
          ..fields(fields));
    return RelatedResourceFetched(
        response.http, response.json ?? (throw FormatException()));
  }

  Future<ResourceFetched> fetchResource(
    String type,
    String id, {
    Map<String, String> headers = const {},
    Map<String, String> filter = const {},
    Iterable<String> include = const [],
    Map<String, Iterable<String>> fields = const {},
    Map<String, String> query = const {},
  }) async {
    final response = await _client.send(
        _uri.resource(type, id),
        Request.get()
          ..headers.addAll(headers)
          ..query.addAll(query)
          ..filter(filter)
          ..include(include)
          ..fields(fields));

    return ResourceFetched(
        response.http, response.json ?? (throw FormatException()));
  }

  Future<ResourceUpdated> updateResource(String type, String id,
      {Map<String, Object?> attributes = const {},
      Map<String, Identifier> one = const {},
      Map<String, Iterable<Identifier>> many = const {},
      Map<String, Object?> meta = const {},
      Map<String, String> headers = const {}}) async {
    final response = await _client.send(
        _uri.resource(type, id),
        Request.patch(OutboundDataDocument.resource(Resource(type, id)
          ..attributes.addAll(attributes)
          ..relationships.addAll({
            ...one.map((key, value) => MapEntry(key, ToOne(value))),
            ...many.map((key, value) => MapEntry(key, ToMany(value))),
          })
          ..meta.addAll(meta)))
          ..headers.addAll(headers));
    return ResourceUpdated(response.http, response.json);
  }

  /// Creates a new resource with the given id on the server.
  Future<ResourceUpdated> create(
    String type,
    String id, {
    Map<String, Object?> attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object?> meta = const {},
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.send(
        _uri.collection(type),
        Request.post(OutboundDataDocument.resource(Resource(type, id)
          ..attributes.addAll(attributes)
          ..relationships.addAll({
            ...one.map((key, value) => MapEntry(key, ToOne(value))),
            ...many.map((key, value) => MapEntry(key, ToMany(value))),
          })
          ..meta.addAll(meta)))
          ..headers.addAll(headers));
    return ResourceUpdated(response.http, response.json);
  }

  Future<RelationshipUpdated<ToOne>> replaceToOne(
    String type,
    String id,
    String relationship,
    Identifier identifier, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.send(
        _uri.relationship(type, id, relationship),
        Request.patch(OutboundDataDocument.one(ToOne(identifier)))
          ..headers.addAll(headers));
    return RelationshipUpdated.one(response.http, response.json);
  }

  Future<RelationshipUpdated<ToMany>> replaceToMany(
    String type,
    String id,
    String relationship,
    Iterable<Identifier> identifiers, {
    Map<String, String> headers = const {},
  }) async {
    final response = await _client.send(
        _uri.relationship(type, id, relationship),
        Request.patch(OutboundDataDocument.many(ToMany(identifiers)))
          ..headers.addAll(headers));
    return RelationshipUpdated.many(response.http, response.json);
  }

  Future<RelationshipUpdated<ToOne>> deleteToOne(
      String type, String id, String relationship,
      {Map<String, String> headers = const {}}) async {
    final response = await _client.send(
        _uri.relationship(type, id, relationship),
        Request.patch(OutboundDataDocument.one(ToOne.empty()))
          ..headers.addAll(headers));
    return RelationshipUpdated.one(response.http, response.json);
  }

  Future<Response> deleteResource(String type, String id) =>
      _client.send(_uri.resource(type, id), Request.delete());
}
