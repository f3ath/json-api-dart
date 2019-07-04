import 'package:json_api/src/server/query/fields.dart';
import 'package:json_api/src/server/query/include.dart';
import 'package:json_api/src/server/query/page.dart';

class Query {
  final Page page;
  final Include include;
  final Fields fields;

  Query(Map<String, List<String>> queryParameters)
      : page = Page.decode(queryParameters),
        include = Include.decode(queryParameters),
        fields = Fields.decode(queryParameters);
}
