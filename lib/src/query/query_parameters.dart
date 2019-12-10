abstract class QueryParameters {
  Map<String, String> get queryParameters;

  Uri addToUri(Uri uri) => queryParameters.isEmpty
      ? uri
      : uri.replace(
          queryParameters: {...uri.queryParameters, ...queryParameters});

}
