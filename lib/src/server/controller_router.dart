import 'package:http_interop/http_interop.dart';
import 'package:http_parser/http_parser.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/errors/method_not_allowed.dart';
import 'package:json_api/src/server/errors/unacceptable.dart';
import 'package:json_api/src/server/errors/unmatched_target.dart';
import 'package:json_api/src/server/errors/unsupported_media_type.dart';

class ControllerRouter implements HttpHandler {
  ControllerRouter(this._controller, this._matchTarget);

  final Controller _controller;
  final Target? Function(Uri uri) _matchTarget;

  @override
  Future<HttpResponse> handle(HttpRequest request) async {
    _validate(request);
    final target = _matchTarget(request.uri);
    if (target is RelationshipTarget) {
      if (request.isGet) {
        return await _controller.fetchRelationship(request, target);
      }
      if (request.isPost) {
        return await _controller.addMany(request, target);
      }
      if (request.isPatch) {
        return await _controller.replaceRelationship(request, target);
      }
      if (request.isDelete) {
        return await _controller.deleteMany(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    if (target is RelatedTarget) {
      if (request.isGet) {
        return await _controller.fetchRelated(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    if (target is ResourceTarget) {
      if (request.isGet) {
        return await _controller.fetchResource(request, target);
      }
      if (request.isPatch) {
        return await _controller.updateResource(request, target);
      }
      if (request.isDelete) {
        return await _controller.deleteResource(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    if (target is Target) {
      if (request.isGet) {
        return await _controller.fetchCollection(request, target);
      }
      if (request.isPost) {
        return await _controller.createResource(request, target);
      }
      throw MethodNotAllowed(request.method);
    }
    throw UnmatchedTarget(request.uri);
  }

  void _validate(HttpRequest request) {
    final contentType = request.headers['Content-Type'];
    if (contentType != null && !_isValid(MediaType.parse(contentType))) {
      throw UnsupportedMediaType();
    }
    final accept = request.headers['Accept'];
    if (accept != null && !_isValid(MediaType.parse(accept))) {
      throw Unacceptable();
    }
  }

  bool _isValid(MediaType mediaType) {
    return mediaType.parameters.isEmpty; // TODO: check for ext and profile
  }
}
