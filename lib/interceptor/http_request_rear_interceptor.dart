import 'package:dio/dio.dart';
import '../network/http_request.dart';

/// @title
/// @description 后置请求拦截器
/// @return
/// @updateTime 2022/2/8 11:40 上午
/// @author 10456
abstract class HttpRequestRearInterceptor {


  /// @title onRequest
  /// @description 响应成功 这里可以作最外层解析
  /// @param: callBack
  /// @param: response
  /// @return void
  /// @updateTime 2022/2/8 11:40 上午
  /// @author 10456
  void onRequest(HttpRequestSuccessCallback? callBack, Map<String, dynamic>? response);


  /// @title onError
  /// @description 响应错误 这里可以坐公告提醒处理等
  /// @param: errorCallback
  /// @param: error
  /// @return void
  /// @updateTime 2022/2/8 11:40 上午
  /// @author 10456
  void onError(HttpRequestErrorCallback? errorCallback, DioError? error);

}
