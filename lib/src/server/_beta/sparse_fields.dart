import 'package:json_api/src/server/uri_manipulation.dart';

class SparseFields with UriManipulation {
  static final delimiter = ',';
  static final key = 'fields';
  static final regex = RegExp(r'^fields\[(.+)\]$');
  final fields = <String, List<String>>{};

  SparseFields(Map<String, List<String>> fields) {
    this.fields.addAll(fields);
  }

  get query => Map.fromEntries(fields.entries
      .map((_) => MapEntry('${key}[${_.key}]', [_.value.join(delimiter)])));

  static SparseFields fromQuery(Map<String, List<String>> query) =>
      SparseFields(Map.fromEntries(query.entries.expand((entry) {
        final match = regex.firstMatch(entry.key);
        if (match == null) return [];
        final name = match.group(1);
        final fields = entry.value.expand((_) => _.split(delimiter)).toList();
        return [MapEntry(name, fields)];
      })));
}
