import 'package:json_api/src/query/query_parameters.dart';

class Fields extends QueryParameters {
  Fields(Map<String, List<String>> fields)
      : _fields = {...fields},
        super(fields.map((k, v) => MapEntry('fields[$k]', v.join(','))));

  static Fields fromUri(Uri uri) => Fields(uri.queryParameters
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v.split(',')))
        ..removeWhere((k, v) => k == null));

  List<String> operator [](String key) => _fields[key];

  static final _regex = RegExp(r'^fields\[(.+)\]$');

  final Map<String, List<String>> _fields;
}
