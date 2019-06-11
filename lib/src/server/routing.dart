import 'package:json_api/src/server/request_target.dart';
import 'package:json_api/src/url_design.dart';

/// The routing schema (URL Design) defines the design of URLs used by the server.
class Routing extends RecommendedUrlDesign {
  Routing(Uri base) : super(base);

  /// This function must return one of the following:
  /// - [CollectionTarget]
  /// - [ResourceTarget]
  /// - [RelationshipTarget]
  /// - [RelatedTarget]
  /// - null if the target can not be determined
  ControllerDispatcherProvider getTarget(Uri uri) {
    final seg = uri.pathSegments;
    switch (seg.length) {
      case 1:
        return CollectionTarget(seg[0]);
      case 2:
        return ResourceTarget(seg[0], seg[1]);
      case 3:
        return RelatedTarget(seg[0], seg[1], seg[2]);
      case 4:
        if (seg[2] == 'relationships') {
          return RelationshipTarget(seg[0], seg[1], seg[3]);
        }
    }
    return null;
  }
}
