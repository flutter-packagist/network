import 'dart:collection';
import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../interceptor/interceptor.dart';
import 'http_request_setting.dart';
import '../log/options_extra.dart';

typedef HttpRequestSuccessCallback = void Function(Map<String, dynamic> data);
typedef HttpRequestErrorCallback = void Function(
    DioError? error, int? stateCode);
typedef HttpRequestCommonCallback = void Function();

/// 可支持 restful 请求和普通API请求
///  restful api 格式化处理:
///  1. url 定义 xxx/xxx/:key/xxx
///  2. 参数 {key: value}
///  例: /user/:userId  使用{userId: 12} 最终转化为：转换为 /user/12
///
/// GET、POST、DELETE、PATCH、PUT <br>
/// 主要作用为统一处理相关事务：<br>
///  - 统一处理请求前缀；<br>
///  - 统一打印请求信息；<br>
///  - 统一打印响应信息；<br>
///  - 统一打印报错信息；
class HttpRequest {
  static HttpRequest? _instance;

  /// 请求方式
  static const String GET = "get";
  static const String POST = "post";
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  factory HttpRequest() => getInstance();

  static HttpRequest getInstance() {
    _instance ??= HttpRequest._internal();
    return _instance!;
  }

  Dio? _client;

  Dio get client => _client!;

  RearInterceptor? _rearInterceptor;

  OptionsExtra? _extra;

  HttpRequest._internal();

  /// 启动请求工具 并且设置请求参数
  void init(HttpRequestSetting setting) async {
    if (_client == null) {
      BaseOptions options = BaseOptions();
      if (setting.dev != null && setting.dev!.isNotEmpty) {
        options.headers[HttpHeaders.cookieHeader] = "dev=${setting.dev};";
      }
      _rearInterceptor = setting.rearInterceptor;
      _extra = setting.extra ?? OptionsExtra();
      options.connectTimeout = setting.connectTimeOut * 1000;
      options.receiveTimeout = setting.receiveTimeOut * 1000;
      options.baseUrl = setting.baseUrl;
      options.contentType = setting.contentType;
      _client = Dio(options);
      setting.interceptors?.forEach((interceptor) {
        _client!.interceptors.add(interceptor);
      });

      if (kDebugMode && setting.delegateHost != null && setting.delegateHost!.isNotEmpty) {
        (_client!.httpClientAdapter as DefaultHttpClientAdapter)
            .onHttpClientCreate = (client) {
          client.findProxy = (url) {
            return "PROXY ${setting.delegateHost}";
          };
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
        };
      }
    }
  }

  /// Get请求 <br/>
  ///
  /// @param [url] 请求地址 <br/>
  /// @param [params] 请求参数（可选） <br/>
  /// @param [extra] 扩展（可选） <br/>
  /// @param [callBack] 请求结果回调方法（可选） <br/>
  /// @param [errorCallBack] 出错回调（可选） <br/>
  /// @param [commonCallBack] 公共回调方法，成功和失败都会调用（可选） <br/>
  /// @param [token] 取消请求时使用的CancelToken（可选） <br/>
  Future<Map<String, dynamic>?> get(
    String url, {
    Options? options,
    Map<String, dynamic>? params,
    OptionsExtra? extra,
    HttpRequestSuccessCallback? callBack,
    HttpRequestErrorCallback? errorCallBack,
    HttpRequestCommonCallback? commonCallBack,
    CancelToken? token,
  }) async {
    return await _request(
      url,
      method: GET,
      options: options,
      params: params,
      extra: extra,
      callBack: callBack,
      errorCallBack: errorCallBack,
      commonCallBack: commonCallBack,
      token: token,
    );
  }

  /// Post请求 <br/>
  ///
  /// @param [url] 请求地址 <br/>
  /// @param [params] 请求参数（可选） <br/>
  /// @param [extra] 扩展（可选） <br/>
  /// @param [callBack] 请求结果回调方法（可选） <br/>
  /// @param [errorCallBack] 出错回调（可选） <br/>
  /// @param [commonCallBack] 公共回调方法，成功和失败都会调用（可选） <br/>
  /// @param [token] 取消请求时使用的CancelToken（可选） <br/>
  Future<Map<String, dynamic>?> post(
    String url, {
    Options? options,
    Map<String, dynamic>? params,
    Map<String, dynamic>? formData,
    OptionsExtra? extra,
    HttpRequestSuccessCallback? callBack,
    HttpRequestErrorCallback? errorCallBack,
    HttpRequestCommonCallback? commonCallBack,
    CancelToken? token,
  }) async {
    return await _request(
      url,
      method: POST,
      options: options,
      params: params,
      formData: formData,
      extra: extra,
      callBack: callBack,
      errorCallBack: errorCallBack,
      commonCallBack: commonCallBack,
      token: token,
    );
  }

  /// DELETE请求 <br/>
  ///
  /// @param [url] 请求地址 <br/>
  /// @param [params] 请求参数（可选） <br/>
  /// @param [extra] 扩展（可选） <br/>
  /// @param [callBack] 请求结果回调方法（可选） <br/>
  /// @param [errorCallBack] 出错回调（可选） <br/>
  /// @param [commonCallBack] 公共回调方法，成功和失败都会调用（可选） <br/>
  /// @param [token] 取消请求时使用的CancelToken（可选） <br/>
  Future<Map<String, dynamic>?> delete(
    String url, {
    Options? options,
    Map<String, dynamic>? params,
    OptionsExtra? extra,
    HttpRequestSuccessCallback? callBack,
    HttpRequestErrorCallback? errorCallBack,
    HttpRequestCommonCallback? commonCallBack,
    CancelToken? token,
  }) async {
    return await _request(
      url,
      method: DELETE,
      options: options,
      params: params,
      extra: extra,
      callBack: callBack,
      errorCallBack: errorCallBack,
      commonCallBack: commonCallBack,
      token: token,
    );
  }

  /// PATCH请求 <br/>
  ///
  /// @param [url] 请求地址 <br/>
  /// @param [params] 请求参数（可选） <br/>
  /// @param [extra] 扩展（可选） <br/>
  /// @param [callBack] 请求结果回调方法（可选） <br/>
  /// @param [errorCallBack] 出错回调（可选） <br/>
  /// @param [commonCallBack] 公共回调方法，成功和失败都会调用（可选） <br/>
  /// @param [token] 取消请求时使用的CancelToken（可选） <br/>
  Future<Map<String, dynamic>?> patch(
    String url, {
    Options? options,
    Map<String, dynamic>? params,
    OptionsExtra? extra,
    HttpRequestSuccessCallback? callBack,
    HttpRequestErrorCallback? errorCallBack,
    HttpRequestCommonCallback? commonCallBack,
    CancelToken? token,
  }) async {
    return await _request(
      url,
      method: PATCH,
      options: options,
      params: params,
      extra: extra,
      callBack: callBack,
      errorCallBack: errorCallBack,
      commonCallBack: commonCallBack,
      token: token,
    );
  }

  /// Put上传 <br/>
  ///
  /// @param [url] 请求地址 <br/>
  /// @param [formData] 请求form表单数据（可选） <br/>
  /// @param [extra] 扩展（可选） <br/>
  /// @param [callBack] 请求结果回调方法（可选） <br/>
  /// @param [errorCallBack] 出错回调（可选） <br/>
  /// @param [commonCallBack] 公共回调方法，成功和失败都会调用（可选） <br/>
  /// @param [progressCallBack] 请求进度回调方法 <br/>
  /// @param [onReceiveProgress] 接收进度回调方法 <br/>
  /// @param [token] 取消请求时使用的CancelToken（可选） <br/>
  Future<Map<String, dynamic>?> put(
    String url, {
    Options? options,
    Map<String, dynamic>? params,
    OptionsExtra? extra,
    HttpRequestSuccessCallback? callBack,
    HttpRequestErrorCallback? errorCallBack,
    HttpRequestCommonCallback? commonCallBack,
    ProgressCallback? progressCallBack,
    CancelToken? token,
  }) async {
    return await _request(
      url,
      method: PUT,
      options: options,
      params: params,
      extra: extra,
      callBack: callBack,
      errorCallBack: errorCallBack,
      commonCallBack: commonCallBack,
      progressCallBack: progressCallBack,
      token: token,
    );
  }

  /// Post上传 <br/>
  ///
  /// @param [url] 请求地址 <br/>
  /// @param [formData] 请求form表单数据（可选） <br/>
  /// @param [extra] 扩展（可选） <br/>
  /// @param [callBack] 请求结果回调方法（可选） <br/>
  /// @param [errorCallBack] 出错回调（可选） <br/>
  /// @param [commonCallBack] 公共回调方法，成功和失败都会调用（可选） <br/>
  /// @param [progressCallBack] 请求进度回调方法 <br/>
  /// @param [token] 取消请求时使用的CancelToken（可选） <br/>
  Future<Map<String, dynamic>?> postUpload(
    String url, {
    Options? options,
    Map<String, dynamic>? formData,
    OptionsExtra? extra,
    HttpRequestSuccessCallback? callBack,
    HttpRequestErrorCallback? errorCallBack,
    HttpRequestCommonCallback? commonCallBack,
    ProgressCallback? progressCallBack,
    CancelToken? token,
  }) async {
    return await _request(
      url,
      method: POST,
      options: options,
      formData: formData,
      extra: extra,
      callBack: callBack,
      errorCallBack: errorCallBack,
      commonCallBack: commonCallBack,
      progressCallBack: progressCallBack,
      token: token,
    );
  }

  /// 统一请求方法 <br/>
  ///
  /// @param [url] 请求地址 <br/>
  /// @param [method] 请求方式：GET、POST、DELETE、PATCH、PUT（可选）<br/>
  /// @param [params] 请求参数（可选） <br/>
  /// @param [formData] 请求form表单数据（可选） <br/>
  /// @param [extra] 扩展（可选） <br/>
  /// @param [callBack] 请求结果回调方法（可选） <br/>
  /// @param [errorCallBack] 出错回调（可选） <br/>
  /// @param [commonCallBack] 公共回调方法，成功和失败都会调用（可选） <br/>
  /// @param [progressCallBack] 请求进度回调方法（可选） <br/>
  /// @param [token] 取消请求时使用的CancelToken（可选） <br/>
  Future<Map<String, dynamic>?> _request(
    String url, {
    String? method,
    Options? options,
    Map<String, dynamic>? params,
    Map<String, dynamic>? formData,
    OptionsExtra? extra,
    HttpRequestSuccessCallback? callBack,
    HttpRequestErrorCallback? errorCallBack,
    HttpRequestCommonCallback? commonCallBack,
    ProgressCallback? progressCallBack,
    CancelToken? token,
  }) async {

    Map<String, dynamic> newParams = HashMap<String, dynamic>();
    params = params ?? {};
    params.forEach((key, value) {
      if(url.contains(":$key")){
        url = url.replaceAll(':$key', value.toString());
      } else {
        newParams.putIfAbsent(key, () => value);
      }
    });

    //请求扩展
    options ??= Options();
    extra ??= _extra ?? OptionsExtra();
    options.extra = {
      singleRequestShowLogKey: extra.singleRequestShowLog,
      singleRequestHeaderShowLogKey: extra.singleRequestHeaderShowLog,
      singleRequestBodyShowLogKey: extra.singleRequestBodyShowLog,
      singleResponseHeaderShowLogKey: extra.singleResponseHeaderShowLog,
      singleResponseBodyShowLogKey: extra.singleResponseBodyShowLog,
      singleErrorShowLogKey: extra.singleErrorShowLog,
      singleShowErrorToastKey: extra.singleErrorToastKey,
    };

    late Response response;
    try {
      switch (method) {
        case GET:
          response = await _client!.get(
            url,
            options: options,
            queryParameters: newParams,
            cancelToken: token,
          );
          break;
        case POST:
          response = await _client!.post(
            url,
            data: newParams.isNotEmpty ? newParams : formData != null ? FormData.fromMap(formData) : null,
            options: options,
            onSendProgress: progressCallBack,
            cancelToken: token,
          );
          break;
        case DELETE:
          response = await _client!.delete(
            url,
            options: options,
            queryParameters: newParams,
            cancelToken: token,
          );
          break;
        case PUT:
          response = await _client!.put(
            url,
            options: options,
            queryParameters: newParams,
            cancelToken: token,
          );
          break;
        case PATCH:
          response = await _client!.patch(
            url,
            options: options,
            queryParameters: newParams,
            cancelToken: token,
          );
          break;
      }

      commonCallBack?.call();
      if(null == _rearInterceptor){
        callBack?.call(_resultToMap(response));
      } else {
        _rearInterceptor?.onRequest(callBack, _resultToMap(response));
      }
      return _resultToMap(response);
    } on DioError catch (e) {
      commonCallBack?.call();
      if(null == _rearInterceptor){
        errorCallBack?.call(e, e.response?.statusCode ?? 0);
      } else {
        _rearInterceptor?.onError(errorCallBack, e);
      }
      return _resultToMap(e.response);
    }
  }

  Map<String, dynamic> _resultToMap(Response<dynamic>? response) {
    if (response?.data == null) return {};
    var result = response!.data;
    if (result is Map) return response.data;
    if (result is List) return {"result": result};
    if (result is String) return {"result": result};
    if (result is int) return {"result": result};
    if (result is bool) return {"result": result};
    if (result is double) return {"result": result};
    return response.data;
  }
}
