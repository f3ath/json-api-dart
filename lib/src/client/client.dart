import 'package:json_api/http.dart';
import 'package:json_api/src/client/disposable_handler.dart';
import 'package:json_api/src/client/request.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/client/response/request_failure.dart';

/// A basic JSON:API client
class Client {
  const Client(
      {PayloadCodec codec = const PayloadCodec(),
        HttpHandler handler = const DisposableHandler()})
      : _codec = codec,
        _http = handler;

  final HttpHandler _http;
  final PayloadCodec _codec;

  /// Sends the [request] to the server.
  /// Throws a [RequestFailure] if the server responds with an error.
  Future<Response> send(Uri uri, Request request) async {
    final body = await _encode(request.document);
    final response = await _http.handle(HttpRequest(
        request.method,
        request.query.isEmpty
            ? uri
            : uri.replace(queryParameters: request.query),
        body: body)
      ..headers.addAll({
        'Accept': MediaType.jsonApi,
        if (body.isNotEmpty) 'Content-Type': MediaType.jsonApi,
        ...request.headers
      }));

    final json = await _decode(response);
    if (StatusCode(response.statusCode).isFailed) {
      throw RequestFailure(response, json);
    }
    return Response(response, json);
  }

  Future<String> _encode(Object? doc) async =>
      doc == null ? '' : await _codec.encode(doc);

  Future<Map?> _decode(HttpResponse response) async =>
      _isJsonApi(response) ? await _codec.decode(response.body) : null;

  /// True if body is not empty and Content-Type is application/vnd.api+json
  bool _isJsonApi(HttpResponse response) =>
      response.body.isNotEmpty &&
      (response.headers['Content-Type'] ?? '')
          .toLowerCase()
          .startsWith(MediaType.jsonApi);
}
