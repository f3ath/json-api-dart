import 'dart:convert';

import 'package:json_api/routing.dart';
import 'package:json_api/src/nullable.dart';

/// JSON:API request consumed by the client
class Request {
  Request(this.method, this.target, {Object document})
      : body = nullable(jsonEncode)(document) ?? '';

  /// HTTP method
  final String method;

  /// Request target
  final Target target;

  /// Encoded document or an empty string.
  final String body;

  /// Any extra HTTP headers.
  final headers = <String, String>{};

  /// A list of dot-separated relationships to include.
  /// See https://jsonapi.org/format/#fetching-includes
  final include = <String>[];

  /// Sorting parameters.
  /// See https://jsonapi.org/format/#fetching-sorting
  final sort = <String>[];

  /// Sparse fieldsets.
  /// See https://jsonapi.org/format/#fetching-sparse-fieldsets
  final fields = <String, Iterable<String>>{};

  /// Pagination parameters.
  /// See https://jsonapi.org/format/#fetching-pagination
  final page = <String, String>{};

  /// Response filtering.
  /// https://jsonapi.org/format/#fetching-filtering
  final filter = <String, String>{};

  /// Any general query parameters.
  /// If passed, this parameter will override other parameters set through
  /// [include], [sort], [fields], [page], and [filter].
  final query = <String, String>{};
}
