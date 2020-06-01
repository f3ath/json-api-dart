import 'dart:collection';
import 'dart:convert';

import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identity_collection.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_with_identity.dart';
import 'package:json_api_common/http.dart';

class FetchCollection with IterableMixin<ResourceWithIdentity> {
  FetchCollection(
      {Iterable<ResourceWithIdentity> resources = const [],
      Iterable<ResourceWithIdentity> included = const [],
      Map<String, Link> links = const {}})
      : resources = resources ?? IdentityCollection(const []),
        links = Map.unmodifiable(links ?? const {}),
        included = included ?? IdentityCollection(const []);

  static FetchCollection decode(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return FetchCollection(
        resources: IdentityCollection(document
            .get('data')
            .cast<List>()
            .map((_) => _.map(ResourceWithIdentity.fromJson))
            .or(const [])),
        included: IdentityCollection(document.included().or([])),
        links: document.links().or(const {}));
  }

  final IdentityCollection<ResourceWithIdentity> resources;
  final IdentityCollection<ResourceWithIdentity> included;
  final Map<String, Link> links;

  @override
  Iterator<ResourceWithIdentity> get iterator => resources.iterator;
}
