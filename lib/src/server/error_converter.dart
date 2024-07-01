import 'package:http_interop/http_interop.dart' as http;
import 'package:json_api/document.dart';
import 'package:json_api/src/server/errors/collection_not_found.dart';
import 'package:json_api/src/server/errors/method_not_allowed.dart';
import 'package:json_api/src/server/errors/relationship_not_found.dart';
import 'package:json_api/src/server/errors/resource_not_found.dart';
import 'package:json_api/src/server/errors/unacceptable.dart';
import 'package:json_api/src/server/errors/unmatched_target.dart';
import 'package:json_api/src/server/errors/unsupported_media_type.dart';
import 'package:json_api/src/server/response.dart';

/// The error converter maps server exceptions to JSON:API responses.
/// It is designed to be used with the TryCatchHandler from the `json_api:http`
/// package and provides some meaningful defaults out of the box.
class ErrorConverter {
  ErrorConverter({
    this.onMethodNotAllowed,
    this.onUnmatchedTarget,
    this.onCollectionNotFound,
    this.onResourceNotFound,
    this.onRelationshipNotFound,
    this.onError,
  });

  final Future<http.Response> Function(MethodNotAllowed)? onMethodNotAllowed;
  final Future<http.Response> Function(UnmatchedTarget)? onUnmatchedTarget;
  final Future<http.Response> Function(CollectionNotFound)?
      onCollectionNotFound;
  final Future<http.Response> Function(ResourceNotFound)? onResourceNotFound;
  final Future<http.Response> Function(RelationshipNotFound)?
      onRelationshipNotFound;
  final Future<http.Response> Function(dynamic, StackTrace)? onError;

  Future<http.Response> call(Object? error, StackTrace trace) async =>
      switch (error) {
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
        RelationshipNotFound() => await onRelationshipNotFound?.call(error) ??
            notFound(OutboundErrorDocument([
              ErrorObject(
                title: 'Relationship Not Found',
                detail: 'Type: ${error.type}'
                    ', id: ${error.id}'
                    ', relationship: ${error.relationship}',
              )
            ])),
        UnsupportedMediaType() => unsupportedMediaType(),
        Unacceptable() => unacceptable(),
        _ => await onError?.call(error, trace) ??
            response(500,
                document: OutboundErrorDocument(
                    [ErrorObject(title: 'Internal Server Error')]))
      };
}
