import 'dart:convert';

import 'package:json_api/src/document.dart';
import 'package:json_api/src/identity_collection.dart';
import 'package:json_api_common/document.dart';
import 'package:json_api_common/http.dart';

class FetchPrimaryResource {
  FetchPrimaryResource(this.resource,
      {Iterable<Resource> included = const [],
      Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = IdentityCollection(included ?? const []);

  static FetchPrimaryResource decode(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return FetchPrimaryResource(
        document
            .get('data')
            .map(Resource.fromJson)
            .orThrow(() => ArgumentError('Invalid response')),
        included: IdentityCollection(document.included().or([])),
        links: document.links().or(const {}));
  }

  final Resource resource;
  final IdentityCollection included;
  final Map<String, Link> links;
}
