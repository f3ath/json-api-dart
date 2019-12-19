import 'package:json_api/server.dart';
import 'package:test/test.dart';

void main() {
  test('Responses should have "included" set to null by default', () {
    expect(CollectionResponse([]).included, null);
    expect(RelatedCollectionResponse([]).included, null);
    expect(RelatedResourceResponse(null).included, null);
    expect(ResourceResponse(null).included, null);
  });
}
