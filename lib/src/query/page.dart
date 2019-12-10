import 'package:json_api/src/query/query_parameters.dart';

/// The "page" query parameters
class Page with QueryParameters implements QueryParameters {
  static final _regex = RegExp(r'^page\[(.+)\]$');

  final _params = <String, String>{};

  Page(Map<String, String> parameters) {
    this._params.addAll(parameters);
  }

  static Page fromUri(Uri uri) => Page(uri.queryParameters
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v))
        ..removeWhere((k, v) => k == null));

  Map<String, String> get queryParameters =>
      _params.map((k, v) => MapEntry('page[${k}]', v));

  String operator [](String key) => _params[key];
}
