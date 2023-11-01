import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

import '../status/http_status_codes.dart';

/// ==============================================================
/// 拦截器：网络请求失败后重试
/// ==============================================================
typedef RetryEvaluator = FutureOr<bool> Function(
  DioException error,
  int attempt,
);
typedef ToNoInternetPageNavigator = Future<void> Function();

/// An interceptor that will try to send failed request again
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required this.dio,
    this.logPrint,
    this.retries = 3,
    this.toNoInternetPageNavigator,
    this.retryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
    this.retryEvaluator,
  });

  /// The original dio
  final Dio dio;

  /// ToNoInternetPage navigate
  final ToNoInternetPageNavigator? toNoInternetPageNavigator;

  /// For logging purpose
  final Function(String message)? logPrint;

  /// The number of retry in case of an error
  final int retries;

  /// The delays between attempts.
  /// Empty [retryDelays] means no delay.
  ///
  /// If [retries] count more than [retryDelays] count,
  /// the last value of [retryDelays] will be used.
  final List<Duration> retryDelays;

  /// Evaluating if a retry is necessary.regarding the error.
  ///
  /// It can be a good candidate for additional operations too, like
  /// updating authentication token in case of a unauthorized error (be careful
  /// with concurrency though).
  ///
  /// Defaults to [defaultRetryEvaluator].
  final RetryEvaluator? retryEvaluator;

  /// Returns true only if the response hasn't been cancelled or got
  /// a bas status code.
  // ignore: avoid-unused-parameters
  FutureOr<bool> defaultRetryEvaluator(
    DioException error,
    int attempt,
  ) async {
    bool shouldRetry;
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      shouldRetry = statusCode != null && needRetry(statusCode);
    } else if (error.type == DioExceptionType.unknown) {
      try {
        final result = await InternetAddress.lookup('baidu.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          shouldRetry = true;
        } else {
          shouldRetry = true;
        }
      } on SocketException catch (_) {
        await toNoInternetPageNavigator?.call();
        shouldRetry = true;
      }
    } else if (error.type == DioExceptionType.connectionError) {
      await toNoInternetPageNavigator?.call();
      shouldRetry = true;
    } else {
      shouldRetry = error.type != DioExceptionType.cancel;
    }
    return shouldRetry;
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.disableRetry) return super.onError(err, handler);
    var attempt = err.requestOptions._attempt + 1;
    final shouldRetry =
        attempt <= retries && await defaultRetryEvaluator(err, attempt);

    if (!shouldRetry) return super.onError(err, handler);

    err.requestOptions._attempt = attempt;
    final delay = _getDelay(attempt);
    logPrint?.call(
      '[${err.requestOptions.uri}] An error occurred during request, '
      'trying again '
      '(attempt: $attempt/$retries, '
      'wait ${delay.inMilliseconds} ms, '
      'error: ${err.error})',
    );

    if (delay != Duration.zero) await Future<void>.delayed(delay);
    var header = <String, dynamic>{}..addAll(err.requestOptions.headers);
    err.requestOptions.headers = header;
    try {
      await dio.fetch<void>(err.requestOptions).then(
            (value) => handler.resolve(value),
          );
    } on DioException catch (e) {
      super.onError(e, handler);
    } catch (e) {
      logPrint!('error: $e');
    }
  }

  Duration _getDelay(int attempt) {
    if (retryDelays.isEmpty) return Duration.zero;
    return attempt - 1 < retryDelays.length
        ? retryDelays[attempt - 1]
        : retryDelays.last;
  }
}

extension RequestOptionsRetry on RequestOptions {
  static const _kAttemptKey = 'dio_attempt';
  static const _kDisableRetryKey = 'dio_disable_retry';

  int get _attempt => extra[_kAttemptKey] ?? 0;

  set _attempt(int value) => extra[_kAttemptKey] = value;

  bool get disableRetry => (extra[_kDisableRetryKey] as bool?) ?? false;

  set disableRetry(bool value) => extra[_kDisableRetryKey] = value;
}
