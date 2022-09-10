/// Arbitrary query parameters.
abstract class QueryEncodable {
  /// Returns the map representing query parameters.
  /// Each key may have zero or more values.
  /// `{'foo': ['bar', 'baz']}` represents `?foo=bar&foo=baz`
  Map<String, List<String>> toQuery();
}
