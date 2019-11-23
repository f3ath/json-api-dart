import 'package:json_api/src/query/fields.dart';
import 'package:json_api/src/query/include.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/query/sort.dart';

class Query {
  final Page page;
  final Include include;
  final Fields fields;
  final Sort sort;

  Query({this.page, this.include, this.fields, this.sort});

  static Query fromUri(Uri uri) => Query(
      page: Page.fromUri(uri),
      include: Include.fromUri(uri),
      sort: Sort.fromUri(uri),
      fields: Fields.fromUri(uri));
}
