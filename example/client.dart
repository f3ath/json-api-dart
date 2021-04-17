import 'package:json_api/client.dart';
import 'package:json_api/routing.dart';

// START THE SERVER FIRST!
void main() async {
  final host = 'localhost';
  final port = 8080;
  final uri = Uri(scheme: 'http', host: host, port: port);
  final client = RoutingClient(StandardUriDesign(uri));
  final response = await client.fetchCollection('colors');
  response.collection.map((resource) => resource.attributes).forEach((attr) {
    print('${attr['name']} - ${attr['red']}:${attr['green']}:${attr['blue']}');
  });
}
