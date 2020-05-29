import 'dart:convert';

import 'package:json_api/src/content_type.dart';
import 'package:json_api_common/query.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

/// A JSON:API HTTP request.
class JsonApiRequest {
  /// Created an instance of JSON:API HTTP request.
  ///
  /// - [method] - the HTTP method
  /// - [document] - if passed, will be JSON-encoded and sent in the HTTP body
  /// - [headers] - any arbitrary HTTP headers
  /// - [include] - related resources to include (for GET requests)
  /// - [fields] - sparse fieldsets (for GET requests)
  /// - [sort] - sorting options (for GET collection requests)
  /// - [page] - pagination options (for GET collection requests)
  /// - [query] - any arbitrary query parameters (for GET requests)
  JsonApiRequest(String method,
      {Object document,
      Map<String, String> headers,
      Iterable<String> include,
      Map<String, List<String>> fields,
      Iterable<String> sort,
      Map<String, String> page,
      Map<String, String> query})
      : method = method.toLowerCase(),
        body = Maybe(document).map(jsonEncode).or(''),
        query = Map.unmodifiable({
          if (include != null) ...Include(include).asQueryParameters,
          if (fields != null) ...Fields(fields).asQueryParameters,
          if (sort != null) ...Sort(sort).asQueryParameters,
          if (page != null) ...Page(page).asQueryParameters,
          ...?query,
        }),
        headers = Map.unmodifiable({
          'accept': ContentType.jsonApi,
          if (document != null) 'content-type': ContentType.jsonApi,
          ...?headers,
        });

  /// HTTP method, lowercase.
  final String method;

  /// HTTP body.
  final String body;

  /// HTTP headers.
  final Map<String, String> headers;

  /// Map of query parameters.
  final Map<String, String> query;
}
