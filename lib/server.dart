import 'package:json_api/core.dart';

class Renderer {
  static const version = '1.0';
  final MetaProvider meta;
  final LinkRenderer link;
  final bool includeApiVersion;

  Renderer(
      {this.meta = const NoMeta(), this.link, this.includeApiVersion = true});

  Map<String, Object> renderEmpty() {
    final doc = <String, Object>{};
    final topLevel = meta.topLevel();
    if (topLevel?.isNotEmpty != true) {
      throw RenderingException('Top-level Meta is required');
    }
    _setMeta(doc, topLevel);
    _setJsonApi(doc);
    return doc;
  }

  Map<String, Object> renderCollection(List<Resource> resources,
      {List<Resource> include = const []}) {
    return {
      "links": {
        "self": link.collection('articles'),
        "next": "http://example.com/articles?page[offset]=2",
        "last": "http://example.com/articles?page[offset]=10"
      },
      'data': resources.map(_resource).toList(),
      "included": include.map(_resource).toList()
    };
  }

  Map<String, Object> _resource(Resource r) {
    final relationships = _relationships(r);
    final j = <String, Object>{
      'type': r.type,
      'id': r.id,
      'attributes': r.attributes,
      'links': {'self': link.resource(r.type, r.id)}
    };
    if (relationships.isNotEmpty) {
      j['relationships'] = relationships;
    }
    return j;
  }

  Map<String, Object> _relationships(Resource r) {
    links(Resource r, String name) => {
          'self': link.relationship(r.type, r.id, name),
          'related': link.related(r.type, r.id, name),
        };
    data(Identifier id) => {
          'type': id.type,
          'id': id.id,
        };

    final rel = <String, Object>{};
    r.toOne.forEach(
        (name, id) => rel[name] = {'data': data(id), 'links': links(r, name)});
    r.toMany.forEach((name, ids) =>
        rel[name] = {'data': ids.map(data).toList(), 'links': links(r, name)});
    return rel;
  }

  void _setJsonApi(Map<String, Object> doc) {
    if (includeApiVersion) {
      final api = <String, Object>{'version': version};
      _setMeta(api, meta.jsonApi());
      doc['jsonapi'] = api;
    }
  }

  void _setMeta(Map<String, Object> node, Map<String, Object> meta) {
    if (meta?.isEmpty == false) {
      node['meta'] = meta;
    }
  }
}

abstract class MetaProvider {
  Map<String, Object> topLevel();

  Map<String, Object> jsonApi();
}

class NoMeta implements MetaProvider {
  const NoMeta();

  Map<String, Object> topLevel() => null;

  Map<String, Object> jsonApi() => null;
}

class RenderingException implements Exception {
  final String message;

  RenderingException(this.message);
}

abstract class LinkRenderer {
  String collection(String type);

  String resource(String type, String id);

  String related(String type, String id, String name);

  String relationship(String type, String id, String name);
}

class StandardLinks implements LinkRenderer {
  final String baseUrl;

  StandardLinks(this.baseUrl);

  String collection(String type) => '${baseUrl}/${type}';

  String resource(String type, String id) => '${baseUrl}/${type}/${id}';

  String related(String type, String id, String name) =>
      '${baseUrl}/${type}/${id}/${name}';

  String relationship(String type, String id, String name) =>
      '${baseUrl}/${type}/${id}/relationships/${name}';
}
