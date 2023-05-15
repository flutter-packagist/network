import 'package:dio/dio.dart';
import '../network/http_request.dart';

///网络请求-头部拦截器
class BaseInterceptor extends InterceptorsWrapper {

  /// 添加Header拦截器 <br/>
  void addHeaderInterceptors(RequestOptions options) {}

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


/// 后置请求拦截器
abstract class RearInterceptor {


  /// 响应成功 这里可以作最外层解析
  void onRequest(HttpRequestSuccessCallback? callBack, Map<String, dynamic>? response);


  /// 响应错误 这里可以坐公告提醒处理等
  void onError(HttpRequestErrorCallback? errorCallback, DioError? error);

}
