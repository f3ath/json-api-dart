import 'package:json_api/server.dart';
import 'package:json_api/url_design.dart';
import 'package:shelf/shelf_io.dart' as shelf;
import 'package:stream_channel/stream_channel.dart';
import 'package:uuid/uuid.dart';

import '../../example/server/crud_controller.dart';
import '../../example/server/shelf_request_response_converter.dart';

void hybridMain(StreamChannel channel, Object uri) async {
  if (uri is Uri) {
    channel.sink.add(await shelf.serve(
        createHttpHandler(ShelfRequestResponseConverter(),
            CRUDController(Uuid().v4), PathBasedUrlDesign(uri)),
        uri.host,
        uri.port));
    return;
  }
  throw ArgumentError.value(uri);
}
