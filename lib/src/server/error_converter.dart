import 'package:http_interop/http_interop.dart';
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

  final Future<HttpResponse> Function(MethodNotAllowed)? onMethodNotAllowed;
  final Future<HttpResponse> Function(UnmatchedTarget)? onUnmatchedTarget;
  final Future<HttpResponse> Function(CollectionNotFound)? onCollectionNotFound;
  final Future<HttpResponse> Function(ResourceNotFound)? onResourceNotFound;
  final Future<HttpResponse> Function(RelationshipNotFound)?
      onRelationshipNotFound;
  final Future<HttpResponse> Function(dynamic, StackTrace)? onError;

  Future<HttpResponse> call(dynamic error, StackTrace trace) async {
    if (error is MethodNotAllowed) {
      return await onMethodNotAllowed?.call(error) ??
          Response.methodNotAllowed();
    }
    if (error is UnmatchedTarget) {
      return await onUnmatchedTarget?.call(error) ?? Response.badRequest();
    }
    if (error is CollectionNotFound) {
      return await onCollectionNotFound?.call(error) ??
          Response.notFound(OutboundErrorDocument([
            ErrorObject(
              title: 'Collection Not Found',
              detail: 'Type: ${error.type}',
            )
          ]));
    }
    if (error is ResourceNotFound) {
      return await onResourceNotFound?.call(error) ??
          Response.notFound(OutboundErrorDocument([
            ErrorObject(
              title: 'Resource Not Found',
              detail: 'Type: ${error.type}, id: ${error.id}',
            )
          ]));
    }
    if (error is RelationshipNotFound) {
      return await onRelationshipNotFound?.call(error) ??
          Response.notFound(OutboundErrorDocument([
            ErrorObject(
              title: 'Relationship Not Found',
              detail:
                  'Type: ${error.type}, id: ${error.id}, relationship: ${error.relationship}',
            )
          ]));
    }
    if (error is UnsupportedMediaType) {
      return Response.unsupportedMediaType();
    }
    if (error is Unacceptable) {
      return Response.unacceptable();
    }
    return await onError?.call(error, trace) ??
        Response(500,
            document: OutboundErrorDocument(
                [ErrorObject(title: 'Internal Server Error')]));
  }
}
