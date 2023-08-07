import 'package:dio/dio.dart';
import 'package:log_wrapper/log/log.dart';
import 'package:network/network.dart';

/// ==============================================================
/// 拦截器：取消网络请求
/// ==============================================================
final Map<dynamic, dynamic> cancelTokenMap = <dynamic, dynamic>{};

class CancelTokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    dynamic bind = options.extra[dioExtraBind];
    options.cancelToken ??= CancelTokenPool().add(bind);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    var options = response.requestOptions;
    dynamic bind = options.extra[dioExtraBind];
    if (options.cancelToken != null) {
      CancelTokenPool().remove(bind, options.cancelToken!);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    var options = err.requestOptions;
    dynamic bind = options.extra[dioExtraBind];
    if (options.cancelToken != null) {
      CancelTokenPool().remove(bind, options.cancelToken!);
    }
    if (err.type == DioExceptionType.cancel) return;
    super.onError(err, handler);
  }
}

class CancelTokenPool {
  factory CancelTokenPool() => _instance ??= CancelTokenPool._();

  static CancelTokenPool? _instance;

  CancelTokenPool._();

  final Map<dynamic, List<CancelToken>> cancelTokenMap =
      <dynamic, List<CancelToken>>{};

  CancelToken add(dynamic bind) {
    if (!cancelTokenMap.containsKey(bind)) {
      cancelTokenMap[bind] = <CancelToken>[];
    }
    final newCancelToken = CancelToken();
    cancelTokenMap[bind]!.add(newCancelToken);
    logV("[CancelTokenPool] add: $bind token => $newCancelToken");
    return newCancelToken;
  }

  void remove(dynamic bind, CancelToken cancelToken) {
    if (!cancelTokenMap.containsKey(bind)) return;
    bool result = cancelTokenMap[bind]!.remove(cancelToken);
    logV("[CancelTokenPool] remove ${result ? "success" : "failed"}: "
        "$bind =>token: $cancelToken");
  }

  void cancel(dynamic bind) {
    if (!cancelTokenMap.containsKey(bind)) return;
    cancelTokenMap[bind]?.forEach((element) {
      element.cancel();
    });
    cancelTokenMap.remove(bind);
    logV("[CancelTokenPool] cancel all $bind");
  }
}
