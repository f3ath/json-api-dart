import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/query/include.dart';
import 'package:json_api/src/routing/route_factory.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/document_factory.dart';
import 'package:json_api/src/server/http_response_converter.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/links/standard_links.dart';
import 'package:json_api/src/server/repository.dart';

/// The base interface for JSON:API requests.
abstract class JsonApiRequest {
  JsonApiRequest(this.httpRequest);

  final HttpRequest httpRequest;
  RouteFactory routeFactory;
  JsonApiResponse _jsonApiResponse;

  /// Calls the appropriate method of [controller] and returns the response
  Future<void> handleWith(Controller controller);

  void send(JsonApiResponse response) {
    _jsonApiResponse = response;
  }

  HttpResponse getHttpResponse() =>
      _jsonApiResponse.convert(HttpResponseConverter(
          DocumentFactory(links: StandardLinks(httpRequest.uri, routeFactory)),
          routeFactory));

  /// HTTP 404 Not Found response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-404
  /// - https://jsonapi.org/format/#fetching-relationships-responses-404
  /// - https://jsonapi.org/format/#crud-creating-responses-404
  /// - https://jsonapi.org/format/#crud-updating-responses-404
  /// - https://jsonapi.org/format/#crud-deleting-responses-404
  void sendErrorNotFound(Iterable<ErrorObject> errors) =>
      send(ErrorResponse(404, errors));

  /// HTTP 403 Forbidden response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-client-ids
  /// - https://jsonapi.org/format/#crud-creating-responses-403
  /// - https://jsonapi.org/format/#crud-updating-resource-relationships
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-403
  void sendErrorForbidden(Iterable<ErrorObject> errors) =>
      send(ErrorResponse(403, errors));

  /// HTTP 409 Conflict response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-responses-409
  /// - https://jsonapi.org/format/#crud-updating-responses-409
  void sendErrorConflict(Iterable<ErrorObject> errors) =>
      send(ErrorResponse(409, errors));

  /// HTTP 400 Bad Request response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-includes
  /// - https://jsonapi.org/format/#fetching-sorting
  /// - https://jsonapi.org/format/#query-parameters
  void sendErrorBadRequest(Iterable<ErrorObject> errors) =>
      send(ErrorResponse(400, errors));

  /// HTTP 405 Method Not Allowed response.
  /// The allowed methods can be specified in [allow]
  void sendErrorMethodNotAllowed(
          Iterable<ErrorObject> errors, Iterable<String> allow) =>
      send(ErrorResponse(405, errors, headers: {'Allow': allow.join(', ')}));
}

class InvalidRequest extends JsonApiRequest {
  InvalidRequest(HttpRequest httpRequest) : super(httpRequest);

  @override
  Future<void> handleWith(Controller controller) async {}
}

/// A request to fetch a collection of type [type].
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchCollection extends JsonApiRequest {
  FetchCollection(HttpRequest httpRequest, this.type) : super(httpRequest);

  /// Resource type
  final String type;

  /// URI query parameters
  Map<String, List<String>> get queryParameters =>
      httpRequest.uri.queryParametersAll;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchCollection(this);

  void sendCollection(Collection<Resource> c, {List<Resource> include}) =>
      send(CollectionResponse(c.elements,
          total: c.total,
          included: Include.fromQueryParameters(queryParameters).isEmpty
              ? null
              : include));
}

/// A request to create a resource on the server
///
/// See: https://jsonapi.org/format/#crud-creating
class CreateResource extends JsonApiRequest {
  CreateResource(HttpRequest httpRequest, this.type, this.resource)
      : super(httpRequest);

  /// Resource type
  final String type;

  /// Resource to create
  final Resource resource;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.createResource(this);

  void sendNoContent() => send(NoContentResponse());

  void sendCreatedResource(Resource resource) =>
      send(ResourceCreatedResponse(resource));
}

/// A request to update a resource on the server
///
/// See: https://jsonapi.org/format/#crud-updating
class UpdateResource extends JsonApiRequest {
  UpdateResource(HttpRequest httpRequest, this.type, this.id, this.resource)
      : super(httpRequest);

  final String type;
  final String id;

  /// Resource containing fields to be updated
  final Resource resource;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.updateResource(this);

  void sendNoContent() => send(NoContentResponse());

  void sendResource(Resource resource) => send(ResourceResponse(resource));
}

/// A request to delete a resource on the server
///
/// See: https://jsonapi.org/format/#crud-deleting
class DeleteResource extends JsonApiRequest {
  DeleteResource(HttpRequest httpRequest, this.type, this.id)
      : super(httpRequest);

  final String type;
  final String id;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.deleteResource(this);

  void sendNoContent() => send(NoContentResponse());
}

/// A request to fetch a resource
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchResource extends JsonApiRequest {
  FetchResource(
      HttpRequest httpRequest, this.type, this.id)
      : super(httpRequest);

  final String type;
  final String id;

  /// URI query parameters
  Map<String, List<String>> get queryParameters => httpRequest.uri.queryParametersAll;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchResource(this);

  void sendResource(Resource resource, {List<Resource> include}) =>
      send(ResourceResponse(resource,
          included: Include.fromQueryParameters(queryParameters).isEmpty
              ? null
              : include));
}

/// A request to fetch a related resource or collection
///
/// See: https://jsonapi.org/format/#fetching
class FetchRelated extends JsonApiRequest {
  FetchRelated(HttpRequest httpRequest, this.type, this.id, this.relationship)
      : super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  /// URI query parameters
  Map<String, List<String>> get queryParameters =>
      httpRequest.uri.queryParametersAll;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchRelated(this);

  void sendCollection(Iterable<Resource> related) =>
      send(CollectionResponse(related));
}

/// A request to fetch a relationship
///
/// See: https://jsonapi.org/format/#fetching-relationships
class FetchRelationship extends JsonApiRequest {
  FetchRelationship(
      HttpRequest httpRequest, this.type, this.id, this.relationship)
      : super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  /// URI query parameters
  Map<String, List<String>> get queryParameters =>
      httpRequest.uri.queryParametersAll;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchRelationship(this);

  void sendToOneRelationship(Identifier identifier) =>
      send(ToOneResponse(type, id, relationship, identifier));

  void sendToManyRelationship(Iterable<Identifier> identifiers) =>
      send(ToManyResponse(type, id, relationship, identifiers));
}

/// A request to delete identifiers from a relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class DeleteFromRelationship extends JsonApiRequest {
  DeleteFromRelationship(HttpRequest httpRequest, this.type, this.id,
      this.relationship, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers),
        super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  /// The identifiers to delete
  final List<Identifier> identifiers;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.deleteFromRelationship(this);

  void sendUpdatedRelationship(Iterable<Identifier> identifiers) =>
      send(ToManyResponse(type, id, relationship, identifiers));
}

/// A request to replace a to-one relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-one-relationships
class ReplaceToOne extends JsonApiRequest {
  ReplaceToOne(HttpRequest httpRequest, this.type, this.id, this.relationship,
      this.identifier)
      : super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  /// The identifier to be put instead of the existing
  final Identifier identifier;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.replaceToOne(this);

  void sendNoContent() => send(NoContentResponse());
}

/// A request to completely replace a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class ReplaceToMany extends JsonApiRequest {
  ReplaceToMany(HttpRequest httpRequest, this.type, this.id, this.relationship,
      Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers),
        super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  /// The set of identifiers to replace the current ones
  final List<Identifier> identifiers;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.replaceToMany(this);

  void sendNoContent() => send(NoContentResponse());
}

/// A request to add identifiers to a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class AddToRelationship extends JsonApiRequest {
  AddToRelationship(HttpRequest httpRequest, this.type, this.id,
      this.relationship, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers),
        super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  /// The identifiers to be added to the existing ones
  final List<Identifier> identifiers;

  void sendUpdatedRelationship(Iterable<Identifier> identifiers) =>
      send(ToManyResponse(type, id, relationship, identifiers));

  @override
  Future<void> handleWith(Controller controller) =>
      controller.addToRelationship(this);
}
