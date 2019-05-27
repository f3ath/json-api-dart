import 'package:json_api/src/server/uri_manipulation.dart';

class PageParameters with UriManipulation {
  static final regex = RegExp(r'^page\[(.+)\]$');

  final parameters = <String, String>{};

  PageParameters(Map<String, String> parameters) {
    this.parameters.addAll(parameters);
  }

  get query => parameters.map((k, v) => MapEntry('page[${k}]', [v]));

  static PageParameters fromQuery(Map<String, List<String>> query) =>
      PageParameters(
          query.map((k, v) => MapEntry(regex.firstMatch(k)?.group(1), v.first))
            ..removeWhere((k, v) => k == null));
}
