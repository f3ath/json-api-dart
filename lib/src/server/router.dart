import 'package:http_interop/http_interop.dart';
import 'package:json_api/routing.dart';
import 'package:json_api/server.dart';

typedef TargetResolver = Target? Function(Request);
typedef ControllerResolver = Controller? Function(Request, Target);
typedef PayloadHandler = Future<Response?> Function(JsonApiRequest request, Controller controller);

Handler router({
  required Target? Function(Request) getTarget,
  required Controller? Function(Request, Target) getController,
  PayloadHandler? beforeDispatch,
}) => (request) async {
  final target = getTarget(request) ?? (throw UnmatchedTarget(request.uri));
  final controller = getController(request, target) ?? (throw CollectionNotFound(target.type));
  final resolved = await JsonApiRequest.resolve(request, target);
  return (await beforeDispatch?.call(resolved, controller)) ?? await resolved.dispatch(controller);
};
