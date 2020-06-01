import 'package:json_api/document.dart';
import 'package:json_api/src/document/document_exception.dart';
import 'package:test/test.dart';

void main() {
  test('throws DocumentException when can not be decoded', () {
    expect(() => IdentifierObject.fromJson([]),
        throwsA(TypeMatcher<DocumentException>()));
  });
}
