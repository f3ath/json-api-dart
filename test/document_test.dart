import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
//  test('Example document', () {
//    final dan = Resource('people', '9',
//        attributes: {
//          'first-name': 'Dan',
//          'last-name': 'Gebhardt',
//          'twitter': 'dgeb'
//        },
//        self: Link('http://example.com/people/9'));
//
//
//    final firstComment = Resource('comments', '5',
//        attributes: {'body': 'First!'},
//        toOne: {'author': Identifier('people', '2')},
//        self: Link('http://example.com/comments/5'));
//
//    final secondComment = Resource('comments', '12',
//        attributes: {'body': 'I like XML better'},
//        toOne: {'author': Identifier.of(dan)},
//        self: Link('http://example.com/comments/12'));
//
//    final article = Resource(
//      'articles',
//      '1',
//      self: Link('http://example.com/articles/1'),
//      attributes: {'title': 'JSON API paints my bikeshed!'},
//      toOne: {
//        'author': ToOne(
//          Identifier.of(dan),
//          self: Link('http://example.com/articles/1/relationships/author'),
//          related: Link('http://example.com/articles/1/author'),
//        ),
//        'comments': ToMany(
//            [Identifier.of(firstComment), Identifier.of(secondComment)],
//            self: Link('http://example.com/articles/1/relationships/comments'),
//            related: Link('http://example.com/articles/1/comments'))
//      },
//    );
//
////    return DataDocument.fromResourceList([article],
////        self: Link('http://example.com/articles'),
////        next: Link('http://example.com/articles?page[offset]=2'),
////        last: Link('http://example.com/articles?page[offset]=10'),
////        included: [dan, firstComment, secondComment]);
//
//    final doc = Document.fromCollection();
//
//
//    expect(doc.toJson(), {
//      "links": {
//        "self": "http://example.com/articles",
//        "next": "http://example.com/articles?page[offset]=2",
//        "last": "http://example.com/articles?page[offset]=10"
//      },
//      "data": [{
//        "type": "articles",
//        "id": "1",
//        "attributes": {
//          "title": "JSON:API paints my bikeshed!"
//        },
//        "relationships": {
//          "author": {
//            "links": {
//              "self": "http://example.com/articles/1/relationships/author",
//              "related": "http://example.com/articles/1/author"
//            },
//            "data": { "type": "people", "id": "9" }
//          },
//          "comments": {
//            "links": {
//              "self": "http://example.com/articles/1/relationships/comments",
//              "related": "http://example.com/articles/1/comments"
//            },
//            "data": [
//              { "type": "comments", "id": "5" },
//              { "type": "comments", "id": "12" }
//            ]
//          }
//        },
//        "links": {
//          "self": "http://example.com/articles/1"
//        }
//      }],
//      "included": [{
//        "type": "people",
//        "id": "9",
//        "attributes": {
//          "firstName": "Dan",
//          "lastName": "Gebhardt",
//          "twitter": "dgeb"
//        },
//        "links": {
//          "self": "http://example.com/people/9"
//        }
//      }, {
//        "type": "comments",
//        "id": "5",
//        "attributes": {
//          "body": "First!"
//        },
//        "relationships": {
//          "author": {
//            "data": { "type": "people", "id": "2" }
//          }
//        },
//        "links": {
//          "self": "http://example.com/comments/5"
//        }
//      }, {
//        "type": "comments",
//        "id": "12",
//        "attributes": {
//          "body": "I like XML better"
//        },
//        "relationships": {
//          "author": {
//            "data": { "type": "people", "id": "9" }
//          }
//        },
//        "links": {
//          "self": "http://example.com/comments/12"
//        }
//      }]
//    });
//
//  });
//
}
