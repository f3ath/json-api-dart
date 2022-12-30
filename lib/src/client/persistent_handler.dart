import 'dart:convert';

import 'package:http/http.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/client/message_converter.dart';

/// Handler which relies on the built-in Dart HTTP client.
/// It is the developer's responsibility to instantiate the client and
/// call `close()` on it in the end pf the application lifecycle.
class PersistentHandler implements HttpHandler {
  /// Creates a new instance of the handler. Do not forget to call `close()` on
  /// the [client] when it's not longer needed.
  ///
  /// Use [messageConverter] to fine tune the HTTP request/response conversion.
  PersistentHandler(
      this.client,
      {@Deprecated('Deprecated in favor of MessageConverter.'
          ' To be removed in version 6.0.0')
          this.defaultEncoding = utf8,
      MessageConverter? messageConverter})
      : _converter = messageConverter ??
            MessageConverter(defaultResponseEncoding: defaultEncoding);

  final Client client;
  final Encoding defaultEncoding;
  final MessageConverter _converter;

  @override
  Future<HttpResponse> handle(HttpRequest request) async {
    final convertedRequest = _converter.request(request);
    final streamedResponse = await client.send(convertedRequest);
    final response = await Response.fromStream(streamedResponse);
    return _converter.response(response);
  }
}
