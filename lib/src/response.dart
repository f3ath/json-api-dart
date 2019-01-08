import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/src/exceptions.dart';
import 'package:json_api_document/json_api_document.dart';

/// A result of a fetch() request.
class Response {
  final Document document;
  final int status;
  final Map<String, String> headers;

  Response(http.Response r, {bool preferResource = false})
      : status = r.statusCode,
        headers = r.headers,
        document = r.contentLength > 0
            ? Document.fromJson(json.decode(r.body),
                preferResource: preferResource)
            : null {
    const contentType = 'content-type';
    if (headers.containsKey(contentType) &&
        headers[contentType].startsWith(Document.mediaType)) return;

    throw InvalidContentTypeException(headers[contentType]);
  }

  String get location => headers['location'];
}
