import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/client.dart';
import 'package:json_api/src/client/request.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/response/collection_fetched.dart';
import 'package:json_api/src/client/response/related_resource_fetched.dart';
import 'package:json_api/src/client/response/relationship_fetched.dart';
import 'package:json_api/src/client/response/relationship_updated.dart';
import 'package:json_api/src/client/response/request_failure.dart';
import 'package:json_api/src/client/response/resource_created.dart';
import 'package:json_api/src/client/response/resource_fetched.dart';
import 'package:json_api/src/client/response/resource_updated.dart';

/// A routing JSON:API client
class RoutingClient {
  RoutingClient(this._baseUri, this._client);

  final Client _client;
  final UriDesign _baseUri;

  /// Adds the [identifiers] to the to-many relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  Future<RelationshipUpdated<ToMany>> addMany(
    String type,
    String id,
    String relationship,
    List<Identifier> identifiers, {
    Map<String, Object?> meta = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await send(
        _baseUri.relationship(type, id, relationship),
        Request.post(
            OutboundDataDocument.many(ToMany(identifiers)..meta.addAll(meta)))
          ..headers.addAll(headers));
    return RelationshipUpdated.many(response.httpResponse, response.document);
  }

  /// Creates a new resource with the given [type] and [id] on the server.
  ///
  /// Optional arguments:
  /// - [attributes] - resource attributes
  /// - [one] - resource to-one relationships
  /// - [many] - resource to-many relationships
  /// - [meta] - resource meta data
  /// - [documentMeta] - document meta
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<ResourceUpdated> create(
    String type,
    String id, {
    Map<String, Object?> attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object?> meta = const {},
    Map<String, Object?> documentMeta = const {},
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.collection(type),
        Request.post(OutboundDataDocument.resource(Resource(type, id)
          ..attributes.addAll(attributes)
          ..relationships.addAll({
            ...one.map((key, value) => MapEntry(key, ToOne(value))),
            ...many.map((key, value) => MapEntry(key, ToMany(value))),
          })
          ..meta.addAll(meta))
          ..meta.addAll(documentMeta))
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return ResourceUpdated(response.httpResponse, response.document);
  }

  /// Creates a new resource in the collection of type [type].
  /// The server is responsible for assigning the resource id.
  ///
  /// Optional arguments:
  /// - [lid] - local resource id
  /// - [attributes] - resource attributes
  /// - [one] - resource to-one relationships
  /// - [many] - resource to-many relationships
  /// - [meta] - resource meta data
  /// - [documentMeta] - document meta
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<ResourceCreated> createNew(
    String type, {
    String? lid,
    Map<String, Object?> attributes = const {},
    Map<String, NewIdentifier> one = const {},
    Map<String, Iterable<NewIdentifier>> many = const {},
    Map<String, Object?> meta = const {},
    Map<String, Object?> documentMeta = const {},
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.collection(type),
        Request.post(
            OutboundDataDocument.newResource(NewResource(type, lid: lid)
              ..attributes.addAll(attributes)
              ..relationships.addAll({
                ...one.map((key, value) => MapEntry(key, NewToOne(value))),
                ...many.map((key, value) => MapEntry(key, NewToMany(value))),
              })
              ..meta.addAll(meta))
              ..meta.addAll(documentMeta))
          ..headers.addAll(headers)
          ..query.mergeAll(query));

    return ResourceCreated(
        response.httpResponse, response.document ?? (throw FormatException()));
  }

  /// Deletes the [identifiers] from the to-many relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [meta] - relationship meta data
  Future<RelationshipUpdated> deleteFromMany(
    String type,
    String id,
    String relationship,
    List<Identifier> identifiers, {
    Map<String, Object?> meta = const {},
    Map<String, List<String>> headers = const {},
  }) async {
    final response = await send(
        _baseUri.relationship(type, id, relationship),
        Request.delete(
            OutboundDataDocument.many(ToMany(identifiers)..meta.addAll(meta)))
          ..headers.addAll(headers));

    return RelationshipUpdated.many(response.httpResponse, response.document);
  }

  /// Fetches the primary collection of type [type].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<CollectionFetched> fetchCollection(
    String type, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.collection(type),
        Request.get()
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return CollectionFetched(
        response.httpResponse, response.document ?? (throw FormatException()));
  }

  /// Fetches the related resource collection
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<CollectionFetched> fetchRelatedCollection(
    String type,
    String id,
    String relationship, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.related(type, id, relationship),
        Request.get()
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return CollectionFetched(
        response.httpResponse, response.document ?? (throw FormatException()));
  }

  /// Fetches the to-one relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<RelationshipFetched<ToOne>> fetchToOne(
    String type,
    String id,
    String relationship, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.relationship(type, id, relationship),
        Request.get()
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return RelationshipFetched.one(
        response.httpResponse, response.document ?? (throw FormatException()));
  }

  /// Fetches the to-many relationship
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<RelationshipFetched<ToMany>> fetchToMany(
    String type,
    String id,
    String relationship, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.relationship(type, id, relationship),
        Request.get()
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return RelationshipFetched.many(
        response.httpResponse, response.document ?? (throw FormatException()));
  }

  /// Fetches the related resource
  /// identified by [type], [id], [relationship].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<RelatedResourceFetched> fetchRelatedResource(
    String type,
    String id,
    String relationship, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.related(type, id, relationship),
        Request.get()
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return RelatedResourceFetched(
        response.httpResponse, response.document ?? (throw FormatException()));
  }

  /// Fetches the resource identified by [type] and [id].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<ResourceFetched> fetchResource(
    String type,
    String id, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.resource(type, id),
        Request.get()
          ..headers.addAll(headers)
          ..query.mergeAll(query));

    return ResourceFetched(
        response.httpResponse, response.document ?? (throw FormatException()));
  }

  /// Updates the resource identified by [type] and [id].
  ///
  /// Optional arguments:
  /// - [attributes] - attributes to update
  /// - [one] - to-one relationships to update
  /// - [many] - to-many relationships to update
  /// - [meta] - resource meta data to update
  /// - [documentMeta] - document meta data
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<ResourceUpdated> updateResource(
    String type,
    String id, {
    Map<String, Object?> attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object?> meta = const {},
    Map<String, Object?> documentMeta = const {},
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.resource(type, id),
        Request.patch(OutboundDataDocument.resource(Resource(type, id)
          ..attributes.addAll(attributes)
          ..relationships.addAll({
            ...one.map((key, value) => MapEntry(key, ToOne(value))),
            ...many.map((key, value) => MapEntry(key, ToMany(value))),
          })
          ..meta.addAll(meta))
          ..meta.addAll(documentMeta))
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return ResourceUpdated(response.httpResponse, response.document);
  }

  /// Replaces the to-one relationship
  /// identified by [type], [id], and [relationship] by setting
  /// the new [identifier].
  ///
  /// Optional arguments:
  /// - [meta] - relationship metadata
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<RelationshipUpdated<ToOne>> replaceToOne(
    String type,
    String id,
    String relationship,
    Identifier identifier, {
    Map<String, Object?> meta = const {},
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.relationship(type, id, relationship),
        Request.patch(
            OutboundDataDocument.one(ToOne(identifier)..meta.addAll(meta)))
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return RelationshipUpdated.one(response.httpResponse, response.document);
  }

  /// Replaces the to-many relationship
  /// identified by [type], [id], and [relationship] by setting
  /// the new [identifiers].
  ///
  /// Optional arguments:
  /// - [meta] - relationship metadata
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<RelationshipUpdated<ToMany>> replaceToMany(
    String type,
    String id,
    String relationship,
    Iterable<Identifier> identifiers, {
    Map<String, Object?> meta = const {},
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.relationship(type, id, relationship),
        Request.patch(
            OutboundDataDocument.many(ToMany(identifiers)..meta.addAll(meta)))
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return RelationshipUpdated.many(response.httpResponse, response.document);
  }

  /// Removes the to-one relationship
  /// identified by [type], [id], and [relationship]..
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<RelationshipUpdated<ToOne>> deleteToOne(
    String type,
    String id,
    String relationship, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) async {
    final response = await send(
        _baseUri.relationship(type, id, relationship),
        Request.patch(OutboundDataDocument.one(ToOne.empty()))
          ..headers.addAll(headers)
          ..query.mergeAll(query));
    return RelationshipUpdated.one(response.httpResponse, response.document);
  }

  /// Deletes the resource identified by [type] and [id].
  ///
  /// Optional arguments:
  /// - [headers] - any extra HTTP headers
  /// - [query] - a collection of parameters to be included in the URI query
  Future<Response> deleteResource(
    String type,
    String id, {
    Map<String, List<String>> headers = const {},
    Iterable<QueryEncodable> query = const [],
  }) =>
      send(
          _baseUri.resource(type, id),
          Request.delete()
            ..headers.addAll(headers)
            ..query.mergeAll(query));

  /// Sends the [request] to the [uri] on the server.
  /// This method can be used to send any non-standard requests.
  Future<Response> send(Uri uri, Request request) async {
    final response = await _client.send(uri, request);
    if (response.isFailed) {
      throw RequestFailure(response.httpResponse, response.document);
    }
    return response;
  }
}
