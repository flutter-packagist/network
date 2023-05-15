import 'package:dio/dio.dart';
import '../interceptor/interceptor.dart';
import '../log/options_extra.dart';

class HttpRequestSetting {
  /// 基础URL(host)
  final String baseUrl;

  /// 连接超时时间
  final int connectTimeOut;

  /// 响应超时时间
  final int receiveTimeOut;

  /// 请求内容编码
  final String contentType;

  /// 拦截器集合
  final List<Interceptor>? interceptors;

  /// 请求代理(测试环境)
  final String? delegateHost;

  /// 添加cookie
  final String? dev;

  /// 异常错误处理
  final RearInterceptor? rearInterceptor;

  /// 日志控制
  final OptionsExtra? extra;


  HttpRequestSetting({
    this.baseUrl = "",
    this.connectTimeOut = 10,
    this.receiveTimeOut = 15,
    this.contentType = "application/x-www-form-urlencoded",
    this.interceptors,
    this.delegateHost,
    this.dev,
    this.rearInterceptor,
    this.extra,
  });
}
