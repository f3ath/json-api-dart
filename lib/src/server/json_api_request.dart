import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/query/include.dart';
import 'package:json_api/src/routing/route_factory.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/document_factory.dart';
import 'package:json_api/src/server/http_response_converter.dart';
import 'package:json_api/src/server/links/standard_links.dart';
import 'package:json_api/src/server/repository.dart';

/// The base interface for JSON:API requests.
abstract class JsonApiRequest {
  JsonApiRequest(this._httpRequest);

  final HttpRequest _httpRequest;
  RouteFactory routeFactory;
  HttpResponse _httpResponse;

  /// Calls the appropriate method of [controller] and returns the response
  Future<void> handleWith(Controller controller);

  /// HTTP 200 OK response containing an empty document.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  /// - https://jsonapi.org/format/#crud-deleting-responses-200
  void sendMeta() {
    // TODO: implement me
  }

  /// HTTP 303 See Other response.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  void sendSeeOther() {
    // TODO: implement me
  }

  /// HTTP 202 Accepted response.
  ///
  /// See: https://jsonapi.org/recommendations/#asynchronous-processing
  void sendAccepted() {
    // TODO: implement me
  }

  /// HTTP 204 No Content response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-responses-204
  /// - https://jsonapi.org/format/#crud-updating-responses-204
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-204
  /// - https://jsonapi.org/format/#crud-deleting-responses-204
  void sendNoContent() {
    _httpResponse = HttpResponse(204);
  }

  /// URI query parameters
  Map<String, List<String>> get queryParameters =>
      _httpRequest.uri.queryParametersAll;

  HttpResponseConverter get _converter => HttpResponseConverter(
      DocumentFactory(links: StandardLinks(_httpRequest.uri, routeFactory)),
      routeFactory);

  HttpResponse getHttpResponse() => _httpResponse;

  /// HTTP 404 Not Found response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-404
  /// - https://jsonapi.org/format/#fetching-relationships-responses-404
  /// - https://jsonapi.org/format/#crud-creating-responses-404
  /// - https://jsonapi.org/format/#crud-updating-responses-404
  /// - https://jsonapi.org/format/#crud-deleting-responses-404
  void sendErrorNotFound(Iterable<ErrorObject> errors) =>
      _httpResponse = _converter.error(errors, 404, {});

  /// HTTP 403 Forbidden response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-client-ids
  /// - https://jsonapi.org/format/#crud-creating-responses-403
  /// - https://jsonapi.org/format/#crud-updating-resource-relationships
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-403
  void sendErrorForbidden(Iterable<ErrorObject> errors) {
    _httpResponse = _converter.error(errors, 403, {});
  }

  /// HTTP 409 Conflict response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#crud-creating-responses-409
  /// - https://jsonapi.org/format/#crud-updating-responses-409
  void sendErrorConflict(Iterable<ErrorObject> errors) {
    _httpResponse = _converter.error(errors, 409, {});
  }

  /// HTTP 400 Bad Request response.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-includes
  /// - https://jsonapi.org/format/#fetching-sorting
  /// - https://jsonapi.org/format/#query-parameters
  void sendErrorBadRequest(Iterable<ErrorObject> errors) {
    _httpResponse = _converter.error(errors, 400, {});
  }

  /// HTTP 405 Method Not Allowed response.
  /// The allowed methods can be specified in [allow]
  void sendErrorMethodNotAllowed(
      Iterable<ErrorObject> errors, Iterable<String> allow) {
    _httpResponse = _converter.error(errors, 405, {'Allow': allow.join(', ')});
  }
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

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchCollection(this);

  /// HTTP 200 OK response with a resource collection.
  ///
  /// See: https://jsonapi.org/format/#fetching-resources-responses-200
  void sendCollection(Collection<Resource> c, {List<Resource> include}) {
    _httpResponse = _converter.collection(c.elements,
        total: c.total,
        included: Include.fromQueryParameters(queryParameters).isEmpty
            ? null
            : include);
  }
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

  /// HTTP 201 Created response containing a newly created resource
  ///
  /// See: https://jsonapi.org/format/#crud-creating-responses-201
  void sendCreatedResource(Resource resource) {
    _httpResponse = _converter.resourceCreated(resource);
  }
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

  /// A successful response containing a resource object.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-200
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  void sendResource(Resource resource) {
    _httpResponse = _converter.resource(resource);
  }
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
}

/// A request to fetch a resource
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchResource extends JsonApiRequest {
  FetchResource(HttpRequest httpRequest, this.type, this.id)
      : super(httpRequest);

  final String type;
  final String id;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchResource(this);

  /// A successful response containing a resource object.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-200
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  void sendResource(Resource resource, {List<Resource> include}) {
    _httpResponse = _converter.resource(resource,
        included: Include.fromQueryParameters(queryParameters).isEmpty
            ? null
            : include);
  }
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

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchRelated(this);

  /// HTTP 200 OK response with a resource collection.
  ///
  /// See: https://jsonapi.org/format/#fetching-resources-responses-200
  void sendCollection(Collection<Resource> c, {List<Resource> include}) {
    _httpResponse = _converter.collection(c.elements,
        total: c.total,
        included: Include.fromQueryParameters(queryParameters).isEmpty
            ? null
            : include);
  }

  /// A successful response containing a resource object.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-200
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  void sendResource(Resource resource, {List<Resource> include}) {
    _httpResponse = _converter.resource(resource,
        included: Include.fromQueryParameters(queryParameters).isEmpty
            ? null
            : include);
  }
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

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchRelationship(this);

  /// HTTP 200 OK response containing a to-one relationship
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToOneRelationship(Identifier identifier) {
    _httpResponse = _converter.toOne(type, id, relationship, identifier);
  }

  /// HTTP 200 OK response containing a to-may relationship.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToManyRelationship(Iterable<Identifier> identifiers) {
    _httpResponse = _converter.toMany(type, id, relationship, identifiers);
  }
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

  /// HTTP 200 OK response containing a to-may relationship.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToManyRelationship(Iterable<Identifier> identifiers) {
    _httpResponse = _converter.toMany(type, id, relationship, identifiers);
  }
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

  /// HTTP 200 OK response containing a to-may relationship.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToManyRelationship(Iterable<Identifier> identifiers) {
    _httpResponse = _converter.toMany(type, id, relationship, identifiers);
  }

  @override
  Future<void> handleWith(Controller controller) =>
      controller.addToRelationship(this);
}
