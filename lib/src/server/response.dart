import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/document/to_json_encodable.dart';
import 'package:json_api/src/media_type.dart';

/// JSON:API response
Response response(int statusCode, {OutboundDocument? document}) => Response(
    statusCode,
    document != null
        ? Body.json(document, toEncodable: toJsonEncodable)
        : Body(),
    Headers())
  ..headers.addAll({
    if (document != null) 'Content-Type': [mediaType]
  });

Response ok(OutboundDocument document) =>
    response(StatusCode.ok, document: document);

Response noContent() => response(StatusCode.noContent);

Response created(OutboundDocument document, String location) =>
    response(StatusCode.created, document: document)
      ..headers['location'] = [location];

Response notFound([OutboundErrorDocument? document]) =>
    response(StatusCode.notFound, document: document);

Response methodNotAllowed([OutboundErrorDocument? document]) =>
    response(StatusCode.methodNotAllowed, document: document);

Response badRequest([OutboundErrorDocument? document]) =>
    response(StatusCode.badRequest, document: document);

Response unsupportedMediaType([OutboundErrorDocument? document]) =>
    response(StatusCode.unsupportedMediaType, document: document);

Response notAcceptable([OutboundErrorDocument? document]) =>
    response(StatusCode.notAcceptable, document: document);

Response internalServerError([OutboundErrorDocument? document]) =>
    response(StatusCode.internalServerError, document: document);
