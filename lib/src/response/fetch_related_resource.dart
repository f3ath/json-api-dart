import 'dart:convert';

import 'package:json_api/src/document.dart';
import 'package:json_api/src/identity_collection.dart';
import 'package:json_api_common/document.dart';
import 'package:json_api_common/http.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class FetchRelatedResource {
  FetchRelatedResource(this.resource,
      {IdentityCollection included, Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {}),
        included = included ?? IdentityCollection(const []);

  static FetchRelatedResource decode(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return FetchRelatedResource(document.get('data').map(Resource.fromJson),
        included: IdentityCollection(document.included().or([])),
        links: document.links().or(const {}));
  }

  final Maybe<Resource> resource;
  final IdentityCollection included;
  final Map<String, Link> links;
}
