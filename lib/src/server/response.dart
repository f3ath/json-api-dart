import 'dart:convert';

import 'package:json_api/src/transport/error_document.dart';
import 'package:json_api/src/transport/error_object.dart';

class ServerResponse {
  final String body;
  final int status;

  ServerResponse(this.status, {this.body});

  ServerResponse.ok([Object doc])
      : this(200, body: doc != null ? json.encode(doc) : null);

  ServerResponse.notFound({List<ErrorObject> errors = const []})
      : this(404, body: json.encode(ErrorDocument(errors)));
}
