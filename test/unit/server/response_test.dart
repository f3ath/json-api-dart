import 'package:http_interop/extensions.dart';
import 'package:json_api/document.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  group('Response', () {
    test('converts DateTime to ISO-8601', () async {
      final r = response(200,
          document: OutboundDocument()..meta['date'] = DateTime(2021));
      expect(
          await r.body.decodeJson(),
          equals({
            'meta': {'date': '2021-01-01T00:00:00.000'}
          }));
    });
  });
}
