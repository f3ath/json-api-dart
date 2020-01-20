import 'dart:async';
import 'dart:convert';

import 'package:json_api/server.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/response_document_factory.dart';
import 'package:json_api/uri_design.dart';

/// HTTP handler
class Handler<Request, Response> {
  /// Processes the incoming HTTP [request] and returns a response
  Future<Response> call(Request request) async {
    final uri = await _http.getUri(request);
    final method = await _http.getMethod(request);
    final requestBody = await _http.getBody(request);
    final requestDoc = requestBody.isEmpty ? null : json.decode(requestBody);
    final requestTarget = Target.of(uri, _design);
    final jsonApiRequest = requestTarget.getRequest(method);
    final jsonApiResponse =
        await jsonApiRequest.call(_controller, requestDoc, request);
    final statusCode = jsonApiResponse.statusCode;
    final headers = jsonApiResponse.buildHeaders(_design);
    final responseDocument = jsonApiResponse.buildDocument(_docFactory, uri);
    return _http.createResponse(
        statusCode, json.encode(responseDocument), headers);
  }

  /// Creates an instance of the handler.
  Handler(this._http, this._controller, this._design, {Pagination pagination})
      : _docFactory = ResponseDocumentFactory(_design,
            pagination: pagination ?? Pagination.none());
  final HttpAdapter<Request, Response> _http;
  final JsonApiController<Request> _controller;
  final UriDesign _design;
  final ResponseDocumentFactory _docFactory;
}

/// The adapter is responsible
abstract class HttpAdapter<Request, Response> {
  FutureOr<String> getMethod(Request request);

  FutureOr<Uri> getUri(Request request);

  FutureOr<String> getBody(Request request);

  FutureOr<Response> createResponse(
      int statusCode, String body, Map<String, String> headers);
}
