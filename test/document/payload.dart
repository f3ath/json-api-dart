final example = {
  'links': {
    'self': 'http://example.com/articles',
    'next': 'http://example.com/articles?page[offset]=2',
    'last': 'http://example.com/articles?page[offset]=10'
  },
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
};

final newResource = {
  'data': {
    'type': 'articles',
    'attributes': {'title': 'A new article'},
    'relationships': {
      'author': {
        'data': {'type': 'people', 'id': '42'}
      }
    }
  }
};

final many = {
  'links': {
    'self': '/articles/1/relationships/tags',
    'related': '/articles/1/tags'
  },
  'data': [
    {'type': 'tags', 'id': '2'},
    {'type': 'tags', 'id': '3'}
  ]
};

final manyEmpty = {
  'links': {
    'self': '/articles/1/relationships/tags',
    'related': '/articles/1/tags'
  },
  'data': []
};

final one = {
  'links': {
    'self': '/articles/1/relationships/author',
    'related': '/articles/1/author'
  },
  'data': {'type': 'people', 'id': '12'}
};

final oneEmpty = {
  'links': {
    'self': '/articles/1/relationships/author',
    'related': '/articles/1/author'
  },
  'data': null
};

final relatedEmpty = {
  'links': {'self': 'http://example.com/articles/1/author'},
  'data': null
};

final resource = {
  'links': {
    'self': {
      'href': 'http://example.com/articles/1',
      'meta': {'answer': 42}
    }
  },
  'data': {
    'type': 'articles',
    'id': '1',
    'attributes': {'title': 'JSON:API paints my bikeshed!'},
    'relationships': {
      'author': {
        'links': {'related': 'http://example.com/articles/1/author'}
      },
      'reviewer': {'data': null}
    }
  }
};
