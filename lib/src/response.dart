import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:json_api/src/exceptions.dart';
import 'package:json_api_document/json_api_document.dart';

/// A response from a JSON:API server.
///
/// The client wraps the responses from JSON:API server in a [Response] class.
/// This class contains the decoded JSON:API document (if any) and other details
/// such as HTTP status code and HTTP headers.
class Response {
  /// JSON:API document returned by the server.
  ///
  /// May be null if the body is empty.
  final Document document;
  /// HTTP status code
  final int status;
  /// HTTP headers
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

  /// The "Location:" headers (if provided).
  ///
  /// This header comes with "201 Created" responses".
  /// More details: https://jsonapi.org/format/#crud-creating-responses-201
  String get location => headers['location'];
}
