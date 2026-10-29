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
    return switch ((request.method.toUpperCase(), target)) {
      ('GET', CollectionTarget target) => FetchCollectionRequest(request, target),
      ('POST', CollectionTarget target) => CreateResourceRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('GET', ResourceTarget target) => FetchResourceRequest(request, target),
      ('PATCH', ResourceTarget target) => UpdateResourceRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('DELETE', ResourceTarget target) => DeleteResourceRequest(request, target),
      ('GET', RelatedTarget target) => FetchRelatedRequest(request, target),
      ('GET', RelationshipTarget target) => FetchRelationshipRequest(request, target),
      ('POST', RelationshipTarget target) => AddManyRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('PATCH', RelationshipTarget target) => ReplaceRelationshipRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      ('DELETE', RelationshipTarget target) => DeleteManyRequest(
        request,
        target,
        doc ?? (throw PayloadMissing()),
      ),
      _ => throw MethodNotAllowed(request.method),
    };
  }

  Request get httpRequest;

  Target get target;

  /// Dispatches to the controller.
  Future<Response> dispatch(Controller controller);
}

final class const FetchCollectionRequest(
  @override final Request httpRequest,
  @override final CollectionTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) =>
      controller.fetchCollection(httpRequest, target);
}

final class const CreateResourceRequest(
  @override final Request httpRequest,
  @override final CollectionTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  NewResource get newResource => doc.dataAsNewResource();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.createResource(httpRequest, target, newResource);
}

final class const FetchResourceRequest(
  @override final Request httpRequest,
  @override final ResourceTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) => controller.fetchResource(httpRequest, target);
}

final class const UpdateResourceRequest(
  @override final Request httpRequest,
  @override final ResourceTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  Resource get resource => doc.dataAsResource();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.updateResource(httpRequest, target, resource);
}

final class const DeleteResourceRequest(
  @override final Request httpRequest,
  @override final ResourceTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) =>
      controller.deleteResource(httpRequest, target);
}

final class const FetchRelatedRequest(
  @override final Request httpRequest,
  @override final RelatedTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) => controller.fetchRelated(httpRequest, target);
}

final class const FetchRelationshipRequest(
  @override final Request httpRequest,
  @override final RelationshipTarget target,
) implements JsonApiRequest {
  @override
  Future<Response> dispatch(Controller controller) =>
      controller.fetchRelationship(httpRequest, target);
}

final class const AddManyRequest(
  @override final Request httpRequest,
  @override final RelationshipTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  ToMany get relationship => doc.asToMany();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.addMany(httpRequest, target, relationship);
}

final class const ReplaceRelationshipRequest(
  @override final Request httpRequest,
  @override final RelationshipTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  Relationship get relationship => doc.asRelationship();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.replaceRelationship(httpRequest, target, relationship);
}

final class const DeleteManyRequest(
  @override final Request httpRequest,
  @override final RelationshipTarget target,
  final InboundDocument doc,
) implements JsonApiRequest {
  ToMany get relationship => doc.asToMany();

  @override
  Future<Response> dispatch(Controller controller) =>
      controller.deleteMany(httpRequest, target, relationship);
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
