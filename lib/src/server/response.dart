import 'dart:convert';

class ServerResponse {
  final String body;
  final int status;

  ServerResponse(this.status, {this.body});

  ServerResponse.ok([Object doc])
      : this(200, body: doc != null ? json.encode(doc) : null);

  ServerResponse.notFound() : this(400);
}
