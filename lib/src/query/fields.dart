import 'package:json_api/src/query/query_parameters.dart';

class Fields extends QueryParameters {
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

  @override
  Map<String, List<String>> encode() {
    return _fields.map((k, v) => MapEntry('fields[$k]', [v.join(',')]));
  }
}
