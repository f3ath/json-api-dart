import 'package:http_interop/http_interop.dart' as interop;
import 'package:http_interop_http/http_interop_http.dart' as http;
import 'package:json_api/src/client/payload_codec.dart';
import 'package:json_api/src/client/request.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/media_type.dart';

/// A basic JSON:API client.
///
/// The JSON:API [Request] is converted to [interop.Request] and sent downstream
/// using the [wrapped]. Received [interop.Response] is then converted back to
/// JSON:API [Response]. JSON conversion is performed by the [codec].
class Client {
  const Client(
      {PayloadCodec codec = const PayloadCodec(),
      interop.Handler handler = const http.DisposableHandler()})
      : _codec = codec,
        _http = handler;

  final interop.Handler _http;
  final PayloadCodec _codec;

  /// Sends the [request] to the given [uri].
  Future<Response> send(Uri uri, Request request) async {
    final body = await _encode(request.document);
    final response = await _http.handle(interop.Request(
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

  Future<Map?> _decode(interop.Response response) async =>
      (response.body.isNotEmpty &&
              (response.headers['Content-Type'] ?? '')
                  .toLowerCase()
                  .startsWith(mediaType))
          ? await _codec.decode(response.body)
          : null;
}
