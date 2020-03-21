import 'package:json_api/document.dart';
import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/server/links/links_factory.dart';
import 'package:json_api/src/server/pagination.dart';
import 'package:json_api/src/server/relationship_target.dart';
import 'package:json_api/src/server/resource_target.dart';

class StandardLinks implements LinksFactory {
  StandardLinks(this._requested, this._route);

  final Uri _requested;
  final RouteFactory _route;

  @override
  Map<String, Link> resource(String type, String id) => {'self': Link(_requested)};

  @override
  Map<String, Link> collection(int total, Pagination pagination) =>
      {'self': Link(_requested), ..._navigation(total, pagination)};

  @override
  Map<String, Link> createdResource(ResourceTarget target) =>
      {'self': Link(_route.resource(target.type, target.id))};

  @override
  Map<String, Link> relationship(RelationshipTarget target) => {
        'self': Link(_requested),
        'related':
            Link(_route.related(target.type, target.id, target.relationship))
      };

  @override
  Map<String, Link> resourceRelationship(RelationshipTarget target) => {
        'self': Link(
            _route.relationship(target.type, target.id, target.relationship)),
        'related':
            Link(_route.related(target.type, target.id, target.relationship))
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
