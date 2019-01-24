import 'package:json_api/core.dart';
import 'package:json_api/server.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  group('Renderer', () {
    group('Data document', () {
      test('Example', () {
        final article = Resource(
          'articles',
          '1',
          attributes: {
            "title": "JSON:API paints my bikeshed!",
          },
          toMany: {
            'comments': [
              Identifier('comments', '5'),
              Identifier('comments', '12')
            ]
          },
          toOne: {'author': Identifier('people', '9')},
        );

        final comment5 = Resource('comments', '5',
            attributes: {"body": "First!"},
            toOne: {"author": Identifier('people', '2')});
        final dan = Resource('people', '9', attributes: {
          "firstName": "Dan",
          "lastName": "Gebhardt",
          "twitter": "dgeb"
        });
        final comment12 = Resource('comments', '12',
            attributes: {"body": 'I like XML better'},
            toOne: {"author": Identifier.of(dan)});

        final r = Renderer(link: StandardLinks('http://example.com'));

        expect(
            r.renderCollection([article], include: [dan, comment5, comment12]),
            encodesToJson({
              "links": {
                "self": "http://example.com/articles",
                "next": "http://example.com/articles?page[offset]=2",
                "last": "http://example.com/articles?page[offset]=10"
              },
              "data": [
                {
                  "type": "articles",
                  "id": "1",
                  "attributes": {"title": "JSON:API paints my bikeshed!"},
                  "relationships": {
                    "author": {
                      "links": {
                        "self":
                            "http://example.com/articles/1/relationships/author",
                        "related": "http://example.com/articles/1/author"
                      },
                      "data": {"type": "people", "id": "9"}
                    },
                    "comments": {
                      "links": {
                        "self":
                            "http://example.com/articles/1/relationships/comments",
                        "related": "http://example.com/articles/1/comments"
                      },
                      "data": [
                        {"type": "comments", "id": "5"},
                        {"type": "comments", "id": "12"}
                      ]
                    }
                  },
                  "links": {"self": "http://example.com/articles/1"}
                }
              ],
              "included": [
                {
                  "type": "people",
                  "id": "9",
                  "attributes": {
                    "firstName": "Dan",
                    "lastName": "Gebhardt",
                    "twitter": "dgeb"
                  },
                  "links": {"self": "http://example.com/people/9"}
                },
                {
                  "type": "comments",
                  "id": "5",
                  "attributes": {"body": "First!"},
                  "relationships": {
                    "author": {
                      "data": {"type": "people", "id": "2"},
                      'links': {
                        'self':
                            'http://example.com/comments/5/relationships/author',
                        'related': 'http://example.com/comments/5/author'
                      }
                    }
                  },
                  "links": {"self": "http://example.com/comments/5"}
                },
                {
                  "type": "comments",
                  "id": "12",
                  "attributes": {"body": "I like XML better"},
                  "relationships": {
                    "author": {
                      "data": {"type": "people", "id": "9"},
                      'links': {
                        'self':
                            'http://example.com/comments/12/relationships/author',
                        'related': 'http://example.com/comments/12/author'
                      }
                    }
                  },
                  "links": {"self": "http://example.com/comments/12"}
                }
              ]
            }));
      });
    });

    group('Empty document', () {
      test('minimal', () {
        final r = Renderer(meta: TestMeta(), includeApiVersion: false);
        expect(r.renderEmpty(), {
          "meta": {"kind": "topLevel"}
        });
      });
      test('top-level meta is required', () {
        try {
          Renderer().renderEmpty();
          fail('Exception expected');
        } on RenderingException catch (e) {
          expect(e.message, 'Top-level Meta is required');
        }
      });
      test('extended', () {
        final r = Renderer(meta: TestMeta());
        expect(r.renderEmpty(), {
          "meta": {"kind": "topLevel"},
          "jsonapi": {
            "version": "1.0",
            "meta": {"kind": "api"}
          }
        });
      });
    });
  });
}

class TestMeta implements MetaProvider {
  Map<String, Object> topLevel() => {"kind": "topLevel"};

  Map<String, Object> jsonApi() => {"kind": "api"};
}
