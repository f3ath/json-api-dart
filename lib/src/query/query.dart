/// An object which can be encoded to query parameters.
abstract class Query {
  /// Query parameters
  Map<String, List<String>> toQuery();
}
