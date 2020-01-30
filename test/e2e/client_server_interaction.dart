import 'package:json_api/server.dart';
import 'package:json_api/uri_design.dart';
import 'package:test/test.dart';

void main() {
  group('Client-Server interation over HTTP', () {
    final port = 8088;
    final host = 'localhost';
    final uri = UriDesign.standard(Uri(host: host, port: port));
    final repo = InMemoryRepository({'people': {}, 'books': {}});
    final server = JsonApiServer(uri, RepositoryController(repo));
    test('can create and fetch resources', () {

    });
  }, testOn: 'vm');
}
