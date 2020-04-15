import 'dart:convert';

import 'package:json_api/http.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/route.dart';
import 'package:json_api/src/server/target.dart';

class Request<T extends CollectionTarget> {
  Request(this.httpRequest, this.route)
      : sort = Sort.fromUri(httpRequest.uri),
        include = Include.fromUri(httpRequest.uri),
        page = Page.fromUri(httpRequest.uri);

  final HttpRequest httpRequest;
  final Include include;
  final Page page;
  final Sort sort;
  final Route<T> route;

  T get target => route.target;

  Object decodePayload() => jsonDecode(httpRequest.body);

  bool get isCompound => include.isNotEmpty;

  /// Generates the 'self' link preserving original query parameters
  Uri generateSelfUri(UriFactory factory) =>
      httpRequest.uri.queryParameters.isNotEmpty
          ? route
              .self(factory)
              .replace(queryParameters: httpRequest.uri.queryParametersAll)
          : route.self(factory);
}
