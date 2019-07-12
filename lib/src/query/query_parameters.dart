abstract class QueryParameters {
  Map<String, String> get queryParameters;

  Uri addTo(Uri uri) => uri
      .replace(queryParameters: {...uri.queryParameters, ...queryParameters});
}
