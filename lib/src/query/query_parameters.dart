/// This class and its descendants describe the query parameters recognized
/// by JSON:API.
class QueryParameters {
  QueryParameters(Map<String, String> parameters)
      : _parameters = {...parameters};

  bool get isEmpty => _parameters.isEmpty;

  bool get isNotEmpty => _parameters.isNotEmpty;

  /// Adds (or replaces) this parameters to the [uri].
  Uri addToUri(Uri uri) => isEmpty
      ? uri
      : uri.replace(queryParameters: {...uri.queryParameters, ..._parameters});

  /// Merges this parameters with [other] parameters. Returns a new instance.
  QueryParameters merge(QueryParameters other) =>
      QueryParameters({..._parameters, ...other._parameters});

  /// A shortcut for [merge]
  QueryParameters operator &(QueryParameters moreParameters) =>
      merge(moreParameters);

  final Map<String, String> _parameters;
}
