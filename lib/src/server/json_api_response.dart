import 'package:json_api/document.dart';
import 'package:json_api/http.dart';

/// JSON:API response
class JsonApiResponse<D extends OutboundDocument> {
  JsonApiResponse(this.statusCode, {this.document});

  final D /*?*/ document;
  final int statusCode;
  final headers = Headers();

  static JsonApiResponse ok(OutboundDocument document) =>
      JsonApiResponse(200, document: document);

  static JsonApiResponse noContent() => JsonApiResponse(204);

  static JsonApiResponse created(OutboundDocument document, String location) =>
      JsonApiResponse(201, document: document)..headers['location'] = location;

  static JsonApiResponse notFound({OutboundErrorDocument /*?*/ document}) =>
      JsonApiResponse(404, document: document);

  static JsonApiResponse methodNotAllowed(
          {OutboundErrorDocument /*?*/ document}) =>
      JsonApiResponse(405, document: document);

  static JsonApiResponse badRequest({OutboundErrorDocument /*?*/ document}) =>
      JsonApiResponse(400, document: document);

  static JsonApiResponse internalServerError(
          {OutboundErrorDocument /*?*/ document}) =>
      JsonApiResponse(500, document: document);
}
