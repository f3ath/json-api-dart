mixin UriManipulation {
  Map<String, List<String>> get query;

  Uri addTo(Uri uri) {
    if (query.isEmpty) return uri;
    if (uri.queryParametersAll.isEmpty)
      return uri.replace(queryParameters: query);
    return uri.replace(
        queryParameters: {}..addAll(uri.queryParametersAll)..addAll(query));
  }
}
