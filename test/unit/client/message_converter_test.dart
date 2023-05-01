import 'package:json_api/client.dart';
import 'package:json_api/http.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final converter = MessageConverter();
  final uri = Uri.parse('https://example.com');

  test('No headers are set for GET requests', () {
    final r = converter.request(HttpRequest('GET', uri));
    expect(r.headers, isEmpty);
  });

  test('No headers are set for OPTIONS requests', () {
    final r = converter.request(HttpRequest('OPTIONS', uri));
    expect(r.headers, isEmpty);
  });

  test('No headers are set for DELETE requests', () {
    final r = converter.request(HttpRequest('DELETE', uri));
    expect(r.headers, isEmpty);
  });
}
