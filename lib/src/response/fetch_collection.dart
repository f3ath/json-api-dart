import 'dart:collection';
import 'dart:convert';

import 'package:json_api/src/document.dart';
import 'package:json_api/src/identity_collection.dart';
import 'package:json_api_common/document.dart';
import 'package:json_api_common/http.dart';

class FetchCollection with IterableMixin<Resource> {
  FetchCollection(
      {Iterable<Resource> resources = const [],
      Iterable<Resource> included = const [],
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
            .map((_) => _.map(Resource.fromJson))
            .or(const [])),
        included: IdentityCollection(document.included().or([])),
        links: document.links().or(const {}));
  }

  final IdentityCollection<Resource> resources;
  final IdentityCollection<Resource> included;
  final Map<String, Link> links;

  @override
  Iterator<Resource> get iterator => resources.iterator;
}
