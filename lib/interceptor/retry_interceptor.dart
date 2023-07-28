import 'dart:async';
import 'dart:io' hide HttpRequest;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../request/http_request.dart';

/// ==============================================================
/// 拦截器：网络连接变化时重试
/// ==============================================================
class RetryOnConnectionChangeInterceptor extends Interceptor {
  final DioConnectivityRequestRetry? requestRetry;

  RetryOnConnectionChangeInterceptor({this.requestRetry});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final requestRetry = this.requestRetry ?? DioConnectivityRequestRetry();
      handler.resolve(await requestRetry.scheduleRetry(err.requestOptions));
      return;
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException err) {
    return err.type != DioExceptionType.unknown &&
        err.type != DioExceptionType.cancel &&
        err.error != null &&
        err.error is SocketException;
  }
}

class DioConnectivityRequestRetry {
  final HttpRequest? httpRequest;
  final Connectivity? connectivity;

  DioConnectivityRequestRetry({this.httpRequest, this.connectivity});

  Future<Response> scheduleRetry(RequestOptions requestOptions) async {
    final httpRequest = this.httpRequest ?? HttpRequest();
    final connectivity = this.connectivity ?? Connectivity();
    final responseCompleter = Completer<Response>();
    // 网络连接状态变化监听
    final StreamSubscription streamSubscription =
        connectivity.onConnectivityChanged.listen(null);
    streamSubscription.onData((connectivityResult) async {
      if (connectivityResult != ConnectivityResult.none) {
        streamSubscription.cancel();
        // Complete the completer instead of returning
        if (responseCompleter.isCompleted) return;
        responseCompleter.complete(
          httpRequest.client?.fetch(requestOptions),
        );
      }
    });
    return responseCompleter.future;
  }
}
