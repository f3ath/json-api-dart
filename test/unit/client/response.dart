import 'package:http_interop/http_interop.dart';
import 'package:json_api/http.dart';
import 'package:json_api/src/media_type.dart';

final headers = Headers({'Content-Type': mediaType});

collectionMin() => Response(
    200,
    Json({
      'data': [
        {'type': 'articles', 'id': '1'}
      ]
    }),
    headers);

collectionFull() => Response(
    200,
    Json({
      'links': {
        'self': 'http://example.com/articles',
        'next': 'http://example.com/articles?page[offset]=2',
        'last': 'http://example.com/articles?page[offset]=10'
      },
      'meta': {'hello': 'world'},
      'data': [
        {
          'type': 'articles',
          'id': '1',
          'attributes': {'title': 'JSON:API paints my bikeshed!'},
          'relationships': {
            'author': {
              'links': {
                'self': 'http://example.com/articles/1/relationships/author',
                'related': 'http://example.com/articles/1/author'
              },
              'data': {'type': 'people', 'id': '9'}
            },
            'comments': {
              'links': {
                'self': 'http://example.com/articles/1/relationships/comments',
                'related': 'http://example.com/articles/1/comments'
              },
              'data': [
                {'type': 'comments', 'id': '5'},
                {'type': 'comments', 'id': '12'}
              ]
            }
          },
          'links': {'self': 'http://example.com/articles/1'}
        }
      ],
      'included': [
        {
          'type': 'people',
          'id': '9',
          'attributes': {
            'firstName': 'Dan',
            'lastName': 'Gebhardt',
            'twitter': 'dgeb'
          },
          'links': {'self': 'http://example.com/people/9'}
        },
        {
          'type': 'comments',
          'id': '5',
          'attributes': {'body': 'First!'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '2'}
            }
          },
          'links': {'self': 'http://example.com/comments/5'}
        },
        {
          'type': 'comments',
          'id': '12',
          'attributes': {'body': 'I like XML better'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '9'}
            }
          },
          'links': {'self': 'http://example.com/comments/12'}
        }
      ]
    }),
    headers);

primaryResource() => Response(
    200,
    Json({
      'links': {'self': 'http://example.com/articles/1'},
      'meta': {'hello': 'world'},
      'data': {
        'type': 'articles',
        'id': '1',
        'attributes': {'title': 'JSON:API paints my bikeshed!'},
        'relationships': {
          'author': {
            'links': {'related': 'http://example.com/articles/1/author'}
          }
        }
      },
      'included': [
        {
          'type': 'people',
          'id': '9',
          'attributes': {
            'firstName': 'Dan',
            'lastName': 'Gebhardt',
            'twitter': 'dgeb'
          },
          'links': {'self': 'http://example.com/people/9'}
        },
        {
          'type': 'comments',
          'id': '5',
          'attributes': {'body': 'First!'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '2'}
            }
          },
          'links': {'self': 'http://example.com/comments/5'}
        },
        {
          'type': 'comments',
          'id': '12',
          'attributes': {'body': 'I like XML better'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '9'}
            }
          },
          'links': {'self': 'http://example.com/comments/12'}
        }
      ]
    }),
    headers);

relatedResourceNull() => Response(
    200,
    Json({
      'links': {'self': 'http://example.com/articles/1/author'},
      'meta': {'hello': 'world'},
      'data': null
    }),
    headers);

one() => Response(
    200,
    Json({
      'links': {
        'self': '/articles/1/relationships/author',
        'related': '/articles/1/author'
      },
      'meta': {'hello': 'world'},
      'data': {'type': 'people', 'id': '12'},
      'included': [
        {
          'type': 'people',
          'id': '9',
          'attributes': {
            'firstName': 'Dan',
            'lastName': 'Gebhardt',
            'twitter': 'dgeb'
          },
          'links': {'self': 'http://example.com/people/9'}
        },
        {
          'type': 'comments',
          'id': '5',
          'attributes': {'body': 'First!'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '2'}
            }
          },
          'links': {'self': 'http://example.com/comments/5'}
        },
        {
          'type': 'comments',
          'id': '12',
          'attributes': {'body': 'I like XML better'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '9'}
            }
          },
          'links': {'self': 'http://example.com/comments/12'}
        }
      ]
    }),
    headers);

oneEmpty() => Response(
    200,
    Json({
      'links': {
        'self': '/articles/1/relationships/author',
        'related': '/articles/1/author'
      },
      'meta': {'hello': 'world'},
      'data': null,
      'included': [
        {
          'type': 'people',
          'id': '9',
          'attributes': {
            'firstName': 'Dan',
            'lastName': 'Gebhardt',
            'twitter': 'dgeb'
          },
          'links': {'self': 'http://example.com/people/9'}
        },
        {
          'type': 'comments',
          'id': '5',
          'attributes': {'body': 'First!'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '2'}
            }
          },
          'links': {'self': 'http://example.com/comments/5'}
        },
        {
          'type': 'comments',
          'id': '12',
          'attributes': {'body': 'I like XML better'},
          'relationships': {
            'author': {
              'data': {'type': 'people', 'id': '9'}
            }
          },
          'links': {'self': 'http://example.com/comments/12'}
        }
      ]
    }),
    headers);

many() => Response(
    200,
    Json({
      'links': {
        'self': '/articles/1/relationships/tags',
        'related': '/articles/1/tags'
      },
      'meta': {'hello': 'world'},
      'data': [
        {'type': 'tags', 'id': '12'}
      ]
    }),
    headers);

noContent() => Response(204, Body.empty(), Headers({}));

error422() => Response(
    422,
    Json({
      'meta': {'hello': 'world'},
      'errors': [
        {
          'status': '422',
          'source': {'pointer': '/data/attributes/firstName'},
          'title': 'Invalid Attribute',
          'detail': 'First name must contain at least three characters.'
        }
      ]
    }),
    headers);

error500() => Response(500, Body.empty(), Headers({}));
