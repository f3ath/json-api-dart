import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';
import 'package:json_api/document.dart';
import 'package:json_api/src/server/errors/collection_not_found.dart';
import 'package:json_api/src/server/errors/method_not_allowed.dart';
import 'package:json_api/src/server/errors/not_acceptable.dart';
import 'package:json_api/src/server/errors/relationship_not_found.dart';
import 'package:json_api/src/server/errors/resource_not_found.dart';
import 'package:json_api/src/server/errors/unmatched_target.dart';
import 'package:json_api/src/server/errors/unsupported_media_type.dart';
import 'package:json_api/src/server/response.dart';

/// Creates a middleware that maps server exceptions to HTTP responses.
Middleware errorConverter({
  Future<Response?> Function(MethodNotAllowed)? onMethodNotAllowed,
  Future<Response?> Function(UnmatchedTarget)? onUnmatchedTarget,
  Future<Response?> Function(CollectionNotFound)? onCollectionNotFound,
  Future<Response?> Function(ResourceNotFound)? onResourceNotFound,
  Future<Response?> Function(RelationshipNotFound)? onRelationshipNotFound,
  Future<Response?> Function(Object, StackTrace)? onError,
}) =>
    middleware(
        onError: (error, trace, _) async => switch (error) {
              MethodNotAllowed() =>
                await onMethodNotAllowed?.call(error) ?? methodNotAllowed(),
              UnmatchedTarget() =>
                await onUnmatchedTarget?.call(error) ?? badRequest(),
              CollectionNotFound() => await onCollectionNotFound?.call(error) ??
                  notFound(OutboundErrorDocument([
                    ErrorObject(
                      title: 'Collection Not Found',
                      detail: 'Type: ${error.type}',
                    )
                  ])),
              ResourceNotFound() => await onResourceNotFound?.call(error) ??
                  notFound(OutboundErrorDocument([
                    ErrorObject(
                      title: 'Resource Not Found',
                      detail: 'Type: ${error.type}, id: ${error.id}',
                    )
                  ])),
              RelationshipNotFound() =>
                await onRelationshipNotFound?.call(error) ??
                    notFound(OutboundErrorDocument([
                      ErrorObject(
                        title: 'Relationship Not Found',
                        detail: 'Type: ${error.type}'
                            ', id: ${error.id}'
                            ', relationship: ${error.relationship}',
                      )
                    ])),
              UnsupportedMediaType() => unsupportedMediaType(),
              NotAcceptable() => notAcceptable(),
              _ => await onError?.call(error, trace) ??
                  internalServerError(OutboundErrorDocument(
                      [ErrorObject(title: 'Internal Server Error')]))
            });
