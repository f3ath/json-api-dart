import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('Unrecognized structure', () {
    expect(() => Document.fromJson({}, ResourceCollectionData.fromJson),
        throwsA(TypeMatcher<DocumentException>()));
  });
}
