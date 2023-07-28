import 'package:dio/dio.dart';

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

  HttpRequestSetting({
    this.baseUrl = "",
    this.connectTimeOut = 20,
    this.receiveTimeOut = 15,
    this.contentType = "application/json",
    this.interceptors,
  });
}
