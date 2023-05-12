import 'package:dio/dio.dart';

///网络请求-头部拦截器
class BaseInterceptor extends InterceptorsWrapper {

  /// 添加Header拦截器 <br/>
  addHeaderInterceptors(RequestOptions options) {
    /// todo
  }

  /// 发起请求
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    addHeaderInterceptors(options);
    return super.onRequest(options, handler);
  }

  /// 响应请求
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    return super.onResponse(response, handler);
  }

  /// 请求响应错误
  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    return super.onError(err, handler);
  }
}
