import 'dart:convert';

import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_with_identity.dart';
import 'package:json_api_common/http.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class UpdateResource {
  UpdateResource(ResourceWithIdentity resource,
      {Map<String, Link> links = const {}})
      : resource = Just(resource),
        links = Map.unmodifiable(links ?? const {});

  UpdateResource.empty()
      : resource = Nothing<ResourceWithIdentity>(),
        links = const {};

  static UpdateResource decode(HttpResponse http) {
    if (http.body.isEmpty) {
      return UpdateResource.empty();
    }
    final document = Document(jsonDecode(http.body));
    return UpdateResource(
        document
            .get('data')
            .map(ResourceWithIdentity.fromJson)
            .orThrow(() => ArgumentError('Invalid response')),
        links: document.links().or(const {}));
  }

  final Map<String, Link> links;
  final Maybe<ResourceWithIdentity> resource;
}
