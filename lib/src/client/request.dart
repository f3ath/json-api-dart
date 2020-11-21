import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/collection_response.dart';
import 'package:json_api/src/client/json_api_request.dart';
import 'package:json_api/src/client/new_resource_response.dart';
import 'package:json_api/src/client/relationship_response.dart';
import 'package:json_api/src/client/resource_response.dart';
import 'package:json_api/src/client/response.dart';

/// A basic implementation of [JsonApiRequest].
/// Allows to easily add query parameters.
/// Contains a collection of static factory methods for common JSON:API requests.
class Request<T> implements JsonApiRequest<T> {
  Request(this.method, this.target, this.convert, {this.document});

  /// Adds identifiers to a to-many relationship
  static Request<RelationshipResponse<Many>> addMany(String type, String id,
          String relationship, List<Identifier> identifiers) =>
      Request('post', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decodeMany,
          document: OutboundDataDocument.many(Many(identifiers)));

  /// Creates a new resource on the server. The server is responsible for assigning the resource id.
  static Request<NewResourceResponse> createNew(String type,
          {Map<String, Object /*?*/ > attributes = const {},
          Map<String, Identifier> one = const {},
          Map<String, Iterable<Identifier>> many = const {},
          Map<String, Object /*?*/ > meta = const {}}) =>
      Request('post', CollectionTarget(type), NewResourceResponse.decode,
          document: OutboundDataDocument.newResource(NewResource(type)
            ..attributes.addAll(attributes)
            ..relationships.addAll({
              ...one.map((key, value) => MapEntry(key, One(value))),
              ...many.map((key, value) => MapEntry(key, Many(value))),
            })
            ..meta.addAll(meta)));

  static Request<RelationshipResponse<Many>> deleteMany(String type, String id,
          String relationship, List<Identifier> identifiers) =>
      Request('delete', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decode,
          document: OutboundDataDocument.many(Many(identifiers)));

  static Request<CollectionResponse> fetchCollection(String type) =>
      Request('get', CollectionTarget(type), CollectionResponse.decode);

  static Request<CollectionResponse> fetchRelatedCollection(
          String type, String id, String relationship) =>
      Request('get', RelatedTarget(type, id, relationship),
          CollectionResponse.decode);

  static Request<RelationshipResponse> fetchRelationship(
          String type, String id, String relationship) =>
      Request('get', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decode);

  static Request<RelationshipResponse<One>> fetchOne(
          String type, String id, String relationship) =>
      Request('get', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decodeOne);

  static Request<RelationshipResponse<Many>> fetchMany(
          String type, String id, String relationship) =>
      Request('get', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decodeMany);

  static Request<ResourceResponse> fetchRelatedResource(
          String type, String id, String relationship) =>
      Request('get', RelatedTarget(type, id, relationship),
          ResourceResponse.decode);

  static Request<ResourceResponse> fetchResource(String type, String id) =>
      Request('get', ResourceTarget(type, id), ResourceResponse.decode);

  static Request<ResourceResponse> updateResource(
    String type,
    String id, {
    Map<String, Object /*?*/ > attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object /*?*/ > meta = const {},
  }) =>
      Request('patch', ResourceTarget(type, id), ResourceResponse.decode,
          document: OutboundDataDocument.resource(Resource(type, id)
            ..attributes.addAll(attributes)
            ..relationships.addAll({
              ...one.map((key, value) => MapEntry(key, One(value))),
              ...many.map((key, value) => MapEntry(key, Many(value))),
            })
            ..meta.addAll(meta)));

  /// Creates a new resource with the given id on the server.
  static Request<ResourceResponse> create(
    String type,
    String id, {
    Map<String, Object /*?*/ > attributes = const {},
    Map<String, Identifier> one = const {},
    Map<String, Iterable<Identifier>> many = const {},
    Map<String, Object /*?*/ > meta = const {},
  }) =>
      Request('post', CollectionTarget(type), ResourceResponse.decode,
          document: OutboundDataDocument.resource(Resource(type, id)
            ..attributes.addAll(attributes)
            ..relationships.addAll({
              ...one.map((k, v) => MapEntry(k, One(v))),
              ...many.map((k, v) => MapEntry(k, Many(v))),
            })
            ..meta.addAll(meta)));

  static Request<RelationshipResponse<One>> replaceOne(
          String type, String id, String relationship, Identifier identifier) =>
      Request('patch', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decodeOne,
          document: OutboundDataDocument.one(One(identifier)));

  static Request<RelationshipResponse<Many>> replaceMany(String type, String id,
          String relationship, Iterable<Identifier> identifiers) =>
      Request('patch', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decodeMany,
          document: OutboundDataDocument.many(Many(identifiers)));

  static Request<RelationshipResponse<One>> deleteOne(
          String type, String id, String relationship) =>
      Request('patch', RelationshipTarget(type, id, relationship),
          RelationshipResponse.decodeOne,
          document: OutboundDataDocument.one(One.empty()));

  static JsonApiRequest<Response> deleteResource(String type, String id) =>
      Request('delete', ResourceTarget(type, id), Response.decode);

  /// Request target
  final Target target;

  @override
  final String method;

  @override
  final Object document;

  final T Function(HttpResponse response) convert;

  @override
  final headers = <String, String>{};

  @override
  Uri uri(TargetMapper<Uri> urls) {
    final path = target.map(urls);
    return query.isEmpty
        ? path
        : path.replace(queryParameters: {...path.queryParameters, ...query});
  }

  /// URL Query String parameters
  final query = <String, String>{};

  /// Adds the request to include the [related] resources to the [query].
  void include(Iterable<String> related) {
    query.addAll(Include(related).asQueryParameters);
  }

  /// Adds the request for the sparse [fields] to the [query].
  void fields(Map<String, List<String>> fields) {
    query.addAll(Fields(fields).asQueryParameters);
  }

  /// Adds the request for pagination to the [query].
  void page(Map<String, String> page) {
    query.addAll(Page(page).asQueryParameters);
  }

  /// Adds the filter parameters to the [query].
  void filter(Map<String, String> page) {
    query.addAll(Filter(page).asQueryParameters);
  }

  /// Adds the request for page sorting to the [query].
  void sort(Iterable<String> fields) {
    query.addAll(Sort(fields).asQueryParameters);
  }

  @override
  T response(HttpResponse response) => convert(response);
}
