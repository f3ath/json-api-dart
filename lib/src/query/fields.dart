import 'package:json_api/src/query/query_parameters.dart';

class Fields with QueryParameters implements QueryParameters {
  static Fields fromUri(Uri uri) => Fields(uri.queryParameters
      .map((k, v) => MapEntry(_regex.firstMatch(k)?.group(1), v.split(',')))
        ..removeWhere((k, v) => k == null));

  Fields(Map<String, List<String>> fields) {
    _fields.addAll(fields);
  }

  static final _regex = RegExp(r'^fields\[(.+)\]$');

  final _fields = <String, List<String>>{};

  List<String> operator [](String key) => _fields[key];

  Map<String, String> get queryParameters =>
      _fields.map((k, v) => MapEntry('fields[$k]', v.join(',')));
}
