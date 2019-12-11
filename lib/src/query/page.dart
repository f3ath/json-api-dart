import 'package:json_api/src/query/query_parameters.dart';

/// The "page" query parameters
class Page extends QueryParameters {
  static final _regex = RegExp(r'^page\[(.+)\]$');

  Page(Map<String, String> parameters)
      : _parameters = {...parameters},
        super(parameters.map((k, v) => MapEntry('page[${k}]', v)));

  static Page fromUri(Uri uri) => Page(uri.queryParameters
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v))
        ..removeWhere((k, v) => k == null));

  String operator [](String key) => _parameters[key];

  final Map<String, String> _parameters;
}
