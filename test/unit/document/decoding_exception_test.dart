import 'package:json_api/document.dart';
import 'package:json_api/src/document/decoding_exception.dart';
import 'package:test/test.dart';

void main() {
  test('DecpdingException.toString()', () {
    expect(DecodingException<Api>([]).toString(),
        'Can not decode Api from JSON: []');
  });
}
