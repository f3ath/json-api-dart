abstract class QueryParameters {
  Map<String, List<String>> encode();

  Uri addTo(Uri uri) =>
      uri.replace(queryParameters: {...uri.queryParameters, ...encode()});
}
