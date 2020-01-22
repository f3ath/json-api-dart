import 'dart:async';
import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:json_api/src/server/json_api_controller.dart';
import 'package:json_api/src/server/json_api_request.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/response_document_factory.dart';
import 'package:json_api/uri_design.dart';

/// HTTP handler
class RequestHandler<Request, Response> {
  /// Processes the incoming HTTP [request] and returns a response
  Future<Response> call(Request request) async {
    final uri = await _httpAdapter.getUri(request);
    final method = await _httpAdapter.getMethod(request);
    final requestBody = await _httpAdapter.getBody(request);
    final requestTarget = Target.of(uri, _design);
    final jsonApiRequest = requestTarget.getRequest(method);
    JsonApiResponse jsonApiResponse;
    try {
      final requestDoc = requestBody.isEmpty ? null : json.decode(requestBody);
      jsonApiResponse =
          await jsonApiRequest.call(_controller, requestDoc, request);
    } on JsonApiResponse catch (e) {
      jsonApiResponse = e;
    } on IncompleteRelationshipException {
      jsonApiResponse = JsonApiResponse.badRequest([
        JsonApiError(
            status: '400',
            title: 'Bad request',
            detail: 'Incomplete relationship object')
      ]);
    } on FormatException catch (e) {
      jsonApiResponse = JsonApiResponse.badRequest([
        JsonApiError(
            status: '400',
            title: 'Bad request',
            detail: 'Invalid JSON. ${e.message} at offset ${e.offset}')
      ]);
    } on DocumentException catch (e) {
      jsonApiResponse = JsonApiResponse.badRequest([
        JsonApiError(status: '400', title: 'Bad request', detail: e.message)
      ]);
    }
    final statusCode = jsonApiResponse.statusCode;
    final headers = jsonApiResponse.buildHeaders(_design);
    final responseDocument = jsonApiResponse.buildDocument(_docFactory, uri);
    return _httpAdapter.createResponse(
        statusCode, json.encode(responseDocument), headers);
  }

  /// Creates an instance of the handler.
  RequestHandler(this._httpAdapter, this._controller, this._design,
      {Pagination pagination})
      : _docFactory = ResponseDocumentFactory(_design,
            pagination: pagination ?? Pagination.none(),
            api: Api(version: '1.0'));
  final HttpAdapter<Request, Response> _httpAdapter;
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
