import 'package:json_api/src/routing/target.dart';

abstract class TargetMatcher {
  /// Nullable. Returns the URI target.
  Target /*?*/ match(Uri uri);
}
