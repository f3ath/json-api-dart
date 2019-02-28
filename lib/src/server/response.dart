import 'dart:convert';

import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/error_document.dart';
import 'package:json_api/src/nullable.dart';

class ServerResponse {
  final String body;
  final int status;
  final headers = <String, String>{};

  ServerResponse(this.status, [Document document])
      : body = nullable(json.encode)(document);

  ServerResponse.ok(Document document) : this(200, document);

  ServerResponse.notFound(ErrorDocument document) : this(404, document);

  ServerResponse.created(Document document) : this(201, document);

  ServerResponse.noContent() : this(204);
}
