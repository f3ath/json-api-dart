import 'package:http_interop/http_interop.dart';
import 'package:http_interop_middleware/http_interop_middleware.dart';
import 'package:http_parser/http_parser.dart';
import 'package:json_api/src/media_type.dart';
import 'package:json_api/src/server/errors/unacceptable.dart';
import 'package:json_api/src/server/errors/unsupported_media_type.dart';

final requestValidator = middleware(onRequest: (Request request) async {
  final contentType = request.headers['Content-Type']?.last;
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
  return null;
});

bool _isInvalid(MediaType mt) =>
    mt.mimeType == mediaType &&
    mt.parameters.isNotEmpty; // TODO: check for ext and profile
