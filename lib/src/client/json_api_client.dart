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

  /// Sends the [request] to the server.
  /// Returns the response when the server responds with a JSON:API document.
  /// Throws a [RequestFailure] if the server responds with a JSON:API error.
  /// Throws a [ServerError] if the server responds with a non-JSON:API error.
  Future<T> call<T>(JsonApiRequest<T> request) async {
    final response = await _http.call(_toHttp(request));
    if (!response.isSuccessful && !response.isPending) {
      throw RequestFailure(response,
          document: response.hasDocument
              ? InboundDocument.decode(response.body)
              : null);
    }
    return request.response(response);
  }

  HttpRequest _toHttp(JsonApiRequest request) {
    final headers = {'accept': MediaType.jsonApi};
    if (request.body.isNotEmpty) {
      headers['content-type'] = MediaType.jsonApi;
    }
    headers.addAll(request.headers);
    return HttpRequest(request.method, request.uri(_uriFactory),
        body: request.body, headers: headers);
  }
}
