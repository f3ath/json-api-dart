import 'package:json_api/document.dart';
import 'package:json_api/src/server/json_api_request_handler.dart';

/// A base interface for JSON:API requests.
abstract class Request {
  /// Calls the appropriate method of [controller] and returns the response
  T handleWith<T>(JsonApiRequestHandler<T> controller);
}

/// A request to fetch a collection of type [type].
class FetchCollection implements Request {
  final String type;

  final Map<String, List<String>> queryParameters;

  FetchCollection(this.queryParameters, this.type);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.fetchCollection(type, queryParameters);
}

class CreateResource implements Request {
  final String type;

  final Resource resource;

  CreateResource(this.type, this.resource);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.createResource(type, resource);
}

class UpdateResource implements Request {
  final String type;
  final String id;

  final Resource resource;

  UpdateResource(this.type, this.id, this.resource);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.updateResource(type, id, resource);
}

class DeleteResource implements Request {
  final String type;

  final String id;

  DeleteResource(this.type, this.id);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.deleteResource(type, id);
}

class FetchResource implements Request {
  final String type;
  final String id;

  final Map<String, List<String>> queryParameters;

  FetchResource(this.type, this.id, this.queryParameters);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.fetchResource(type, id, queryParameters);
}

class FetchRelated implements Request {
  final String type;
  final String id;
  final String relationship;

  final Map<String, List<String>> queryParameters;

  FetchRelated(this.type, this.id, this.relationship, this.queryParameters);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.fetchRelated(type, id, relationship, queryParameters);
}

class FetchRelationship implements Request {
  final String type;
  final String id;
  final String relationship;

  final Map<String, List<String>> queryParameters;

  FetchRelationship(
      this.type, this.id, this.relationship, this.queryParameters);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.fetchRelationship(type, id, relationship, queryParameters);
}

class DeleteFromRelationship implements Request {
  final String type;
  final String id;
  final String relationship;
  final Iterable<Identifier> identifiers;

  DeleteFromRelationship(
      this.type, this.id, this.relationship, this.identifiers);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.deleteFromRelationship(type, id, relationship, identifiers);
}

class ReplaceToOne implements Request {
  final String type;
  final String id;
  final String relationship;
  final Identifier identifier;

  ReplaceToOne(this.type, this.id, this.relationship, this.identifier);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.replaceToOne(type, id, relationship, identifier);
}

class ReplaceToMany implements Request {
  final String type;
  final String id;
  final String relationship;
  final Iterable<Identifier> identifiers;

  ReplaceToMany(this.type, this.id, this.relationship, this.identifiers);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.replaceToMany(type, id, relationship, identifiers);
}

class AddToRelationship implements Request {
  final String type;
  final String id;
  final String relationship;
  final Iterable<Identifier> identifiers;

  AddToRelationship(this.type, this.id, this.relationship, this.identifiers);

  @override
  T handleWith<T>(JsonApiRequestHandler<T> controller) =>
      controller.addToRelationship(type, id, relationship, identifiers);
}
