import 'package:json_api/src/server/uri_manipulation.dart';

class Sorting with UriManipulation {
  static final delimiter = ',';
  final fields = <SortField>[];

  Sorting(Iterable<SortField> fields) {
    this.fields.addAll(fields);
  }

  get query => {
        'sort': [fields.join(delimiter)]
      };

  static Sorting fromQuery(Map<String, List<String>> query) =>
      Sorting(query['sort']
          .expand((_) => _.split(delimiter))
          .map(SortField.fromString));
}

class SortField {
  final String name;
  final bool ascending;

  SortField(this.name, {this.ascending = true});

  bool get descending => !ascending;

  static SortField asc(String name) => SortField(name);

  static SortField desc(String name) => SortField(name, ascending: false);

  static SortField fromString(String name) => name.startsWith('-')
      ? SortField(name.substring(1), ascending: false)
      : SortField(name);

  @override
  String toString() => (descending ? '-' : '') + name;
}
