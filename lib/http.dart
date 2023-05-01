/// This is a thin HTTP layer abstraction used by the client and the server
library http;

export 'package:http_interop/http_interop.dart'
    show
        HttpMessage,
        HttpHeaders,
        HttpRequest,
        HttpResponse,
        HttpHandler,
        LoggingHandler;
export 'package:json_api/src/http/http_response_ext.dart';
export 'package:json_api/src/http/media_type.dart';
export 'package:json_api/src/http/payload_codec.dart';
export 'package:json_api/src/http/status_code.dart';
