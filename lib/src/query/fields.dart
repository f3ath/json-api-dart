import 'package:json_api/src/query/query_parameters.dart';

/// Query parameters defining Sparse Fieldsets
/// @see https://jsonapi.org/format/#fetching-sparse-fieldsets
class Fields extends QueryParameters {
  /// The [fields] argument maps the resource type to a list of fields.
  ///
  /// Example:
  /// ```dart
  /// Fields({'articles': ['title', 'body'], 'people': ['name']}).addTo(url);
  /// ```
  /// encodes to
  /// ```
  /// ?fields[articles]=title,body&fields[people]=name
  /// ```
  Fields(Map<String, List<String>> fields)
      : _fields = {...fields},
        super(fields.map((k, v) => MapEntry('fields[$k]', v.join(','))));

  /// Extracts the requested fields from the [uri].
  static Fields fromUri(Uri uri) => fromQueryParameters(uri.queryParametersAll);

  /// Extracts the requested fields from [queryParameters].
  static Fields fromQueryParameters(
          Map<String, List<String>> queryParameters) =>
      Fields(queryParameters.map((k, v) => MapEntry(
          _regex.firstMatch(k)?.group(1),
          v.expand((_) => _.split(',')).toList()))
        ..removeWhere((k, v) => k == null));

  List<String> operator [](String key) => _fields[key];

  static final _regex = RegExp(r'^fields\[(.+)\]$');

  final Map<String, List<String>> _fields;
}
