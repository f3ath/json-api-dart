import 'dart:convert';

import 'package:json_api/src/document.dart';
import 'package:json_api_common/http.dart';

class DeleteResource {
  DeleteResource({Map<String, Object> meta = const {}})
      : meta = Map.unmodifiable(meta ?? const {});

  static DeleteResource decode(HttpResponse http) => DeleteResource(
      meta: http.body.isEmpty
          ? const {}
          : Document(jsonDecode(http.body)).meta().or(const {}));

  final Map<String, Object> meta;
}
