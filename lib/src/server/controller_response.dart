import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/collection.dart';

abstract class ControllerResponse {
  int get status;

  Map<String, String> headers(RouteFactory route);

  Document document(DocumentFactory doc);
}

class ErrorResponse implements ControllerResponse {
  ErrorResponse(this.status, this.errors);

  @override
  final int status;
  final List<ErrorObject> errors;

  @override
  Map<String, String> headers(RouteFactory route) =>
      {'Content-Type': Document.contentType};

  @override
  Document document(DocumentFactory doc) => doc.error(errors);
}

class NoContentResponse implements ControllerResponse {
  NoContentResponse();

  @override
  int get status => 204;

  @override
  Map<String, String> headers(RouteFactory route) => {};

  @override
  Document document(DocumentFactory doc) => null;
}

class ResourceResponse implements ControllerResponse {
  ResourceResponse(this.resource, {this.include});

  final Resource resource;
  final List<Resource> include;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(RouteFactory route) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ResourceData> document(DocumentFactory doc) =>
      doc.resource(resource, include: include);
}

class CreatedResourceResponse implements ControllerResponse {
  CreatedResourceResponse(this.resource);

  final Resource resource;

  @override
  int get status => 201;

  @override
  Map<String, String> headers(RouteFactory route) => {
        'Content-Type': Document.contentType,
        'Location': route.resource(resource.type, resource.id).toString()
      };

  @override
  Document<ResourceData> document(DocumentFactory doc) =>
      doc.createdResource(resource, StandardRouting());
}

class CollectionResponse implements ControllerResponse {
  CollectionResponse(this.collection, {this.include});

  final Collection<Resource> collection;
  final List<Resource> include;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(RouteFactory route) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ResourceCollectionData> document(DocumentFactory doc) =>
      doc.collection(collection, include: include);
}

class ToOneResponse implements ControllerResponse {
  ToOneResponse(this.identifier);

  final Identifier identifier;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(RouteFactory route) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ToOne> document(DocumentFactory doc) => doc.toOne(identifier);
}

class ToManyResponse implements ControllerResponse {
  ToManyResponse(this.identifiers);

  final List<Identifier> identifiers;

  @override
  int get status => 200;

  @override
  Map<String, String> headers(RouteFactory route) =>
      {'Content-Type': Document.contentType};

  @override
  Document<ToMany> document(DocumentFactory doc) => doc.toMany(identifiers);
}

class DocumentFactory {
  Document error(List<ErrorObject> errors) => Document.error(errors);

  Document<ResourceCollectionData> collection(Collection<Resource> collection,
          {List<Resource> include}) =>
      Document(ResourceCollectionData(collection.elements.map(resourceObject),
          include: include?.map(resourceObject)));

  Document<ResourceData> resource(Resource resource,
          {List<Resource> include}) =>
      Document(ResourceData(resourceObject(resource),
          include: include?.map(resourceObject)));

  Document<ResourceData> createdResource(
          Resource resource, RouteFactory routeFactory) =>
      Document(ResourceData(resourceObject(resource,
          self: Link(routeFactory.resource(resource.type, resource.id)))));

  Document<ToOne> toOne(Identifier identifier) =>
      Document(ToOne(IdentifierObject.fromIdentifier(identifier)));

  Document<ToMany> toMany(List<Identifier> identifiers) =>
      Document(ToMany(identifiers.map(IdentifierObject.fromIdentifier)));

  ResourceObject resourceObject(Resource resource, {Link self}) {
    return ResourceObject(resource.type, resource.id,
        attributes: resource.attributes,
        relationships: {
          ...resource.toOne.map((k, v) =>
              MapEntry(k, ToOne(nullable(IdentifierObject.fromIdentifier)(v)))),
          ...resource.toMany.map((k, v) =>
              MapEntry(k, ToMany(v.map(IdentifierObject.fromIdentifier)))),
        },
        links: {
          if (self != null) 'self': self
        });
  }
}
