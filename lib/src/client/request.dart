import 'dart:convert';

import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/src/client/content_type.dart';
import 'package:json_api/src/http/method.dart';
import 'package:json_api/src/maybe.dart';

/// A JSON:API HTTP request builder
class JsonApiRequest {
  JsonApiRequest(this._method, {Object document})
      : _body = Maybe(document).map(jsonEncode).or('');

  JsonApiRequest.get() : this(Method.GET);

  JsonApiRequest.post([Object document])
      : this(Method.POST, document: document);

  JsonApiRequest.patch([Object document])
      : this(Method.PATCH, document: document);

  JsonApiRequest.delete([Object document])
      : this(Method.DELETE, document: document);

  final String _method;
  final String _body;
  final _headers = <String, String>{};
  QueryParameters _parameters = QueryParameters.empty();

  /// Adds headers to the request.
  void headers(Map<String, String> headers) {
    _headers.addAll(headers);
  }

  /// Adds the "include" query parameter
  void include(Iterable<String> items) {
    _parameters &= Include(items);
  }

  /// Converts to an HTTP request
  HttpRequest toHttp(Uri uri) =>
      HttpRequest(_method, _parameters.addToUri(uri), body: _body, headers: {
        ..._headers,
        'Accept': ContentType.jsonApi,
        if (_body.isNotEmpty) 'Content-Type': ContentType.jsonApi
      });
}
