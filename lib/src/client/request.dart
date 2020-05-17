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

  /// Requests inclusion of related resources.
  ///
  /// See https://jsonapi.org/format/#fetching-includes
  void include(Iterable<String> items) {
    _parameters &= Include(items);
  }

  /// Requests collection sorting.
  ///
  /// See https://jsonapi.org/format/#fetching-sorting
  void sort(Iterable<String> sort) {
    _parameters &= Sort(sort.map(SortField.parse));
  }

  /// Requests a specific page.
  ///
  /// See https://jsonapi.org/format/#fetching-pagination
  void page(Map<String, String> page){
    _parameters &= Page(page);
  }

  /// Requests sparse fieldsets.
  ///
  /// See https://jsonapi.org/format/#fetching-sparse-fieldsets
  void fields(Map<String, Iterable<String>> fields) {
    _parameters &= Fields(fields);
  }

  /// Sets arbitrary query parameters.
  void parameters(Map<String, String> parameters) {
    _parameters &= QueryParameters(parameters);
  }

  /// Converts to an HTTP request
  HttpRequest toHttp(Uri uri) =>
      HttpRequest(_method, _parameters.addToUri(uri), body: _body, headers: {
        ..._headers,
        'Accept': ContentType.jsonApi,
        if (_body.isNotEmpty) 'Content-Type': ContentType.jsonApi
      });
}
