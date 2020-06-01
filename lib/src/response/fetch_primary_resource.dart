import 'dart:convert';

import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identity_collection.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_with_identity.dart';
import 'package:json_api_common/http.dart';

class FetchPrimaryResource {
  FetchPrimaryResource(this.resource,
      {Iterable<ResourceWithIdentity> included = const [],
      Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = IdentityCollection(included ?? const []);

  static FetchPrimaryResource decode(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return FetchPrimaryResource(
        document
            .get('data')
            .map(ResourceWithIdentity.fromJson)
            .orThrow(() => ArgumentError('Invalid response')),
        included: IdentityCollection(document.included().or([])),
        links: document.links().or(const {}));
  }

  final ResourceWithIdentity resource;
  final IdentityCollection included;
  final Map<String, Link> links;
}
