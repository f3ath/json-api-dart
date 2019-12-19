import 'package:json_api/document.dart';
import 'package:json_api/src/server/response/json_api_response.dart';
import 'package:json_api/src/server/server_document_factory.dart';

class ErrorResponse extends JsonApiResponse {
  final Iterable<JsonApiError> errors;

  const ErrorResponse(int status, this.errors) : super(status);

  Document buildDocument(ServerDocumentFactory builder, Uri self) =>
      builder.makeErrorDocument(errors);

  const ErrorResponse.notImplemented(this.errors) : super(501);

  const ErrorResponse.notFound(this.errors) : super(404);

  const ErrorResponse.badRequest(this.errors) : super(400);

  const ErrorResponse.methodNotAllowed(this.errors) : super(405);

  const ErrorResponse.conflict(this.errors) : super(409);
}
