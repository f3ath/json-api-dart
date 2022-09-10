import 'package:json_api/src/query/query_encodable.dart';

/// Arbitrary query parameters.
class Query implements QueryEncodable {
  Query([Map<String, Iterable<String>> parameters = const {}]) {
    mergeMap(parameters);
  }

  final _parameters = <String, List<String>>{};

  /// Returns true if the collection is empty.
  get isEmpty => _parameters.isEmpty;

  /// Adds a new [value] for the [key].
  void addValue(String key, String value) {
    _parameters.putIfAbsent(key, () => []);
    _parameters[key]!.add(value);
  }

  /// Merges the query [parameters] into this object.
  void mergeMap(Map<String, Iterable<String>> parameters) {
    parameters.forEach((key, values) {
      for (final value in values) {
        addValue(key, value);
      }
    });
  }

  /// Merges parameters from another [encodable] into this object.
  void merge(QueryEncodable encodable) {
    mergeMap(encodable.toQuery());
  }

  /// Merges parameters from other [encodables] into this object.
  void mergeAll(Iterable<QueryEncodable> encodables) {
    encodables.forEach(merge);
  }

  @override
  Map<String, List<String>> toQuery() =>
      _parameters.map((key, value) => MapEntry(key, value.toList()));
}
