import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/document_builder.dart';
import 'package:json_api/src/document/identifier.dart';
import 'package:json_api/src/document/json_api_error.dart';
import 'package:json_api/src/document/primary_data.dart';
import 'package:json_api/src/document/resource.dart';
import 'package:json_api/src/target.dart';
import 'package:json_api/url_design.dart';

abstract class Response {
  final int status;

  const Response(this.status);

  Document getDocument(DocumentBuilder builder, Uri self);

  Map<String, String> getHeaders(UrlBuilder route) =>
      {'Content-Type': 'application/vnd.api+json'};
}

class ErrorResponse extends Response {
  final Iterable<JsonApiError> errors;

  const ErrorResponse(int status, this.errors) : super(status);

  Document getDocument(DocumentBuilder builder, Uri self) =>
      builder.errorDocument(errors);

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
  Document getDocument(DocumentBuilder builder, Uri self) =>
      builder.collectionDocument(collection,
          self: self, included: included, total: total);
}

class ResourceResponse extends Response {
  final Resource resource;
  final Iterable<Resource> included;

  const ResourceResponse(this.resource, {this.included = const []})
      : super(200);

  @override
  Document getDocument(DocumentBuilder builder, Uri self) =>
      builder.resourceDocument(resource, self: self, included: included);
}

class RelatedResourceResponse extends Response {
  final Resource resource;
  final Iterable<Resource> included;

  const RelatedResourceResponse(this.resource, {this.included = const []})
      : super(200);

  @override
  Document getDocument(DocumentBuilder builder, Uri self) =>
      builder.relatedResourceDocument(resource, self: self);
}

class RelatedCollectionResponse extends Response {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  const RelatedCollectionResponse(this.collection,
      {this.included = const [], this.total})
      : super(200);

  @override
  Document getDocument(DocumentBuilder builder, Uri self) =>
      builder.relatedCollectionDocument(collection, self: self, total: total);
}

class ToOneResponse extends Response {
  final Identifier identifier;
  final RelationshipTarget target;

  const ToOneResponse(this.target, this.identifier) : super(200);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) =>
      builder.toOneDocument(identifier, target: target, self: self);
}

class ToManyResponse extends Response {
  final Iterable<Identifier> collection;
  final RelationshipTarget target;

  const ToManyResponse(this.target, this.collection) : super(200);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) =>
      builder.toManyDocument(collection, target: target, self: self);
}

class MetaResponse extends Response {
  final Map<String, Object> meta;

  MetaResponse(this.meta) : super(200);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) =>
      builder.metaDocument(meta);
}

class NoContentResponse extends Response {
  const NoContentResponse() : super(204);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) => null;
}

class SeeOtherResponse extends Response {
  final Resource resource;

  SeeOtherResponse(this.resource) : super(303);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) => null;

  @override
  Map<String, String> getHeaders(UrlBuilder route) => {
        ...super.getHeaders(route),
        'Location': route.resource(resource.type, resource.id).toString()
      };
}

class ResourceCreatedResponse extends Response {
  final Resource resource;

  ResourceCreatedResponse(this.resource) : super(201);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) =>
      builder.resourceDocument(resource, self: self);

  @override
  Map<String, String> getHeaders(UrlBuilder route) => {
        ...super.getHeaders(route),
        'Location': route.resource(resource.type, resource.id).toString()
      };
}

class ResourceUpdatedResponse extends Response {
  final Resource resource;

  ResourceUpdatedResponse(this.resource) : super(200);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) =>
      builder.resourceDocument(resource, self: self);
}

class AcceptedResponse extends Response {
  final Resource resource;

  AcceptedResponse(this.resource) : super(202);

  @override
  Document<PrimaryData> getDocument(DocumentBuilder builder, Uri self) =>
      builder.resourceDocument(resource, self: self);

  @override
  Map<String, String> getHeaders(UrlBuilder route) => {
        ...super.getHeaders(route),
        'Content-Location':
            route.resource(resource.type, resource.id).toString(),
      };
}
