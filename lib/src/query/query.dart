import 'package:json_api/src/query/fields.dart';
import 'package:json_api/src/query/include.dart';
import 'package:json_api/src/query/page.dart';
import 'package:json_api/src/query/sort.dart';

class Query {
  final Page page;
  final Include include;
  final Fields fields;
  final Sort sort;
  final Uri _uri;

  Query(this._uri)
      : page = Page.decode(_uri.queryParametersAll),
        include = Include.decode(_uri.queryParametersAll),
        sort = Sort.decode(_uri.queryParametersAll),
        fields = Fields.decode(_uri.queryParametersAll);

  Map<String, List<String>> get parametersAll => _uri.queryParametersAll;

  Map<String, String> get parameters => _uri.queryParameters;
}
