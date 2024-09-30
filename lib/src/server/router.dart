import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/errors/method_not_allowed.dart';
import 'package:json_api/src/server/errors/unmatched_target.dart';

Handler router(Controller controller, Target? Function(Uri uri) matchTarget) =>
    (request) => switch (matchTarget(request.uri)) {
          RelationshipTarget target => switch (request.method) {
              'get' => controller.fetchRelationship(request, target),
              'post' => controller.addMany(request, target),
              'patch' => controller.replaceRelationship(request, target),
              'delete' => controller.deleteMany(request, target),
              _ => throw MethodNotAllowed(request.method)
            },
          RelatedTarget target => switch (request.method) {
              'get' => controller.fetchRelated(request, target),
              _ => throw MethodNotAllowed(request.method)
            },
          ResourceTarget target => switch (request.method) {
              'get' => controller.fetchResource(request, target),
              'patch' => controller.updateResource(request, target),
              'delete' => controller.deleteResource(request, target),
              _ => throw MethodNotAllowed(request.method)
            },
          Target target => switch (request.method) {
              'get' => controller.fetchCollection(request, target),
              'post' => controller.createResource(request, target),
              _ => throw MethodNotAllowed(request.method)
            },
          _ => throw UnmatchedTarget(request.uri)
        };
