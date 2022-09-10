import 'package:json_api/http.dart';
import 'package:json_api/src/client/disposable_handler.dart';
import 'package:json_api/src/client/request.dart';
import 'package:json_api/src/client/response.dart';

/// A basic JSON:API client.
///
/// The JSON:API [Request] is converted to [HttpRequest] and sent downstream
/// using the [handler]. Received [HttpResponse] is then converted back to
/// JSON:API [Response]. JSON conversion is performed by the [codec].
class Client {
  const Client(
      {PayloadCodec codec = const PayloadCodec(),
      HttpHandler handler = const DisposableHandler()})
      : _codec = codec,
        _http = handler;

  final HttpHandler _http;
  final PayloadCodec _codec;

  /// Sends the [request] to the given [uri].
  Future<Response> send(Uri uri, Request request) async {
    final body = await _encode(request.document);
    final response = await _http.handle(HttpRequest(
        request.method,
        request.query.isEmpty
            ? uri
            : uri.replace(queryParameters: request.query.toQuery()),
        body: body)
      ..headers.addAll({
        'Accept': mediaType,
        if (body.isNotEmpty) 'Content-Type': mediaType,
        ...request.headers
      }));

    final document = await _decode(response);
    return Response(response, document);
  }

  Future<String> _encode(Object? doc) async =>
      doc == null ? '' : await _codec.encode(doc);

  Future<Map?> _decode(HttpResponse response) async =>
      response.hasDocument ? await _codec.decode(response.body) : null;
}
