import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/links/links_factory.dart';
import 'package:json_api/src/server/pagination.dart';

class StandardLinks implements LinksFactory {
  StandardLinks(this._requested, this._route);

  final Uri _requested;
  final RouteFactory _route;

  @override
  Map<String, Link> resource(String type, String id) =>
      {'self': Link(_requested)};

  @override
  Map<String, Link> collection(int total, Pagination pagination) =>
      {'self': Link(_requested), ..._navigation(total, pagination)};

  @override
  Map<String, Link> createdResource(String type, String id) =>
      {'self': Link(_route.resource(type, id))};

  @override
  Map<String, Link> relationship(String type, String id, String relationship) =>
      {
        'self': Link(_requested),
        'related': Link(_route.related(type, id, relationship))
      };

  @override
  Map<String, Link> resourceRelationship(
          String type, String id, String relationship) =>
      {
        'self': Link(_route.relationship(type, id, relationship)),
        'related': Link(_route.related(type, id, relationship))
      };

  Map<String, Link> _navigation(int total, Pagination pagination) {
    final page = Page.fromQueryParameters(_requested.queryParametersAll);

    return ({
      'first': pagination.first(),
      'last': pagination.last(total),
      'prev': pagination.prev(page),
      'next': pagination.next(page, total)
    }..removeWhere((k, v) => v == null))
        .map((k, v) => MapEntry(k, Link(v.addToUri(_requested))));
  }
}
