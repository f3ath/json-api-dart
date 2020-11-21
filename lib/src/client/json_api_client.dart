import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/json_api_request.dart';
import 'package:json_api/src/client/request_failure.dart';
import 'package:json_api/src/http/media_type.dart';

/// The JSON:API client
class JsonApiClient {
  JsonApiClient(this._http, this._uriFactory);

  final HttpHandler _http;
  final UriFactory _uriFactory;

  // /// Adds identifiers to a to-many relationship
  // RelationshipResponse<Many> addMany(String type, String id,
  //     String relationship, List<Identifier> identifiers) async =>
  //     Request('post', RelationshipTarget(type, id, relationship),
  //         RelationshipResponse.decodeMany,
  //         document: OutboundDataDocument.many(Many(identifiers)));


  /// Sends the [request] to the server.
  /// Returns the response when the server responds with a JSON:API document.
  /// Throws a [RequestFailure] if the server responds with an error.
  Future<T> call<T>(JsonApiRequest<T> request) async {
    return request.response(await _call(request));
  }

  /// Sends the [request] to the server.
  /// Returns the response when the server responds with a JSON:API document.
  /// Throws a [RequestFailure] if the server responds with an error.
  Future<HttpResponse> _call<T>(JsonApiRequest<T> request) async {
    final response = await _http.call(_toHttp(request));
    if (!response.isSuccessful && !response.isPending) {
      throw RequestFailure(response,
          document: response.hasDocument
              ? InboundDocument.decode(response.body)
              : null);
    }
    return response;
  }

  HttpRequest _toHttp(JsonApiRequest request) {
    final headers = {'accept': MediaType.jsonApi};
    var body = '';
    if (request.document != null) {
      headers['content-type'] = MediaType.jsonApi;
      body = jsonEncode(request.document);
    }
    headers.addAll(request.headers);
    return HttpRequest(request.method, request.uri(_uriFactory),
        body: body, headers: headers);
  }
}
