import 'package:json_api/query.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/src/routing/target.dart';

class Request<T extends CollectionTarget> {
  Request(this.uri, this.target)
      : sort = Sort.fromUri(uri),
        include = Include.fromUri(uri),
        page = Page.fromUri(uri);

  final Uri uri;
  final Include include;
  final Page page;
  final Sort sort;
  final T target;

  bool get isCompound => include.isNotEmpty;
}
