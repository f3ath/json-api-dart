import 'dart:async';
import 'dart:convert';

import 'package:json_api/routing.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/pagination/no_pagination.dart';
import 'package:json_api/src/server/pagination/pagination_strategy.dart';
import 'package:json_api/src/server/response_document_factory.dart';
import 'package:json_api/src/server/target/target_factory.dart';

abstract class HttpMessageConverter<Request, Response> {
  FutureOr<String> getMethod(Request request);

  FutureOr<Uri> getUri(Request request);

  FutureOr<String> getBody(Request request);

  FutureOr<Response> createResponse(
      int statusCode, String body, Map<String, String> headers);
}

/// HTTP handler
class Handler<Request, Response> {
  /// Processes the incoming HTTP [request] and returns a response
  Future<Response> call(Request request) async {
    final uri = await _converter.getUri(request);
    final method = await _converter.getMethod(request);
    final body = await _converter.getBody(request);
    final document = body.isEmpty ? null : json.decode(body);

    final response = await _routing
        .match(uri, _toTarget)
        .getRequest(method)
        .call(_controller, document, request);

    return _converter.createResponse(
        response.statusCode,
        json.encode(response.buildDocument(_docFactory, uri)),
        response.buildHeaders(_routing));
  }

  /// Creates an instance of the handler.
  Handler(this._converter, this._controller, this._routing,
      {PaginationStrategy pagination = const NoPagination()})
      : _docFactory =
            ResponseDocumentFactory(_routing, pagination: pagination);
  final HttpMessageConverter<Request, Response> _converter;
  final JsonApiController<Request> _controller;
  final Routing _routing;
  final ResponseDocumentFactory _docFactory;
  final TargetFactory _toTarget = const TargetFactory();
}
