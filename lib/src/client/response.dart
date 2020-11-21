import 'package:json_api/http.dart';

/// A response sent by the server
class Response {
  Response(this.http);

  static Response decode(HttpResponse response) {
    return Response(response);
  }

  final HttpResponse http;
}
