import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/request_converter.dart';

/// A simple implementation of JSON:API server
class JsonApiServer implements HttpHandler {
  JsonApiServer(this._controller, {Routing routing})
      : _routing = routing ?? StandardRouting();

  final Routing _routing;
  final Controller _controller;

  @override
  Future<HttpResponse> call(HttpRequest httpRequest) async {
    try {
      RequestBase request;
      final uri = httpRequest.uri;

//      final isRouteMatched = _routing.matchCollection(
//          uri, (t) => request = _CollectionRequest(httpRequest, t)) || _routing.matchRelated(uri, onMatch);

//      jsonApiRequest = RequestConverter().convert(httpRequest);
//      jsonApiRequest.route = _routing;
    } on FormatException catch (e) {
      jsonApiRequest.sendError(400, [
        ErrorObject(
            status: '400',
            title: 'Bad request',
            detail: 'Invalid JSON. ${e.message}')
      ]);
    } on DocumentException catch (e) {
      jsonApiRequest.sendError(400, [
        ErrorObject(status: '400', title: 'Bad request', detail: e.message)
      ]);
    } on MethodNotAllowedException {
      return HttpResponse(405,
          headers: {'Allow': jsonApiRequest.allowedMethods.join(', ')});
    } on UnmatchedUriException {
      jsonApiRequest.sendError(404, [
        ErrorObject(
            status: '404',
            title: 'Not Found',
            detail: 'The requested URL does exist on the server')
      ]);
    } on IncompleteRelationshipException {
      jsonApiRequest.sendError(400, [
        ErrorObject(
            status: '400',
            title: 'Bad request',
            detail: 'Incomplete relationship object')
      ]);
    }

    await jsonApiRequest.handle(_controller);
    return jsonApiRequest.getHttpResponse();
  }
}

abstract class RequestBase {
  HttpRequest request;

  Map<String, List<String>> get queryParameters =>
      request.uri.queryParametersAll;

  Object get payload => jsonDecode(request.body);

  Iterable<String> get allowedMethods;

  Future<void> handle(Controller controller);

  Future<HttpResponse> getHttpResponse();

  void sendError(int status, Iterable<ErrorObject> list) {
    // TODO
  }

  void sendAccepted() {
    // TODO: implement sendAccepted
  }

  void sendCollection(Collection<Resource> c, {Iterable<Resource> include}) {
    // TODO: implement sendCollection
  }

  void sendCreatedResource(Resource modified) {
    // TODO: implement sendCreatedResource
  }

  void sendErrorBadRequest(List<ErrorObject> list) {
    // TODO: implement sendErrorBadRequest
  }

  void sendErrorConflict(Iterable<ErrorObject> list) {
    // TODO: implement sendErrorConflict
  }

  void sendErrorForbidden(Iterable<ErrorObject> list) {
    // TODO: implement sendErrorForbidden
  }

  void sendErrorNotFound(Iterable<ErrorObject> list) {
    // TODO: implement sendErrorNotFound
  }

  void sendMeta() {
    // TODO: implement sendMeta
  }

  void sendNoContent() {
    // TODO: implement sendNoContent
  }

  void sendSeeOther(String type, String id) {
    // TODO: implement sendSeeOther
  }
}

class _CollectionRequest extends RequestBase implements CollectionRequest {
  _CollectionRequest(HttpRequest request, this.type);

  @override
  final String type;

  @override
  Iterable<String> get allowedMethods => ['GET', 'POST'];

  @override
  Future<HttpResponse> getHttpResponse() {
    return null;
  }

  @override
  Future<void> handle(Controller controller) {
    if (request.isGet) {
      return controller.fetchCollection(this);
    }
    if (request.isPost) {
      return controller.createResource(
          this, ResourceData.fromJson(payload).unwrap());
    }
    return null;
  }
}

class _ResourceRequest extends RequestBase implements ResourceRequest {
  _ResourceRequest(HttpRequest request, this.type, this.id);

  @override
  final String type;

  @override
  final String id;

  @override
  Iterable<String> get allowedMethods => ['DELETE', 'GET', 'PATCH'];

  @override
  Future<HttpResponse> getHttpResponse() {
    return null;
  }

  @override
  Future<void> handle(Controller controller) {
    return null;
  }

  @override
  void sendResource(Resource resource, {Iterable<Resource> include}) {}
}

class _RelatedRequest extends RequestBase implements RelationshipRequest {
  _RelatedRequest(this.type, this.id, this.relationship);

  @override
  final String type;

  @override
  final String id;

  @override
  final String relationship;

  @override
  final allowedMethods = ['GET'];

  @override
  Future<HttpResponse> getHttpResponse() {
    // TODO: implement getHttpResponse
    return null;
  }

  @override
  Future<void> handle(Controller controller) {
    // TODO: implement handle
    return null;
  }

  @override
  void sendResource(Resource resource, {Iterable<Resource> include}) {
    // TODO: implement sendResource
  }

  @override
  void sendToManyRelationship(Iterable<Identifier> many, {Iterable<Resource> include}) {
    // TODO: implement sendToManyRelationship
  }

  @override
  void sendToOneRelationship(Identifier one, {Iterable<Resource> include}) {
    // TODO: implement sendToOneRelationship
  }
}




abstract class _JsonApiRequest implements ControllerRequest {
  JsonApiRequest(this._httpRequest)
      : page = Page.fromQueryParameters(_httpRequest.uri.queryParametersAll);
  final Page page;

  Uri get requested => _httpRequest.uri;
  final HttpRequest _httpRequest;
  RouteFactory route;
  HttpResponse _httpResponse;

  /// Calls the appropriate method of [controller] and returns the response
  Future<void> handle(Controller controller);

  @override
  void sendMeta() {
    // TODO: implement me
  }

  @override
  void sendSeeOther(String type, String id) {
    _httpResponse = HttpResponse(303,
        headers: {'Location': route.resource(type, id).toString()});
  }

  @override
  void sendAccepted() {
    // TODO: implement me
  }

  @override
  void sendNoContent() {
    _httpResponse = HttpResponse(204);
  }

  /// HTTP 200 OK response with a resource collection.
  ///
  /// See: https://jsonapi.org/format/#fetching-resources-responses-200
  void sendCollection(Collection<Resource> c, {List<Resource> include}) {
    sendDocument(Document(
        ResourceCollectionData(c.elements.map(resourceObject).toList(),
            links: {
              'self': Link(requested),
              ...({
                'first': const NoPagination().first(),
                'last': const NoPagination().last(c.total),
                'prev': const NoPagination().prev(page),
                'next': const NoPagination().next(page, c.total)
              }..removeWhere((k, v) => v == null))
                  .map((k, v) => MapEntry(k, Link(v.addToUri(requested))))
            },
            included: (Include.fromQueryParameters(queryParameters).isEmpty
                    ? null
                    : include)
                ?.map(resourceObject)),
        api: api));
  }

  /// A successful response containing a resource object.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-resources-responses-200
  /// - https://jsonapi.org/format/#crud-updating-responses-200
  void sendResource(Resource resource, {List<Resource> include}) {
    sendDocument(Document(
        ResourceData(resourceObject(resource),
            links: {'self': Link(requested)},
            included: (Include.fromQueryParameters(queryParameters).isEmpty
                    ? null
                    : include)
                ?.map(resourceObject)),
        api: api));
  }

  /// URI query parameters
  Map<String, List<String>> get queryParameters =>
      _httpRequest.uri.queryParametersAll;

  HttpResponse getHttpResponse() => _httpResponse;

  @override
  void sendErrorNotFound(Iterable<ErrorObject> errors) =>
      sendError(errors, 404, {});

  @override
  void sendErrorForbidden(Iterable<ErrorObject> errors) {
    sendError(errors, 403, {});
  }

  @override
  void sendErrorConflict(Iterable<ErrorObject> errors) {
    sendError(errors, 409, {});
  }

  @override
  void sendErrorBadRequest(Iterable<ErrorObject> errors) {
    sendError(errors, 400, {});
  }

  /// HTTP 405 Method Not Allowed response.
  /// The allowed methods can be specified in [allow]
  void sendErrorMethodNotAllowed(
      Iterable<ErrorObject> errors, Iterable<String> allow) {
    sendError(errors, 405, {'Allow': allow.join(', ')});
  }

  final Api api = Api(version: '1.0');

  ResourceObject resourceObject(Resource r) =>
      ResourceObject(r.type, r.id, attributes: r.attributes, relationships: {
        ...r.toOne.map((k, v) => MapEntry(
            k,
            ToOne(nullable(IdentifierObject.fromIdentifier)(v),
                links: _resourceRelationshipLinks(r.type, r.id, k)))),
        ...r.toMany.map((k, v) => MapEntry(
            k,
            ToMany(v.map(IdentifierObject.fromIdentifier),
                links: _resourceRelationshipLinks(r.type, r.id, k))))
      }, links: {
        'self': Link(requested)
      });

  void sendError(Iterable<ErrorObject> errors, int statusCode,
          Map<String, String> headers) =>
      sendDocument(Document.error(errors, api: api),
          status: statusCode, headers: headers);

  void resourceCreatedResponse(Resource resource) => sendDocument(
          Document(
              ResourceData(resourceObject(resource), links: {
                'self': Link(route.resource(resource.type, resource.id))
              }),
              api: api),
          status: 201,
          headers: {
            'Location': route.resource(resource.type, resource.id).toString()
          });

  void toManyResponse(String type, String id, String relationship,
          Iterable<Identifier> identifiers,
          {Iterable<Resource> included}) =>
      sendDocument(Document(
          ToMany(
            identifiers.map(IdentifierObject.fromIdentifier),
            links: _relationshipLinks(type, id, relationship),
          ),
          api: api));

  void sendDocument(Document d,
      {int status = 200, Map<String, String> headers = const {}}) {
    _httpResponse = HttpResponse(status,
        body: jsonEncode(d),
        headers: {...headers, 'Content-Type': Document.contentType});
  }

  Map<String, Link> _relationshipLinks(
          String type, String id, String relationship) =>
      {
        'self': Link(requested),
        'related': Link(route.related(type, id, relationship))
      };

  Map<String, Link> _resourceRelationshipLinks(
          String type, String id, String relationship) =>
      {
        'self': Link(route.relationship(type, id, relationship)),
        'related': Link(route.related(type, id, relationship))
      };
}

/// A request to fetch a collection of type [type].
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchCollection extends ControllerRequest {
  FetchCollection(HttpRequest httpRequest, this.type) : super(httpRequest);

  /// Resource type
  final String type;

  @override
  Future<void> handle(Controller controller) =>
      controller.fetchCollection(this);
}

/// A request to create a resource on the server
///
/// See: https://jsonapi.org/format/#crud-creating
class CreateResource extends ControllerRequest {
  CreateResource(HttpRequest httpRequest, this.type, this.resource)
      : super(httpRequest);

  /// Resource type
  final String type;

  /// Resource to create
  final Resource resource;

  @override
  Future<void> handle(Controller controller) => controller.createResource(this);

  /// HTTP 201 Created response containing a newly created resource
  ///
  /// See: https://jsonapi.org/format/#crud-creating-responses-201
  void sendCreatedResource(Resource resource) {
    resourceCreatedResponse(resource);
  }
}

/// A request to update a resource on the server
///
/// See: https://jsonapi.org/format/#crud-updating
class UpdateResource extends ControllerRequest {
  UpdateResource(HttpRequest httpRequest, this.type, this.id, this.resource)
      : super(httpRequest);

  final String type;
  final String id;

  /// Resource containing fields to be updated
  final Resource resource;

  @override
  Future<void> handle(Controller controller) => controller.updateResource(this);
}

/// A request to delete a resource on the server
///
/// See: https://jsonapi.org/format/#crud-deleting
class DeleteResource extends ControllerRequest {
  DeleteResource(HttpRequest httpRequest, this.type, this.id)
      : super(httpRequest);

  final String type;
  final String id;

  @override
  Future<void> handle(Controller controller) => controller.deleteResource(this);
}

/// A request to fetch a resource
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchResource extends ControllerRequest {
  FetchResource(HttpRequest httpRequest, this.type, this.id)
      : super(httpRequest);

  final String type;
  final String id;

  @override
  Future<void> handle(Controller controller) => controller.fetchResource(this);
}

/// A request to fetch a related resource or collection
///
/// See: https://jsonapi.org/format/#fetching
class FetchRelated extends ControllerRequest {
  FetchRelated(HttpRequest httpRequest, this.type, this.id, this.relationship)
      : super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  @override
  Future<void> handle(Controller controller) => controller.fetchRelated(this);
}

/// A request to fetch a relationship
///
/// See: https://jsonapi.org/format/#fetching-relationships
class FetchRelationship extends ControllerRequest {
  FetchRelationship(
      HttpRequest httpRequest, this.type, this.id, this.relationship)
      : super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  @override
  Future<void> handle(Controller controller) =>
      controller.fetchRelationship(this);

  /// HTTP 200 OK response containing a to-one relationship
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToOneRelationship(Identifier identifier) {
    sendDocument(Document(
        ToOne(
          nullable(IdentifierObject.fromIdentifier)(identifier),
          links: _relationshipLinks(type, id, relationship),
        ),
        api: api));
  }

  /// HTTP 200 OK response containing a to-may relationship.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToManyRelationship(Iterable<Identifier> identifiers) {
    toManyResponse(type, id, relationship, identifiers);
  }
}

/// A request to delete identifiers from a relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class DeleteFromRelationship extends ControllerRequest {
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
  Future<void> handle(Controller controller) =>
      controller.deleteFromRelationship(this);

  /// HTTP 200 OK response containing a to-may relationship.
  ///
  /// See:
  /// - https://jsonapi.org/format/#fetching-relationships-responses-200
  /// - https://jsonapi.org/format/#crud-updating-relationship-responses-200
  void sendToManyRelationship(Iterable<Identifier> identifiers) {
    toManyResponse(type, id, relationship, identifiers);
  }
}

/// A request to replace a to-one relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-one-relationships
class ReplaceToOne extends ControllerRequest {
  ReplaceToOne(HttpRequest httpRequest, this.type, this.id, this.relationship,
      this.identifier)
      : super(httpRequest);

  final String type;
  final String id;
  final String relationship;

  /// The identifier to be put instead of the existing
  final Identifier identifier;

  @override
  Future<void> handle(Controller controller) => controller.replaceToOne(this);
}

/// A request to completely replace a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class ReplaceToMany extends ControllerRequest {
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
  Future<void> handle(Controller controller) => controller.replaceToMany(this);
}

/// A request to add identifiers to a to-many relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class AddToRelationship extends ControllerRequest {
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
    toManyResponse(type, id, relationship, identifiers);
  }

  @override
  Future<void> handle(Controller controller) =>
      controller.addToRelationship(this);
}
