import 'package:json_api/document.dart';
import 'package:json_matcher/json_matcher.dart';
import 'package:test/test.dart';

void main() {
  test('Single resource collection', () {
    final tesla = Resource('brands', '1', attributes: {'name': 'Tesla'});
    final doc = CollectionDocument([tesla]);
    expect(
        doc,
        encodesToJson({
          'data': [
            {
              'type': 'brands',
              'id': '1',
              'attributes': {'name': 'Tesla'}
            }
          ]
        }));
  });

  test('Example document', () {
    final dan = Resource('people', '9',
        attributes: {
          'firstName': 'Dan',
          'lastName': 'Gebhardt',
          'twitter': 'dgeb'
        },
        self: Link('http://example.com/people/9'));

    final firstComment = Resource('comments', '5',
        attributes: {'body': 'First!'},
        relationships: {'author': ToOne(Identifier('people', '2'))},
        self: Link('http://example.com/comments/5'));

    final secondComment = Resource('comments', '12',
        attributes: {'body': 'I like XML better'},
        relationships: {'author': ToOne(Identifier('people', '9'))},
        self: Link('http://example.com/comments/12'));

    final article = Resource(
      'articles',
      '1',
      attributes: {'title': 'JSON:API paints my bikeshed!'},
      self: Link('http://example.com/articles/1'),
      relationships: {
        'author': ToOne(Identifier('people', '9'),
            self: Link('http://example.com/articles/1/relationships/author'),
            related: Link('http://example.com/articles/1/author')),
        'comments': ToMany(
            [Identifier('comments', '5'), Identifier('comments', '12')],
            self: Link('http://example.com/articles/1/relationships/comments'),
            related: Link('http://example.com/articles/1/comments')),
      },
    );

    final doc = CollectionDocument([article],
        included: [dan, firstComment, secondComment],
        self: Link('http://example.com/articles'),
        pagination: PaginationLinks(
            next: Link('http://example.com/articles?page[offset]=2'),
            last: Link('http://example.com/articles?page[offset]=10')));

    expect(
        doc,
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
                  "data": {"type": "people", "id": "9"}
                }
              },
              "links": {"self": "http://example.com/comments/12"}
            }
          ]
        }));
  });
}

//class MockPage implements Page {
//  final Map<String, String> parameters;
//  final Page next;
//  final Page prev;
//  final Page first;
//  final Page last;
//
//  MockPage(this.parameters, {this.first, this.last, this.prev, this.next});
//}
