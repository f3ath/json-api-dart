import 'package:json_api/document.dart';
import 'package:json_api/src/server/response_document_factory.dart';
import 'package:json_api/routing.dart';

abstract class JsonApiResponse {
  final int statusCode;

  const JsonApiResponse(this.statusCode);

  Document buildDocument(ResponseDocumentFactory factory, Uri self);

  Map<String, String> buildHeaders(Routing routing);

  static JsonApiResponse noContent() => _NoContent();

  static JsonApiResponse accepted(Resource resource) => _Accepted(resource);

  static JsonApiResponse meta(Map<String, Object> meta) => _Meta(meta);

  static JsonApiResponse collection(Iterable<Resource> collection,
          {Iterable<Resource> included, int total}) =>
      _Collection(collection, included: included, total: total);

  static JsonApiResponse resource(Resource resource,
          {Iterable<Resource> included}) =>
      _Resource(resource, included: included);

  static JsonApiResponse resourceCreated(Resource resource) =>
      _ResourceCreated(resource);

  static JsonApiResponse seeOther(String type, String id) =>
      _SeeOther(type, id);

  static JsonApiResponse toMany(String type, String id, String relationship,
          Iterable<Identifier> identifiers) =>
      _ToMany(type, id, relationship, identifiers);

  static JsonApiResponse toOne(
          String type, String id, String relationship, Identifier identifier) =>
      _ToOne(type, id, relationship, identifier);

  /// Generic error response
  static JsonApiResponse error(int statusCode, Iterable<JsonApiError> errors) =>
      _Error(statusCode, errors);

  static JsonApiResponse badRequest(Iterable<JsonApiError> errors) =>
      _Error(400, errors);

  static JsonApiResponse forbidden(Iterable<JsonApiError> errors) =>
      _Error(403, errors);

  static JsonApiResponse notFound(Iterable<JsonApiError> errors) =>
      _Error(404, errors);

  /// The allowed methods can be specified in [allow]
  static JsonApiResponse methodNotAllowed(Iterable<JsonApiError> errors,
          {Iterable<String> allow}) =>
      _Error(405, errors, headers: {'Allow': allow.join(', ')});

  static JsonApiResponse conflict(Iterable<JsonApiError> errors) =>
      _Error(409, errors);

  static JsonApiResponse notImplemented(Iterable<JsonApiError> errors) =>
      _Error(501, errors);
}

class _NoContent extends JsonApiResponse {
  const _NoContent() : super(204);

  @override
  Document<PrimaryData> buildDocument(
          ResponseDocumentFactory factory, Uri self) =>
      null;

  @override
  Map<String, String> buildHeaders(Routing routing) => {};
}

class _Collection extends JsonApiResponse {
  final Iterable<Resource> collection;
  final Iterable<Resource> included;
  final int total;

  const _Collection(this.collection, {this.included, this.total}) : super(200);

  @override
  Document<ResourceCollectionData> buildDocument(
          ResponseDocumentFactory builder, Uri self) =>
      builder.makeCollectionDocument(self, collection,
          included: included, total: total);

  @override
  Map<String, String> buildHeaders(Routing routing) =>
      {'Content-Type': Document.contentType};
}

class _Accepted extends JsonApiResponse {
  final Resource resource;

  _Accepted(this.resource) : super(202);

  @override
  Document<ResourceData> buildDocument(
          ResponseDocumentFactory factory, Uri self) =>
      factory.makeResourceDocument(self, resource);

  @override
  Map<String, String> buildHeaders(Routing routing) => {
        'Content-Type': Document.contentType,
        'Content-Location':
            routing.resource(resource.type, resource.id).toString(),
      };
}

class _Error extends JsonApiResponse {
  final Iterable<JsonApiError> errors;
  final Map<String, String> headers;

  const _Error(int status, this.errors, {this.headers = const {}})
      : super(status);

  @override
  Document buildDocument(ResponseDocumentFactory builder, Uri self) =>
      builder.makeErrorDocument(errors);

  @override
  Map<String, String> buildHeaders(Routing routing) =>
      {...headers, 'Content-Type': Document.contentType};
}

class _Meta extends JsonApiResponse {
  final Map<String, Object> meta;

  _Meta(this.meta) : super(200);

  @override
  Document buildDocument(ResponseDocumentFactory builder, Uri self) =>
      builder.makeMetaDocument(meta);

  @override
  Map<String, String> buildHeaders(Routing routing) =>
      {'Content-Type': Document.contentType};
}

class _Resource extends JsonApiResponse {
  final Resource resource;
  final Iterable<Resource> included;

  const _Resource(this.resource, {this.included}) : super(200);

  @override
  Document<ResourceData> buildDocument(
          ResponseDocumentFactory builder, Uri self) =>
      builder.makeResourceDocument(self, resource, included: included);

  @override
  Map<String, String> buildHeaders(Routing routing) =>
      {'Content-Type': Document.contentType};
}

class _ResourceCreated extends JsonApiResponse {
  final Resource resource;

  _ResourceCreated(this.resource) : super(201) {
    ArgumentError.checkNotNull(resource.id, 'resource.id');
  }

  @override
  Document<ResourceData> buildDocument(
          ResponseDocumentFactory builder, Uri self) =>
      builder.makeCreatedResourceDocument(resource);

  @override
  Map<String, String> buildHeaders(Routing routing) => {
        'Content-Type': Document.contentType,
        'Location': routing.resource(resource.type, resource.id).toString()
      };
}

class _SeeOther extends JsonApiResponse {
  final String type;
  final String id;

  _SeeOther(this.type, this.id) : super(303);

  @override
  Document buildDocument(ResponseDocumentFactory builder, Uri self) => null;

  @override
  Map<String, String> buildHeaders(Routing routing) =>
      {'Location': routing.resource(type, id).toString()};
}

class _ToMany extends JsonApiResponse {
  final Iterable<Identifier> collection;
  final String type;
  final String id;
  final String relationship;

  const _ToMany(this.type, this.id, this.relationship, this.collection)
      : super(200);

  @override
  Document<ToMany> buildDocument(ResponseDocumentFactory builder, Uri self) =>
      builder.makeToManyDocument(self, collection, type, id, relationship);

  @override
  Map<String, String> buildHeaders(Routing routing) =>
      {'Content-Type': Document.contentType};
}

class _ToOne extends JsonApiResponse {
  final String type;
  final String id;
  final String relationship;
  final Identifier identifier;

  const _ToOne(this.type, this.id, this.relationship, this.identifier)
      : super(200);

  @override
  Document<ToOne> buildDocument(ResponseDocumentFactory builder, Uri self) =>
      builder.makeToOneDocument(self, identifier, type, id, relationship);

  @override
  Map<String, String> buildHeaders(Routing routing) =>
      {'Content-Type': Document.contentType};
}
