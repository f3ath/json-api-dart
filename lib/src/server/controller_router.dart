import 'package:http_interop/http_interop.dart';
import 'package:http_parser/http_parser.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/media_type.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/errors/method_not_allowed.dart';
import 'package:json_api/src/server/errors/unacceptable.dart';
import 'package:json_api/src/server/errors/unmatched_target.dart';
import 'package:json_api/src/server/errors/unsupported_media_type.dart';

class ControllerRouter {
  ControllerRouter(this._controller, this._matchTarget);

  final Controller _controller;
  final Target? Function(Uri uri) _matchTarget;

  Future<Response> handle(Request request) async {
    _validate(request);
    final target = _matchTarget(request.uri);
    return await switch (target) {
      RelationshipTarget() => switch (request.method) {
          'get' => _controller.fetchRelationship(request, target),
          'post' => _controller.addMany(request, target),
          'patch' => _controller.replaceRelationship(request, target),
          'delete' => _controller.deleteMany(request, target),
          _ => throw MethodNotAllowed(request.method)
        },
      RelatedTarget() => switch (request.method) {
          'get' => _controller.fetchRelated(request, target),
          _ => throw MethodNotAllowed(request.method)
        },
      ResourceTarget() => switch (request.method) {
          'get' => _controller.fetchResource(request, target),
          'patch' => _controller.updateResource(request, target),
          'delete' => _controller.deleteResource(request, target),
          _ => throw MethodNotAllowed(request.method)
        },
      Target() => switch (request.method) {
          'get' => _controller.fetchCollection(request, target),
          'post' => _controller.createResource(request, target),
          _ => throw MethodNotAllowed(request.method)
        },
      _ => throw UnmatchedTarget(request.uri)
    };
  }

  void _validate(Request request) {
    final contentType = request.headers.last('Content-Type');
    if (contentType != null && _isInvalid(MediaType.parse(contentType))) {
      throw UnsupportedMediaType();
    }
    if ((request.headers['Accept'] ?? [])
        .expand((it) => it.split(','))
        .map((it) => it.trim())
        .map(MediaType.parse)
        .any(_isInvalid)) {
      throw Unacceptable();
    }
  }

  bool _isInvalid(MediaType mt) =>
      mt.mimeType == mediaType &&
      mt.parameters.isNotEmpty; // TODO: check for ext and profile
}
