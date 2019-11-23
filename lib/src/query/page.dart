/// The "page" query parameters
class Page {
  static final _regex = RegExp(r'^page\[(.+)\]$');

  final _params = <String, String>{};

  Page(Map<String, String> parameters) {
    this._params.addAll(parameters);
  }

  static Page fromUri(Uri uri) => Page(uri.queryParameters
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v))
        ..removeWhere((k, v) => k == null));

  Map<String, String> encode() =>
      _params.map((k, v) => MapEntry('page[${k}]', v));

  String operator [](String key) => _params[key];

  Uri addTo(Uri uri) =>
      uri.replace(queryParameters: {...uri.queryParameters, ...encode()});
}
