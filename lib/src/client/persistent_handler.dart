import 'dart:convert';

import 'package:http/http.dart';
import 'package:http_interop_http/http_interop_http.dart';

/// Handler which relies on the built-in Dart HTTP client.
/// It is the developer's responsibility to instantiate the client and
/// call `close()` on it in the end pf the application lifecycle.
class PersistentHandler extends HandlerWrapper {
  /// Creates a new instance of the handler. Do not forget to call `close()` on
  /// the [client] when it's not longer needed.
  ///
  /// Use [messageConverter] to fine tune the HTTP request/response conversion.
  PersistentHandler(Client client,
      {@Deprecated('Deprecated in favor of MessageConverter.'
          ' To be removed in version 6.0.0')
          this.defaultEncoding = utf8,
      MessageConverter? messageConverter})
      : super(client,
            messageConverter: messageConverter ??
                MessageConverter(defaultResponseEncoding: defaultEncoding));

  final Encoding defaultEncoding;
}
