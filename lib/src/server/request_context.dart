import 'dart:convert';

import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/response.dart';

class RequestContext {
  RequestContext(this._doc, this._uri);

  final DocumentFactory _doc;
  final UriFactory _uri;

  HttpResponse convert(Response r) {
    final document = r.document(_doc, _uri);
    return HttpResponse(r.status,
        body: document == null ? '' : jsonEncode(document),
        headers: r.headers(_uri));
  }
}
