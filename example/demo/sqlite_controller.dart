import 'dart:convert';

import 'package:json_api/document.dart';
import 'package:json_api/http.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';
import 'package:json_api/src/http/media_type.dart';
import 'package:json_api/src/server/model.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

class SqliteController implements JsonApiController<Future<HttpResponse>> {
  SqliteController(this.db);

  static SqliteController inMemory(String init) {
    final db = sqlite3.openInMemory();
    db.execute(init);
    return SqliteController(db);
  }

  final Database db;

  final urlDesign = RecommendedUrlDesign.pathOnly;

  @override
  Future<HttpResponse> fetchCollection(
      HttpRequest request, CollectionTarget target) async {
    final collection = db
        .select('SELECT * FROM ${_sanitize(target.type)}')
        .map(_resourceFromRow(target.type));
    final doc = OutboundDataDocument.collection(collection)
      ..links['self'] = Link(target.map(urlDesign));
    return HttpResponse(200, body: jsonEncode(doc), headers: {
      'content-type': MediaType.jsonApi,
    });
  }

  @override
  Future<HttpResponse> fetchResource(
      HttpRequest request, ResourceTarget target) async {
    final resource = _fetchResource(target.type, target.id);
    final self = Link(target.map(urlDesign));
    final doc = OutboundDataDocument.resource(resource)..links['self'] = self;
    return HttpResponse(200,
        body: jsonEncode(doc), headers: {'content-type': MediaType.jsonApi});
  }

  @override
  Future<HttpResponse> createResource(
      HttpRequest request, CollectionTarget target) async {
    final doc = InboundDocument(jsonDecode(request.body));
    final res = doc.newResource();
    final model = Model(res.type)..attributes.addAll(res.attributes);
    final id = res.id ?? Uuid().v4();
    if (res.id == null) {
      _createResource(target.type, id, model);
      final resource = _fetchResource(target.type, id);

      final self =
          Link(ResourceTarget(resource.type, resource.id).map(urlDesign));
      resource.links['self'] = self;
      final doc = OutboundDataDocument.resource(resource)..links['self'] = self;
      return HttpResponse(201, body: jsonEncode(doc), headers: {
        'content-type': MediaType.jsonApi,
        'location': self.uri.toString()
      });
    }
    _createResource(target.type, res.id, model);
    return HttpResponse(204);
  }

  void _createResource(String type, String id, Model model) {
    final columns = ['id', ...model.attributes.keys].map(_sanitize);
    final values = [id, ...model.attributes.values];
    final sql = '''
      INSERT INTO ${_sanitize(type)}
      (${columns.join(', ')})
      VALUES (${values.map((_) => '?').join(', ')})
    ''';
    final s = db.prepare(sql);
    s.execute(values);
  }

  Resource _fetchResource(String type, String id) {
    final sql = 'SELECT * FROM ${_sanitize(type)} WHERE id = ?';
    final results = db.select(sql, [id]);
    if (results.isEmpty) throw ResourceNotFound(type, id);
    return _resourceFromRow(type)(results.first);
  }

  Resource Function(Row row) _resourceFromRow(String type) =>
      (Row row) => Resource(type, row['id'].toString())
        ..attributes.addAll({
          for (var _ in row.keys.where((_) => _ != 'id')) _.toString(): row[_]
        });

  String _sanitize(String value) => value.replaceAll(_nonAlpha, '');

  static final _nonAlpha = RegExp('[^a-z]');
}

class ResourceNotFound implements Exception {
  ResourceNotFound(String type, String id);
}
