import 'dart:convert';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart' as i;
import 'package:json_api/src/client/payload_codec.dart';
import 'package:json_api/src/client/request.dart';
import 'package:json_api/src/client/response.dart';
import 'package:json_api/src/media_type.dart';

/// A basic JSON:API client.
///
/// The JSON:API [Request] is converted to [HttpRequest] and sent downstream
/// using the [_handler]. Received [HttpResponse] is then converted back to
/// JSON:API [Response]. JSON conversion is performed by the [codec].
class Client {
  const Client(this._handler, {PayloadCodec codec = const PayloadCodec()})
      : _codec = codec;

  final i.Handler _handler;
  final PayloadCodec _codec;

  /// Sends the [request] to the given [uri].
  Future<Response> send(Uri uri, Request request) async {
    final json = await _encode(request.document);
    final body = i.Body.text(json, utf8);
    final headers = i.Headers.from({
      'Accept': [mediaType],
      if (json.isNotEmpty) 'Content-Type': [mediaType],
      ...request.headers
    });
    final url = request.query.isEmpty
        ? uri
        : uri.replace(queryParameters: request.query.toQuery());
    final response =
        await _handler(i.Request(request.method, url, body, headers));

    final document = await _decode(response);
    return Response(response, document);
  }

  Future<String> _encode(Object? doc) async =>
      doc == null ? '' : await _codec.encode(doc);

  Future<Map?> _decode(i.Response response) async {
    final json = await response.body.decode(utf8);
    if (json.isNotEmpty &&
        response.headers['Content-Type']?.last
                .toLowerCase()
                .startsWith(mediaType) ==
            true) {
      return await _codec.decode(json);
    }
    return null;
  }
}
