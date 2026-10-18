import 'dart:convert';

import 'package:http_interop/extensions.dart';
import 'package:http_interop/http_interop.dart';
import 'package:json_api/document.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/controller.dart';
import 'package:json_api/src/server/errors/method_not_allowed.dart';
import 'package:json_api/src/server/errors/payload_invalid.dart';
import 'package:json_api/src/server/errors/payload_missing.dart';

/// A supported combination of an HTTP method and a JSON:API target.
sealed class JsonApiRequest {
  /// Resolves an HTTP [request] and [target] to a supported request.
  /// Throws [MethodNotAllowed] for unsupported combinations.
  static Future<JsonApiRequest> resolve(Request request, Target target) async {
    final doc = await _decode(request);
    return switch ((request.method, target)) {
      ('get', CollectionTarget target) => FetchCollectionRequest(request, target),
      ('post', CollectionTarget target) => CreateResourceRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('get', ResourceTarget target) => FetchResourceRequest(request, target),
      ('patch', ResourceTarget target) => UpdateResourceRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('delete', ResourceTarget target) => DeleteResourceRequest(request, target),
      ('get', RelatedTarget target) => FetchRelatedRequest(request, target),
      ('get', RelationshipTarget target) => FetchRelationshipRequest(request, target),
      ('post', RelationshipTarget target) => AddManyRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('patch', RelationshipTarget target) => ReplaceRelationshipRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('delete', RelationshipTarget target) => DeleteManyRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      _ => throw MethodNotAllowed(request.method),
    };
  }

  Request get request;

  Target get target;

  /// Dispatches to the controller.
  Future<Response> dispatch(Controller controller);
}

final class const FetchCollectionRequest(
  @override final Request request,
  @override final CollectionTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) => controller.fetchCollection(request, target);
}

final class const CreateResourceRequest(
  @override final Request request,
  @override final CollectionTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  NewResource get newResource => doc.dataAsNewResource();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.createResource(request, target, newResource);
}

final class const FetchResourceRequest(
  @override final Request request,
  @override final ResourceTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) => controller.fetchResource(request, target);
}

final class const UpdateResourceRequest(
  @override final Request request,
  @override final ResourceTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  Resource get resource => doc.dataAsResource();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.updateResource(request, target, resource);
}

final class const DeleteResourceRequest(
  @override final Request request,
  @override final ResourceTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) => controller.deleteResource(request, target);
}

final class const FetchRelatedRequest(
  @override final Request request,
  @override final RelatedTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) => controller.fetchRelated(request, target);
}

final class const FetchRelationshipRequest(
  @override final Request request,
  @override final RelationshipTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) => controller.fetchRelationship(request, target);
}

final class const AddManyRequest(
  @override final Request request,
  @override final RelationshipTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  ToMany get relationship => doc.asToMany();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.addMany(request, target, relationship);
}

final class const ReplaceRelationshipRequest(
  @override final Request request,
  @override final RelationshipTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  Relationship get relationship => doc.asRelationship();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.replaceRelationship(request, target, relationship);
}

final class const DeleteManyRequest(
  @override final Request request,
  @override final RelationshipTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  ToMany get relationship => doc.asToMany();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.deleteMany(request, target, relationship);
}

Future<InboundDocument?> _decode(Request r) async {
  final body = await r.body.decode(utf8);
  if (body.isEmpty) return null;
  try {
    return InboundDocument(await const PayloadCodec().decode(body));
  } on FormatException {
    throw PayloadInvalid();
  }
}
