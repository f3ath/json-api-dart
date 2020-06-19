import 'dart:convert';

import 'package:json_api/src/document.dart';
import 'package:json_api_common/document.dart';
import 'package:json_api_common/http.dart';
import 'package:maybe_just_nothing/maybe_just_nothing.dart';

class UpdateResource {
  UpdateResource(Resource resource, {Map<String, Link> links = const {}})
      : resource = Just(resource),
        links = Map.unmodifiable(links ?? const {});

  UpdateResource.empty()
      : resource = Nothing<Resource>(),
        links = const {};

  static UpdateResource decode(HttpResponse http) {
    if (http.body.isEmpty) {
      return UpdateResource.empty();
    }
    final document = Document(jsonDecode(http.body));
    return UpdateResource(
        document
            .get('data')
            .map(Resource.fromJson)
            .orThrow(() => ArgumentError('Invalid response')),
        links: document.links().or(const {}));
  }

  final Map<String, Link> links;
  final Maybe<Resource> resource;
}
