import 'package:json_api/routing.dart';

abstract interface class UriDesign {
  Uri uri(Target target);

  Target? target(Uri uri);
}

typedef UriBuilder = Uri Function(Target target);
typedef TargetMatcher = Target? Function(Uri uri);
