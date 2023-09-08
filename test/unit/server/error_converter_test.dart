import 'dart:convert';

import 'package:http_interop/extensions.dart';
import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  test('500', () async {
    final r = await ErrorConverter().call('Foo', StackTrace.current);
    expect(r.statusCode, equals(500));
    expect(await r.body.decode(utf8),
        equals('{"errors":[{"title":"Internal Server Error"}]}'));
  });
}
