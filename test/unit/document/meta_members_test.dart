import 'package:json_api/document.dart';
import 'package:test/test.dart';

void main() {
  group('Meta members', () {
    test('should be parsed correctly', () {
      final meta = {
        "bool": true,
        "array": [1, 2, 3],
        "string": "foo"
      };
      final json = {
        "links": {
          "self": "http://example.com/articles",
          "next": "http://example.com/articles?page=2",
          "last": "http://example.com/articles?page=10"
        },
        "meta": meta,
        "data": [
          {
            "type": "articles",
            "id": "1",
            "attributes": {"title": "JSON:API paints my bikeshed!"},
            "meta": meta,
            "relationships": {
              "author": {
                "links": {
                  "self": "http://example.com/articles/1/relationships/author",
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
                  {
                    "type": "comments",
                    "id": "5",
                    "meta": meta,
                  },
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
      };

      final doc = Document.decodeJson(json, ResourceCollectionData.decodeJson);
      expect(doc.meta["bool"], true);
      expect(doc.data.collection.first.meta, meta);
      expect(
          (doc.data.collection.first.relationships['comments'] as ToMany)
              .linkage
              .first
              .meta,
          meta);
    });
  });
}
