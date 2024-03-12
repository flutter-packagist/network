import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:log_wrapper/log/log.dart';

import '../adapter/dio_adapter.dart';
import '../resolve/safe_convert.dart';
import 'http_request_setting.dart';

const String dioExtraBind = 'dio_bind';

typedef OnSuccess = void Function(Map<String, dynamic> data);
typedef OnFailed = void Function(int? stateCode, DioException? error);
typedef OnCommon = void Function();

/// 可支持 restful 请求和普通API请求
///
/// GET、POST、PUT、HEAD、DELETE、PATCH、DOWNLOAD <br>
/// 主要作用为统一处理相关事务：<br>
///  - 统一处理请求前缀；<br>
///  - 统一打印请求信息；<br>
///  - 统一打印响应信息；<br>
///  - 统一打印报错信息；
class HttpRequest {
  factory HttpRequest() {
    _instance ??= HttpRequest._();
    return _instance!;
  }

  static HttpRequest? _instance;

  HttpRequest._();

  Dio? _client;

  Dio? get client => _client;

  /// 初始化
  void init(HttpRequestSetting setting) {
    BaseOptions options = BaseOptions();
    options.baseUrl = setting.baseUrl;
    options.contentType = setting.contentType;
    options.sendTimeout = Duration(seconds: setting.sendTimeOut);
    options.connectTimeout = Duration(seconds: setting.connectTimeOut);
    options.receiveTimeout = Duration(seconds: setting.receiveTimeOut);
    _client = Dio(options);
    _client!.httpClientAdapter = getClientAdapter();
    if (setting.interceptors != null) {
      _client!.interceptors.addAll(setting.interceptors!);
    }
  }

  /// 设置代理（不支持Web）
  void setupProxy(String host, int port) {
    _client!.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.findProxy = (uri) => 'PROXY $host:$port';
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );
  }

  /// HTTPS证书验证 <br><br>
  /// use openssl to read the SHA256 value of a certificate: <br>
  /// openssl s_client -servername pinning-test.badssl.com -connect pinning-test.badssl.com:443
  /// < /dev/null 2>/dev/null \ | openssl x509 -noout -fingerprint -sha256
  void setupHttpsCertificateVerification(String fingerprint) {
    _client!.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Don't trust any certificate just because their root cert is trusted.
        final HttpClient client =
            HttpClient(context: SecurityContext(withTrustedRoots: false));
        // You can test the intermediate / root cert here. We just ignore it.
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
      validateCertificate: (cert, host, port) {
        // Check that the cert fingerprint matches the one we expect.
        // We definitely require _some_ certificate.
        if (cert == null) {
          return false;
        }
        // Validate it any way you want. Here we only check that
        // the fingerprint matches the OpenSSL SHA256.
        return fingerprint == sha256.convert(cert.der).toString();
      },
    );
  }

  /// 证书颁发机构验证
  void setupCertificateAuthorityVerification(String pem) {
    _client!.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return cert.pem == pem; // Verify the certificate.
        };
        return client;
      },
    );
  }

  /// GET 请求 <br/>
  ///
  /// @param [url]                请求地址 <br/>
  /// @param [params]             请求参数（可选） <br/>
  /// @param [options]            请求额外设置，包括Header等（可选） <br/>
  /// @param [cancelToken]        取消请求时使用的CancelToken（可选） <br/>
  /// @param [onReceiveProgress]  请求响应进度回调方法（可选） <br/>
  /// @param [onSuccess]          请求成功回调方法（可选） <br/>
  /// @param [onFailed]           请求失败回调方法（可选） <br/>
  /// @param [onCommon]           公共回调方法，成功和失败都会调用，在onSuccess和onFailed之前调用（可选） <br/>
  Future<dynamic> get<T>(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
    dynamic bind,
  }) async {
    return _client!
        .get<T>(
          _handleUrl(url, params),
          queryParameters: _handleParams(url, params),
          options: _bindCancelToken(options, bind),
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress,
        )
        ._handleCallback(onSuccess, onFailed, onCommon);
  }

  /// POST 请求 <br/>
  ///
  /// @param [url]                请求地址 <br/>
  /// @param [params]             请求参数（可选） <br/>
  /// @param [options]            请求额外设置，包括Header等（可选） <br/>
  /// @param [cancelToken]        取消请求时使用的CancelToken（可选） <br/>
  /// @param [onSendProgress]     请求上传进度回调方法（可选） <br/>
  /// @param [onReceiveProgress]  请求响应进度回调方法（可选） <br/>
  /// @param [onSuccess]          请求成功回调方法（可选） <br/>
  /// @param [onFailed]           请求失败回调方法（可选） <br/>
  /// @param [onCommon]           公共回调方法，成功和失败都会调用，在onSuccess和onFailed之前调用（可选） <br/>
  Future<dynamic> post<T>(
    String url, {
    Map<String, dynamic>? params,
    Map<String, dynamic>? formData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
    dynamic bind,
  }) async {
    String uri = _handleUrl(url, params);
    Object? data = _handleParams(url, params);
    if (formData != null && formData.isNotEmpty) {
      uri = url;
      data = FormData.fromMap(formData);
    }
    return _client!
        .post<T>(
          uri,
          data: data,
          options: _bindCancelToken(options, bind),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        )
        ._handleCallback(onSuccess, onFailed, onCommon);
  }

  /// PUT 请求 <br/>
  ///
  /// @param [url]                请求地址 <br/>
  /// @param [params]             请求参数（可选） <br/>
  /// @param [options]            请求额外设置，包括Header等（可选） <br/>
  /// @param [cancelToken]        取消请求时使用的CancelToken（可选） <br/>
  /// @param [onSendProgress]     请求上传进度回调方法（可选） <br/>
  /// @param [onReceiveProgress]  请求响应进度回调方法（可选） <br/>
  /// @param [onSuccess]          请求成功回调方法（可选） <br/>
  /// @param [onFailed]           请求失败回调方法（可选） <br/>
  /// @param [onCommon]           公共回调方法，成功和失败都会调用，在onSuccess和onFailed之前调用（可选） <br/>
  Future<dynamic> put<T>(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
    dynamic bind,
  }) async {
    return _client!
        .put<T>(
          _handleUrl(url, params),
          data: _handleParams(url, params),
          options: _bindCancelToken(options, bind),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        )
        ._handleCallback(onSuccess, onFailed, onCommon);
  }

  /// HEAD 请求 <br/>
  ///
  /// @param [url]                请求地址 <br/>
  /// @param [params]             请求参数（可选） <br/>
  /// @param [options]            请求额外设置，包括Header等（可选） <br/>
  /// @param [cancelToken]        取消请求时使用的CancelToken（可选） <br/>
  /// @param [onSuccess]          请求成功回调方法（可选） <br/>
  /// @param [onFailed]           请求失败回调方法（可选） <br/>
  /// @param [onCommon]           公共回调方法，成功和失败都会调用，在onSuccess和onFailed之前调用（可选） <br/>
  Future<dynamic> head<T>(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
    dynamic bind,
  }) async {
    return _client!
        .head<T>(
          _handleUrl(url, params),
          data: _handleParams(url, params),
          options: _bindCancelToken(options, bind),
          cancelToken: cancelToken,
        )
        ._handleCallback(onSuccess, onFailed, onCommon);
  }

  /// DELETE 请求 <br/>
  ///
  /// @param [url]                请求地址 <br/>
  /// @param [params]             请求参数（可选） <br/>
  /// @param [options]            请求额外设置，包括Header等（可选） <br/>
  /// @param [cancelToken]        取消请求时使用的CancelToken（可选） <br/>
  /// @param [onSuccess]          请求成功回调方法（可选） <br/>
  /// @param [onFailed]           请求失败回调方法（可选） <br/>
  /// @param [onCommon]           公共回调方法，成功和失败都会调用，在onSuccess和onFailed之前调用（可选） <br/>
  Future<dynamic> delete<T>(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
    dynamic bind,
  }) async {
    return _client!
        .delete<T>(
          _handleUrl(url, params),
          data: _handleParams(url, params),
          options: _bindCancelToken(options, bind),
          cancelToken: cancelToken,
        )
        ._handleCallback(onSuccess, onFailed, onCommon);
  }

  /// PATCH 请求 <br/>
  ///
  /// @param [url]                请求地址 <br/>
  /// @param [params]             请求参数（可选） <br/>
  /// @param [options]            请求额外设置，包括Header等（可选） <br/>
  /// @param [cancelToken]        取消请求时使用的CancelToken（可选） <br/>
  /// @param [onSendProgress]     请求上传进度回调方法（可选） <br/>
  /// @param [onReceiveProgress]  请求响应进度回调方法（可选） <br/>
  /// @param [onSuccess]          请求成功回调方法（可选） <br/>
  /// @param [onFailed]           请求失败回调方法（可选） <br/>
  /// @param [onCommon]           公共回调方法，成功和失败都会调用，在onSuccess和onFailed之前调用（可选） <br/>
  Future<dynamic> patch<T>(
    String url, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
    dynamic bind,
  }) async {
    return _client!
        .patch<T>(
          _handleUrl(url, params),
          data: _handleParams(url, params),
          options: _bindCancelToken(options, bind),
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        )
        ._handleCallback(onSuccess, onFailed, onCommon);
  }

  /// DOWNLOAD 请求 <br/>
  ///
  /// @param [url]                请求地址 <br/>
  /// @param [savePath]           文件下载路径 <br/>
  /// @param [params]             请求参数（可选） <br/>
  /// @param [options]            请求额外设置，包括Header等（可选） <br/>
  /// @param [cancelToken]        取消请求时使用的CancelToken（可选） <br/>
  /// @param [onReceiveProgress]  请求响应进度回调方法（可选） <br/>
  /// @param [onSuccess]          请求成功回调方法（可选） <br/>
  /// @param [onFailed]           请求失败回调方法（可选） <br/>
  /// @param [onCommon]           公共回调方法，成功和失败都会调用，在onSuccess和onFailed之前调用（可选） <br/>
  ///
  /// [deleteOnError] 当下载失败时，是否删除已下载的文件，默认为true。 <br/>
  ///
  /// [lengthHeader] 原始文件的实际大小（未压缩）。
  /// 当文件被压缩时：
  /// 1. 如果该值为 'content-length'，则 [onReceiveProgress] 的 'total' 参数将为 -1
  /// 2. 如果该值不是 'content-length'，可能是自定义标头指示原始文件大小，则 [onReceiveProgress] 的 'total' 参数将是该标头值。
  /// 您还可以通过将 'accept-encoding' 标头值指定为 '*' 来禁用压缩，以确保 [onReceiveProgress] 的 'total' 参数值不为 -1。 例如：
  Future<dynamic> download(
    String url,
    dynamic savePath, {
    Map<String, dynamic>? params,
    Options? options,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    ProgressCallback? onReceiveProgress,
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
    dynamic bind,
  }) async {
    return _client!
        .download(
          _handleUrl(url, params),
          savePath,
          data: _handleParams(url, params),
          options: _bindCancelToken(options, bind),
          cancelToken: cancelToken,
          queryParameters: queryParameters,
          deleteOnError: deleteOnError,
          lengthHeader: lengthHeader,
          onReceiveProgress: onReceiveProgress,
        )
        ._handleCallback(onSuccess, onFailed, onCommon);
  }

  /// 处理链接参数化 <br/>
  /// restful api 格式化处理
  /// 例：将 /user/:userId 转换为 /user/12
  String _handleUrl(String url, Map<String, dynamic>? params) {
    params?.forEach((key, value) {
      if (url.contains(":$key")) {
        url = url.replaceAll(':$key', value.toString());
      }
    });
    return url;
  }

  /// 处理链接参数化 <br/>
  /// restful api 格式化处理
  /// 例：将 /user/:userId 转换为 /user/12
  Map<String, dynamic>? _handleParams(
      String url, Map<String, dynamic>? params) {
    params?.removeWhere((key, value) => url.contains(":$key"));
    return params;
  }

  /// 绑定请求额外参数，用于页面销毁时自动取消请求
  Options? _bindCancelToken(Options? options, dynamic bind) {
    options ??= Options(extra: <String, dynamic>{});
    options.extra ??= <String, dynamic>{};
    options.extra!.putIfAbsent(dioExtraBind, () => bind);
    return options;
  }
}

extension FutureCallback<T> on Future<Response<T>> {
  /// 回调统一处理 <br/>
  /// @param [onSuccess] 请求成功回调方法 <br/>
  /// @param [onFailed] 请求失败回调方法 <br/>
  /// @param [onCommon] 请求公共回调方法 <br/>
  Future<dynamic> _handleCallback(
    OnSuccess? onSuccess,
    OnFailed? onFailed,
    OnCommon? onCommon,
  ) async {
    return then(
      (response) {
        onCommon?.call();
        onSuccess?.call(_responseToMap(response));
      },
      onError: (error) {
        onCommon?.call();
        _handleError(onFailed, exception: error);
      },
    );
  }

  /// 异常处理<br/>
  ///
  /// @param [onFailed] 错误处理回调方法 <br/>
  /// @param [error] DioException由dio封装的错误信息（可选） <br/>
  void _handleError(OnFailed? onFailed, {dynamic exception}) {
    if (onFailed != null) {
      onFailed(exception?.response?.statusCode, exception);
      return;
    }

    String? errorOutput = "";
    if (exception is DioException) {
      switch (exception.type) {
        case DioExceptionType.connectionTimeout:
          errorOutput = "连接服务器超时";
          break;
        case DioExceptionType.sendTimeout:
          errorOutput = "请求服务器超时";
          break;
        case DioExceptionType.receiveTimeout:
          errorOutput = "服务器响应超时";
          break;
        case DioExceptionType.badCertificate:
          errorOutput = "证书校验失败";
          break;
        case DioExceptionType.cancel:
          errorOutput = "网络请求取消";
          break;
        case DioExceptionType.connectionError:
          errorOutput = "网络连接错误";
          break;
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          final data = exception.response?.data;
          errorOutput = data is Map
              ? asString(data.cast<String, dynamic>(), "message")
              : data?.toString();
          errorOutput ??= "未知错误";
          break;
      }
    } else if (exception.error is SocketException) {
      errorOutput = "请检查网络连接";
    } else {
      errorOutput = exception ?? "未知错误";
    }

    logE(errorOutput);
  }

  /// 将请求结果转换为Map
  Map<String, dynamic> _responseToMap(Response<dynamic> response) {
    if (response.data == null) return {};
    var result = response.data;
    if (result is Map) return response.data;
    if (result is List) return {"result": result};
    if (result is String) return {"result": result};
    if (result is int) return {"result": result};
    if (result is bool) return {"result": result};
    if (result is double) return {"result": result};
    return response.data;
  }
}
