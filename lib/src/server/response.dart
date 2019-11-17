import 'package:json_api/document.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/src/target.dart';
import 'package:json_api/url_design.dart';

abstract class Response {
  final int status;

  const Response(this.status);

  Document buildDocument(ServerDocumentFactory factory, Uri self);

  Map<String, String> getHeaders(UrlFactory route) =>
      {'Content-Type': 'application/vnd.api+json'};
}

class ErrorResponse extends Response {
  final Iterable<JsonApiError> errors;

  const ErrorResponse(int status, this.errors) : super(status);

  Document buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeErrorDocument(errors);

  const ErrorResponse.notImplemented(this.errors) : super(501);

  const ErrorResponse.notFound(this.errors) : super(404);

  const ErrorResponse.badRequest(this.errors) : super(400);

  const ErrorResponse.methodNotAllowed(this.errors) : super(405);

  const ErrorResponse.conflict(this.errors) : super(409);
}

class CollectionResponse extends Response {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  const CollectionResponse(this.collection,
      {this.included = const [], this.total})
      : super(200);

  @override
  Document<ResourceCollectionData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeCollectionDocument(collection,
          self: self, included: included, total: total);
}

class ResourceResponse extends Response {
  final Resource resource;
  final Iterable<Resource> included;

  const ResourceResponse(this.resource, {this.included = const []})
      : super(200);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(resource, self: self, included: included);
}

class RelatedResourceResponse extends Response {
  final Resource resource;
  final Iterable<Resource> included;

  const RelatedResourceResponse(this.resource, {this.included = const []})
      : super(200);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeRelatedResourceDocument(resource, self: self);
}

class RelatedCollectionResponse extends Response {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  const RelatedCollectionResponse(this.collection,
      {this.included = const [], this.total})
      : super(200);

  @override
  Document<ResourceCollectionData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeRelatedCollectionDocument(collection, self: self, total: total);
}

class ToOneResponse extends Response {
  final Identifier identifier;
  final RelationshipTarget target;

  const ToOneResponse(this.target, this.identifier) : super(200);

  @override
  Document<ToOne> buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeToOneDocument(identifier, target: target, self: self);
}

class ToManyResponse extends Response {
  final Iterable<Identifier> collection;
  final RelationshipTarget target;

  const ToManyResponse(this.target, this.collection) : super(200);

  @override
  Document<ToMany> buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeToManyDocument(collection, target: target, self: self);
}

class MetaResponse extends Response {
  final Map<String, Object> meta;

  MetaResponse(this.meta) : super(200);

  @override
  Document buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeMetaDocument(meta);
}

class NoContentResponse extends Response {
  const NoContentResponse() : super(204);

  @override
  Document<PrimaryData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      null;
}

class SeeOtherResponse extends Response {
  final Resource resource;

  SeeOtherResponse(this.resource) : super(303);

  @override
  Document buildDocument(ServerDocumentFactory builder, Uri self) => null;

  @override
  Map<String, String> getHeaders(UrlFactory route) => {
        ...super.getHeaders(route),
        'Location': route.resource(resource.type, resource.id).toString()
      };
}

class ResourceCreatedResponse extends Response {
  final Resource resource;

  ResourceCreatedResponse(this.resource) : super(201);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(resource, self: self);

  @override
  Map<String, String> getHeaders(UrlFactory route) => {
        ...super.getHeaders(route),
        'Location': route.resource(resource.type, resource.id).toString()
      };
}

class ResourceUpdatedResponse extends Response {
  final Resource resource;

  ResourceUpdatedResponse(this.resource) : super(200);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(resource, self: self);
}

class AcceptedResponse extends Response {
  final Resource resource;

  AcceptedResponse(this.resource) : super(202);

  @override
  Document<ResourceData> buildDocument(
          ServerDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(resource, self: self);

  @override
  Map<String, String> getHeaders(UrlFactory route) => {
        ...super.getHeaders(route),
        'Content-Location':
            route.resource(resource.type, resource.id).toString(),
      };
}
