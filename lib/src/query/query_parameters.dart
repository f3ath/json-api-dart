/// This class and its descendants describe the query parameters recognized
/// by JSON:API.
class QueryParameters {
  final Map<String, String> _parameters;

  QueryParameters(Map<String, String> parameters)
      : _parameters = {...parameters};

  bool get isEmpty => _parameters.isEmpty;

  bool get isNotEmpty => _parameters.isNotEmpty;

  Uri addToUri(Uri uri) => isEmpty
      ? uri
      : uri.replace(queryParameters: {...uri.queryParameters, ..._parameters});

  QueryParameters merge(QueryParameters moreParameters) =>
      QueryParameters({..._parameters, ...moreParameters._parameters});

  /// A shortcut for [merge]
  QueryParameters operator &(QueryParameters moreParameters) =>
      merge(moreParameters);
}
