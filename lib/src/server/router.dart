import 'dart:convert';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

typedef TargetResolver = Target? Function(Request);
typedef ControllerResolver = Controller? Function(Request, Target);
typedef PayloadHandler = Future<Response?> Function(
  Request request,
  Target target,
  InboundDocument doc,
);

Handler router({
  required Target? Function(Request) getTarget,
  required Controller? Function(Request, Target) getController,
  PayloadHandler? onPayload,
}) => (request) async {
  final target = getTarget(request) ?? (throw UnmatchedTarget(request.uri));
  final controller = getController(request, target) ?? (throw CollectionNotFound(target.type));
  final docOrNull = await _decode(request);
  if (docOrNull != null) {
    final response = await onPayload?.call(request, target, docOrNull);
    if (response != null) return response;
  }
  InboundDocument doc() => docOrNull ?? (throw PayloadMissing());

  return switch (target) {
    RelationshipTarget target => switch (request.method) {
      'get' => controller.fetchRelationship(request, target),
      'post' => controller.addMany(request, target, doc().asToMany()),
      'patch' => controller.replaceRelationship(request, target, doc().asRelationship()),
      'delete' => controller.deleteMany(request, target, doc().asToMany()),
      _ => throw MethodNotAllowed(request.method),
    },
    RelatedTarget target => switch (request.method) {
      'get' => controller.fetchRelated(request, target),
      _ => throw MethodNotAllowed(request.method),
    },
    ResourceTarget target => switch (request.method) {
      'get' => controller.fetchResource(request, target),
      'patch' => controller.updateResource(request, target, doc().dataAsResource()),
      'delete' => controller.deleteResource(request, target),
      _ => throw MethodNotAllowed(request.method),
    },
    CollectionTarget target => switch (request.method) {
      'get' => controller.fetchCollection(request, target),
      'post' => controller.createResource(request, target, doc().dataAsNewResource()),
      _ => throw MethodNotAllowed(request.method),
    },
  };
};

Future<InboundDocument?> _decode(Request r) async {
  final body = await r.body.decode(utf8);
  if (body.isEmpty) return null;
  try {
    return InboundDocument(await const PayloadCodec().decode(body));
  } on FormatException {
    throw PayloadInvalid();
  }
}
