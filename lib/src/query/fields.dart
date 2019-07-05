class Fields {
  static final _regex = RegExp(r'^fields\[(.+)\]$');

  final _fields = <String, List<String>>{};

  Fields(Map<String, List<String>> fields) {
    _fields.addAll(fields);
  }

  factory Fields.decode(Map<String, List<String>> queryParameters) {
    return Fields(queryParameters.map(
        (k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v.first.split(',')))
      ..removeWhere((k, v) => k == null));
  }

  List<String> operator [](String key) => _fields[key];
}
