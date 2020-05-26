import 'dart:collection';

import 'package:json_api/src/query/query_parameters.dart';

/// Query parameter defining inclusion of related resources.
/// @see https://jsonapi.org/format/#fetching-includes
class Include extends QueryParameters with IterableMixin<String> {
  /// Example:
  /// ```dart
  /// Include(['comments', 'comments.author']).addTo(url);
  /// ```
  /// encodes into
  /// ```
  /// ?include=comments,comments.author
  /// ```
  Include(Iterable<String> resources)
      : _resources = [...resources],
        super({'include': resources.join(',')});

  static Include fromUri(Uri uri) =>
      fromQueryParameters(uri.queryParametersAll);

  static Include fromQueryParameters(Map<String, List<String>> parameters) =>
      Include((parameters['include']?.expand((_) => _.split(',')) ?? []));

  @override
  Iterator<String> get iterator => _resources.iterator;

  final List<String> _resources;
}
