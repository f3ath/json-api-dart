import 'dart:collection';

import 'package:json_api/src/query/query.dart';

/// Query parameter defining inclusion of related resources.
/// @see https://jsonapi.org/format/#fetching-includes
class Include with IterableMixin<String> implements Query {
  /// Example:
  /// ```dart
  /// Include(['comments', 'comments.author']);
  /// ```
  Include([Iterable<String> resources = const []]) {
    _.addAll(resources);
  }

  static Include fromUri(Uri uri) => Include(
      uri.queryParametersAll['include']?.expand((_) => _.split(',')) ?? []);

  final _ = <String>[];

  /// Converts to a map of query parameters
  @override
  Map<String, List<String>> toQuery() =>
      {if (isNotEmpty) 'include': [join(',')]};

  @override
  Iterator<String> get iterator => _.iterator;

  @override
  int get length => _.length;
}
