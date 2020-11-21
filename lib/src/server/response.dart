import 'dart:convert';

import 'package:json_api/http.dart';
import 'package:json_api/src/document/one.dart';
import 'package:json_api/src/nullable.dart';

/// JSON:API response
class Response extends HttpResponse {
  Response(int statusCode,
      {Object /*?*/ document, Map<String, String> headers = const {}})
      : super(statusCode, body: nullable(jsonEncode)(document) ?? '', headers: {
          ...headers,
          if (document != null) 'content-type': MediaType.jsonApi
        });

  Response.ok(Object document) : this(200, document: document);

  Response.noContent() : this(204);

  Response.notFound({Object /*?*/ document}) : this(404, document: document);

  Response.created(Object document, {String location = ''})
      : this(201,
            document: document,
            headers: {if (location.isNotEmpty) 'location': location});
}
