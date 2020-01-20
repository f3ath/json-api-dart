import 'dart:async';

import 'package:json_api/query.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:shelf/shelf.dart' as shelf;

import 'colors.dart';

class PaginatingController extends JsonApiControllerBase<shelf.Request> {
  final Pagination _pagination;

  PaginatingController(this._pagination);

  @override
  FutureOr<JsonApiResponse> fetchCollection(
      shelf.Request request, String type) {
    final page = Page.fromUri(request.requestedUri);
    final offset = _pagination.offset(page);
    final limit = _pagination.limit(page);
    return JsonApiResponse.collection(colors.values.skip(offset).take(limit),
        total: colors.length);
  }
}
