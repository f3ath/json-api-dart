import 'package:json_api/src/document/document.dart';
import 'package:json_api/src/document/error_object.dart';

class ErrorDocument extends Document {
  final errors = <ErrorObject>[];

  ErrorDocument(Iterable<ErrorObject> errors) {
    this.errors.addAll(errors ?? []);
  }

  toJson() {
    return {'errors': errors};
  }

  static ErrorDocument fromJson(Object json) {
    if (json is Map) {
      final errors = json['errors'];
      if (errors is List) {
        return ErrorDocument(errors.map(ErrorObject.fromJson));
      }
    }
    throw 'Can not parse ErrorDocument from $json';
  }
}
