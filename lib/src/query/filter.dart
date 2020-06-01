import 'package:json_api/src/query/query_parameters.dart';

/// Query parameters defining Filter
/// @see https://jsonapi.org/recommendations/#filtering
class Filter extends QueryParameters {
  /// The [filter] argument maps the resource type to a list of filters.
  ///
  /// Example:
  /// ```dart
  /// Filter({'articles': ['title', 'body'], 'people': ['name']}).addTo(url);
  /// ```
  /// encodes to
  /// ```
  /// ?filter[articles]=title,body&filter[people]=name
  /// ```
  Filter(Map<String, List<String>> filter)
      : _filter = {...filter},
        super(filter.map((k, v) => MapEntry('filter[$k]', v.join(','))));

  /// Extracts the requested filter from the [uri].
  static Filter fromUri(Uri uri) => Filter(uri.queryParameters
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v.split(',')))
        ..removeWhere((k, v) => k == null));

  List<String> operator [](String key) => _filter[key];

  static final _regex = RegExp(r'^filter\[(.+)\]$');

  final Map<String, List<String>> _filter;
}
