import 'dart:convert';

import 'package:json_api/document.dart';

class ServerResponse {
  final String body;
  final int status;

  ServerResponse(this.status, {this.body});

  ServerResponse.ok([Document doc])
      : this(200, body: doc != null ? json.encode(doc) : null);
}
