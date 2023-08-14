import 'package:dio/dio.dart';

class HttpRequestSetting {
  /// 基础URL(host)
  final String baseUrl;

  /// 发送超时时间
  final int sendTimeOut;

  /// 连接超时时间
  final int connectTimeOut;

  /// 响应超时时间
  final int receiveTimeOut;

  /// 请求内容编码
  final String contentType;

  /// 拦截器集合
  final List<Interceptor>? interceptors;

  HttpRequestSetting({
    this.baseUrl = "",
    this.sendTimeOut = 20,
    this.connectTimeOut = 60,
    this.receiveTimeOut = 20,
    this.contentType = "application/json",
    this.interceptors,
  });
}
