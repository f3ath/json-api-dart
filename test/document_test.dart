import 'package:json_api/document.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  test('Example document', () {
    final dan = Resource('people', '9', attributes: {
      'firstName': 'Dan',
      'lastName': 'Gebhardt',
      'twitter': 'dgeb'
    });

    final firstComment = Resource('comments', '5',
        attributes: {'body': 'First!'},
        toOne: {'author': Identifier('people', '2')});

    final secondComment = Resource('comments', '12',
        attributes: {'body': 'I like XML better'},
        toOne: {'author': Identifier.of(dan)});

    final article = Resource(
      'articles',
      '1',
      attributes: {'title': 'JSON:API paints my bikeshed!'},
      toOne: {
        'author': Identifier.of(dan),
      },
      toMany: {
        'comments': [Identifier.of(firstComment), Identifier.of(secondComment)],
      },
    );

    final page = MockPage({},
        next: MockPage({'page[offset]': '2'}),
        last: MockPage({'page[offset]': '10'}));

    final doc = CollectionDocument([article],
        route: CollectionRoute('articles', page: page),
        included: [dan, firstComment, secondComment]);

    final links = StandardLinks(Uri.parse('http://example.com'));
    doc.setLinks(links);

    expect(
        doc,
        encodesToJson({
          "links": {
            "self": "http://example.com/articles",
            "next": "http://example.com/articles?page%5Boffset%5D=2",
            "last": "http://example.com/articles?page%5Boffset%5D=10"
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
                  "links": {
                    "self":
                        "http://example.com/comments/5/relationships/author",
                    "related": "http://example.com/comments/5/author"
                  },
                  "data": {"type": "people", "id": "2"}
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
                  "links": {
                    "self":
                        "http://example.com/comments/12/relationships/author",
                    "related": "http://example.com/comments/12/author"
                  },
                  "data": {"type": "people", "id": "9"}
                }
              },
              "links": {"self": "http://example.com/comments/12"}
            }
          ]
        }));
  });
}

class MockPage implements Page {
  final Map<String, String> parameters;
  final Page next;
  final Page prev;
  final Page first;
  final Page last;

  MockPage(this.parameters, {this.first, this.last, this.prev, this.next});
}
