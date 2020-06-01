import 'dart:convert';

import 'package:json_api/json_api.dart';
import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/identity.dart';
import 'package:json_api/src/document/link.dart';
import 'package:json_api/src/document/resource_with_identity.dart';
import 'package:json_api_common/http.dart';

class CreateResource {
  CreateResource(this.resource, {Map<String, Link> links = const {}})
      : links = Map.unmodifiable(links ?? const {});

  static CreateResource decode(HttpResponse http) {
    final document = Document(jsonDecode(http.body));
    return CreateResource(
        document
            .get('data')
            .map(ResourceWithIdentity.fromJson)
            .orThrow(() => FormatException('Invalid response')),
        links: document.links().or(const {}));
  }

  final Map<String, Link> links;
  final ResourceWithIdentity resource;
}
