import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/routing/route_factory.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/document_factory.dart';
import 'package:json_api/src/server/http_response_converter.dart';
import 'package:json_api/src/server/json_api_response.dart';
import 'package:json_api/src/server/links/standard_links.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';

/// The base interface for JSON:API requests.
abstract class JsonApiRequest {
  RouteFactory routeFactory;
  JsonApiResponse _jsonApiResponse;
  Uri uri;

  /// Calls the appropriate method of [controller] and returns the response
  Future<void> handleWith(Controller controller);

  void respond(JsonApiResponse response) {
    _jsonApiResponse = response;
  }

  HttpResponse getHttpResponse() =>
      _jsonApiResponse.convert(HttpResponseConverter(
          DocumentFactory(links: StandardLinks(uri, routeFactory)),
          routeFactory));
}

class InvalidRequest extends JsonApiRequest {
  @override
  Future<void> handleWith(Controller controller) async {}
}

/// A request to fetch a collection of type [type].
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchCollection extends JsonApiRequest {
  FetchCollection(this._httpRequest, this.type);

  final HttpRequest _httpRequest;

  /// Resource type
  final String type;

  /// URI query parameters
  Map<String, List<String>> get queryParameters =>
      _httpRequest.uri.queryParametersAll;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchCollection(this);
}

/// A request to create a resource on the server
///
/// See: https://jsonapi.org/format/#crud-creating
class CreateResource extends JsonApiRequest {
  CreateResource(this.type, this.resource);

  /// Resource type
  final String type;

  /// Resource to create
  final Resource resource;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.createResource(this);
}

/// A request to update a resource on the server
///
/// See: https://jsonapi.org/format/#crud-updating
class UpdateResource extends JsonApiRequest {
  UpdateResource(this.target, this.resource);

  final ResourceTarget target;

  /// Resource containing fields to be updated
  final Resource resource;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.updateResource(this);
}

/// A request to delete a resource on the server
///
/// See: https://jsonapi.org/format/#crud-deleting
class DeleteResource extends JsonApiRequest {
  DeleteResource(this.target);

  final ResourceTarget target;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.deleteResource(this);
}

/// A request to fetch a resource
///
/// See: https://jsonapi.org/format/#fetching-resources
class FetchResource extends JsonApiRequest {
  FetchResource(this.target, this.queryParameters);

  final ResourceTarget target;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchResource(this);
}

/// A request to fetch a related resource or collection
///
/// See: https://jsonapi.org/format/#fetching
class FetchRelated extends JsonApiRequest {
  FetchRelated(this.target, this.queryParameters);

  final RelationshipTarget target;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchRelated(this);
}

/// A request to fetch a relationship
///
/// See: https://jsonapi.org/format/#fetching-relationships
class FetchRelationship extends JsonApiRequest {
  FetchRelationship(this.target, this.queryParameters);

  final RelationshipTarget target;

  /// URI query parameters
  final Map<String, List<String>> queryParameters;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.fetchRelationship(this);
}

/// A request to delete identifiers from a relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-many-relationships
class DeleteFromRelationship extends JsonApiRequest {
  DeleteFromRelationship(this.target, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers);

  final RelationshipTarget target;

  /// The identifiers to delete
  final List<Identifier> identifiers;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.deleteFromRelationship(this);
}

/// A request to replace a to-one relationship
///
/// See: https://jsonapi.org/format/#crud-updating-to-one-relationships
class ReplaceToOne extends JsonApiRequest {
  ReplaceToOne(this.target, this.identifier);

  final RelationshipTarget target;

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
  ReplaceToMany(this.target, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers);

  final RelationshipTarget target;

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
  AddToRelationship(this.target, Iterable<Identifier> identifiers)
      : identifiers = List.unmodifiable(identifiers);

  final RelationshipTarget target;

  /// The identifiers to be added to the existing ones
  final List<Identifier> identifiers;

  @override
  Future<void> handleWith(Controller controller) =>
      controller.addToRelationship(this);
}
