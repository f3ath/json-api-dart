import 'package:json_api/src/query/query_parameters.dart';

/// Query parameters defining the pagination data.
/// @see https://jsonapi.org/format/#fetching-pagination
class Page extends QueryParameters {
  /// Example:
  /// ```dart
  /// Page({'limit': '10', 'offset': '20'}).addTo(url);
  /// ```
  /// encodes into
  /// ```
  /// ?page[limit]=10&page[offset]=20
  /// ```
  ///
  Page(Map<String, String> parameters)
      : _parameters = {...parameters},
        super(parameters.map((k, v) => MapEntry('page[${k}]', v)));

  static Page fromUri(Uri uri) => Page(uri.queryParameters
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v))
        ..removeWhere((k, v) => k == null));

  String operator [](String key) => _parameters[key];

  static final _regex = RegExp(r'^page\[(.+)\]$');

  final Map<String, String> _parameters;
}
