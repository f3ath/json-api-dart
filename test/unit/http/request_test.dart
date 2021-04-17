import 'package:json_api/http.dart';
import 'package:test/test.dart';

void main() {
  group('HttpRequest', () {
    final uri = Uri();
    final get = HttpRequest('get', uri);
    final post = HttpRequest('post', uri);
    final delete = HttpRequest('delete', uri);
    final patch = HttpRequest('patch', uri);
    final options = HttpRequest('options', uri);
    final fail = HttpRequest('fail', uri);
    test('getters', () {
      expect(get.isGet, isTrue);
      expect(post.isPost, isTrue);
      expect(delete.isDelete, isTrue);
      expect(patch.isPatch, isTrue);
      expect(options.isOptions, isTrue);

      expect(fail.isGet, isFalse);
      expect(fail.isPost, isFalse);
      expect(fail.isDelete, isFalse);
      expect(fail.isPatch, isFalse);
      expect(fail.isOptions, isFalse);
    });
    test('converts method to lowercase', () {
      expect(HttpRequest('pAtCh', Uri()).method, 'patch');
    });
  });
}
