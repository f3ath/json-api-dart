import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';

// START THE SERVER FIRST!
void main() async {
  final uri = Uri(host: 'localhost', port: 8080);
  final client =
      RoutingClient(StandardUriDesign(uri));
}
