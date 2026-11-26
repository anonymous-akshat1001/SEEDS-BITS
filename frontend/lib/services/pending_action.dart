import 'dart:async';

import 'api_service.dart';

/// Sends an action that must not be lost to a dropped connection (raising a
/// hand, a quiz answer). If there is no connection, [onQueued] is called
/// once and the action is sent again every [every] until it goes through,
/// fails for another reason, or [stillWanted] returns false.
///
/// The returned result is the last attempt's; when [stillWanted] stopped
/// the retries it is a network failure, which callers ignore.
Future<ApiResult<T>> sendWhenConnected<T>(
  Future<ApiResult<T>> Function() attempt, {
  required bool Function() stillWanted,
  void Function()? onQueued,
  Duration every = const Duration(seconds: 3),
}) async {
  var result = await attempt();
  var queued = false;
  while (!result.isSuccess &&
      result.failure!.kind == ApiFailureKind.network &&
      stillWanted()) {
    if (!queued) {
      queued = true;
      onQueued?.call();
    }
    await Future<void>.delayed(every);
    if (!stillWanted()) break;
    result = await attempt();
  }
  return result;
}
