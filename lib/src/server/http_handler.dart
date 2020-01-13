import 'dart:async';
import 'dart:convert';

import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/pagination/no_pagination.dart';
import 'package:json_api/src/server/pagination/pagination_strategy.dart';
import 'package:json_api/src/server/server_document_factory.dart';
import 'package:json_api/src/server/target.dart';
import 'package:json_api/url_design.dart';

typedef HttpHandler<Request, Response> = Future<Response> Function(
    Request request);

HttpHandler<Request, Response> createHttpHandler<Request, Response>(
    HttpMessageConverter<Request, Response> converter,
    JsonApiController<Request> controller,
    UrlDesign urlDesign,
    {PaginationStrategy pagination = const NoPagination()}) {
  const targetFactory = TargetFactory();
  const requestFactory = ControllerRequestFactory();
  final docFactory = ServerDocumentFactory(urlDesign, pagination: pagination);

  return (Request request) async {
    final uri = await converter.getUri(request);
    final method = await converter.getMethod(request);
    final body = await converter.getBody(request);
    final target = urlDesign.match(uri, targetFactory);
    final requestDocument = body.isEmpty ? null : json.decode(body);
    final response = await target
        .getRequest(method, requestFactory)
        .call(controller, requestDocument, request);
    return converter.createResponse(response.statusCode,
        json.encode(response.buildDocument(docFactory, uri)), {
      ...response.buildHeaders(urlDesign),
      'Access-Control-Allow-Origin': '*',
          'Access-Control-Request-Headers': 'X-PINGOTHER, Content-Type'
    });
  };
}

abstract class HttpMessageConverter<Request, Response> {
  FutureOr<String> getMethod(Request request);

  FutureOr<Uri> getUri(Request request);

  FutureOr<String> getBody(Request request);

  FutureOr<Response> createResponse(
      int statusCode, String body, Map<String, String> headers);
}
