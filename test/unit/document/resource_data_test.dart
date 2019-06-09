import 'package:json_api/json_api.dart';
import 'package:test/test.dart';

import 'helper.dart';

void main() {
  test('Can decode a primary resource with missing id', () {
    final data = ResourceData.decodeJson(recodeJson({
      'data': {'type': 'apples'}
    }));
    expect(data.unwrap().type, 'apples');
    expect(data.unwrap().id, isNull);
  });

  test('Can decode a primary resource with null id', () {
    final data = ResourceData.decodeJson(recodeJson({
      'data': {'type': 'apples', 'id': null}
    }));
    expect(data.unwrap().type, 'apples');
    expect(data.unwrap().id, isNull);
  });
}
