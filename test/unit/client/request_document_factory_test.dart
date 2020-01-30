import 'package:json_api/client.dart';
import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  test('Generated documents contain no links object', () {
    final doc =
        RequestDocumentFactory().resourceDocument(Resource('apples', null));
    expect(doc.data.links, isNull);
  });
}
