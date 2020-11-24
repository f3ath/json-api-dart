import 'dart:convert';

import 'package:json_api/handler.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/nullable.dart';
import 'package:json_api/src/server/json_api_response.dart';

/// Converts [JsonApiResponse] to [HttpResponse]
class JsonApiResponseEncoder<Rq> implements Handler<Rq, HttpResponse> {
  JsonApiResponseEncoder(this._handler);

  final Handler<Rq, JsonApiResponse> _handler;

  @override
  Future<HttpResponse> call(Rq request) async {
    final r = await _handler.call(request);
    final body = nullable(jsonEncode)(r.document) ?? '';
    final headers = {
      ...r.headers,
      if (body.isNotEmpty) 'Content-Type': MediaType.jsonApi
    };
    return HttpResponse(r.statusCode, body: body)..headers.addAll(headers);
  }
}
