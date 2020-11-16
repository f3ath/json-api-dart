import 'dart:collection';

/// Query parameter defining inclusion of related resources.
/// @see https://jsonapi.org/format/#fetching-includes
class Include with IterableMixin<String> {
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
  Map<String, String> get asQueryParameters => {'include': join(',')};

  @override
  Iterator<String> get iterator => _.iterator;

  @override
  int get length => _.length;
}
