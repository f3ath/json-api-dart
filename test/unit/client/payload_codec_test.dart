import 'package:json_api/src/client/payload_codec.dart';
import 'package:test/test.dart';

void main() {
  test('Throws format exception if the payload is not a Map', () {
    expect(() => PayloadCodec().decode('"oops"'), throwsFormatException);
  });
}
