import 'dart:collection';

class Filter with MapMixin<String, dynamic> {
  /// Example:
  /// ```dart
  /// Filter({'post': '1,2', 'author': {'id': '12', 'role': 'admin'}}).addTo(url);
  /// ```
  /// encodes into
  /// ```
  /// ?filter[post]=1,2&filter[author][id]=12&filter[author][role]=admin
  /// ```
  Filter([Map<String, dynamic> parameters = const {}]) {
    addAll(parameters);
  }

  static Filter fromUri(Uri uri) {
    Map<String, dynamic> filters = {};
    uri.queryParametersAll.forEach((key, value) {
      if (_validationRegex.hasMatch(key)) {
        final matches = _extractionRegex.allMatches(key).toList();
        _convertToMapAndMerge(matches, filters, value.last);
      }
    });
    return Filter(filters);
  }

  static void _convertToMapAndMerge(
    List<RegExpMatch> matches,
    Map<String, dynamic> destination,
    String value,
  ) {
    final key = matches[0].group(1) ?? '';
    if (key.isNotEmpty) {
      if (matches.length == 1) {
        destination[key] = value;
        return;
      }
      if (!destination.containsKey(key)) {
        destination[key] = <String, dynamic>{};
      }
      _convertToMapAndMerge(matches.sublist(1), destination[key], value);
    }
  }

  static final _validationRegex = RegExp(r'^filter(?:\[[^\[\]]+\])+$');
  static final _extractionRegex = RegExp(r'\[([^\[\]]+)\]');

  final _ = <String, dynamic>{};

  /// Converts to a map of query parameters
  Map<String, String> get asQueryParameters => _flattenFiltersMap(_);

  Map<String, String> _flattenFiltersMap(Map<String, dynamic> filters,
      [String keyPrefix = 'filter']) {
    final queryParameters = <String, String>{};
    filters.forEach((key, value) {
      final keyWithPrefix = '$keyPrefix[$key]';
      if (value is String) {
        queryParameters[keyWithPrefix] = value;
      } else if (value is Map<String, dynamic>) {
        queryParameters.addAll(_flattenFiltersMap(value, keyWithPrefix));
      }
    });
    return queryParameters;
  }

  @override
  dynamic operator [](Object? key) => _[key];

  @override
  void operator []=(String key, dynamic value) {
    if (value is! String && value is! Map<String, dynamic>) {
      throw ArgumentError(
        'Filter value must have a type of String or Map<String, dynamic>',
        'value',
      );
    }
    _[key] = value;
  }

  @override
  void clear() => _.clear();

  @override
  Iterable<String> get keys => _.keys;

  @override
  String? remove(Object? key) => _.remove(key);
}
