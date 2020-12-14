// @dart=2.9
import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/client/basic_client.dart';

// The handler is not migrated to null safety yet.
import '../legacy/dart_http_handler.dart';

// START THE SERVER FIRST!
void main() async {
  final uri = Uri(host: 'localhost', port: 8080);
  final client =
      RoutingClient(StandardUriDesign(uri), BasicClient(DartHttpHandler()));
}
