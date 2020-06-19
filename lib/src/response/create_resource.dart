import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:json_api/src/document.dart';
import 'package:json_api_common/document.dart';
import 'package:json_api_common/http.dart';

class CreateResource {
  CreateResource(this.resource, {Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {});

  static CreateResource decode(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return CreateResource(
        document
            .get('data')
            .map(Resource.fromJson)
            .orThrow(() => FormatException('Invalid response')),
        links: document.links().or(const {}));
  }

  final Map<String, Link> links;
  final Resource resource;
}
