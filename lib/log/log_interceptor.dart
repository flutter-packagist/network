import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'options_extra.dart';

/// [LogPrintInterceptor] is used to print logs during network requests.
/// It's better to add [LogPrintInterceptor] to the tail of the interceptor queue,
/// otherwise the changes made in the interceptor behind A will not be printed out.
/// This is because the execution of interceptors is in the order of addition.
class LogPrintInterceptor extends Interceptor {
  LogPrintInterceptor({
    this.request = true,
    this.requestHeader = true,
    this.requestBody = false,
    this.responseHeader = false,
    this.responseBody = true,
    this.error = true,
    this.logPrint = print,
    this.showLog = kDebugMode,
  });

  /// Whether to print log [Options]
  bool showLog;

  /// Print request [Options]
  bool request;

  /// Print request header [Options.headers]
  bool requestHeader;

  /// Print request data [Options.data]
  bool requestBody;

  /// Print [Response.data]
  bool responseBody;

  /// Print [Response.headers]
  bool responseHeader;

  /// Print error message
  bool error;

  /// Log printer; defaults print log to console.
  /// In flutter, you'd better use debugPrint.
  /// you can also write log in a file, for example:
  ///```dart
  ///  var file=File("./log.txt");
  ///  var sink=file.openWrite();
  ///  dio.interceptors.add(LogPrintInterceptor(logPrint: sink.writeln));
  ///  ...
  ///  await sink.close();
  ///```
  void Function(Object object) logPrint;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!showLog) return super.onRequest(options, handler);
    _printRequest(options);
    return super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (!showLog) return super.onError(err, handler);
    _printError(err);
    return super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!showLog) return super.onResponse(response, handler);
    _printResponse(response);
    return super.onResponse(response, handler);
  }

  void _printRequest(RequestOptions options) {
    printV('*************** 请求发起 ***************');
    printKV('请求链接', options.uri);

    //单个请求-是否打印-请求参数
    bool singleRequestShowLog = options.extra[singleRequestShowLogKey] ?? true;
    if (request && singleRequestShowLog) {
      printKV('请求方式', options.method);
      if (options.method == "POST") {
        if (options.data is FormData) {
          printV("请求参数:");
          printV(options.data);
        } else {
          printV("请求参数:");
          prettyPrintJson(options.data);
        }
      } else {
        printV("请求参数:");
        prettyPrintJson(options.queryParameters);
      }
    }

    //单个请求-是否打印-请求头部
    bool singleRequestHeaderShowLog =
        options.extra[singleRequestHeaderShowLogKey] ?? true;
    if (requestHeader && singleRequestHeaderShowLog) {
      printV("请求头部:");
      options.headers.forEach((key, v) {
        if (key == "Authorization") {
          printV(key.toString());
          prettyLongString(v.toString());
        } else {
          printKV("$key", "$v");
        }
      });
    }

    //单个请求-是否打印-请求参数
    bool singleRequestBodyShowLog =
        options.extra[singleRequestBodyShowLogKey] ?? true;
    if (requestBody && singleRequestBodyShowLog) {
      printV("请求参数 Body:");
      prettyPrintJson(options.data.toString());
    }
    printV("");
  }

  void _printError(DioError err) {
    //单个请求-是否打印-错误信息
    bool singleErrorShowLog =
        err.requestOptions.extra[singleErrorShowLogKey] ?? true;
    if (error && singleErrorShowLog) {
      printV('*************** 请求出错 ***************:');
      printKV("出错链接", err.requestOptions.uri);
      printKV("出错原因", err);
      if (err.response != null) {
        _printResponse(err.response!);
      }
      printV("");
    }
  }

  void _printResponse(Response response) {
    printV("*************** 请求响应 ***************");
    printKV('响应链接', response.requestOptions.uri);
    //单个请求-是否打印-响应头
    bool singleResponseHeaderShowLog =
        response.requestOptions.extra[singleResponseHeaderShowLogKey] ?? true;
    if (responseHeader && singleResponseHeaderShowLog) {
      printKV('响应状态码', response.statusCode);
      if (response.isRedirect == true) {
        printKV('redirect', response.realUri);
      }
      var headers = response.headers.toString().replaceAll("\n", "\n ");
      printKV('响应头部', headers);
    }

    //单个请求-是否打印-响应头
    bool singleResponseBodyShowLog =
        response.requestOptions.extra[singleResponseBodyShowLogKey] ?? true;
    if (responseBody && singleResponseBodyShowLog) {
      printV("响应内容:");
      prettyPrintJson(response.data);
    }
    printV("");
  }

  void printV(Object value) {
    logPrint('$value');
  }

  void printKV(String key, Object? value) {
    logPrint('$key: $value');
  }

  JsonDecoder decoder = const JsonDecoder();
  JsonEncoder encoder = const JsonEncoder.withIndent('  ');

  /// 打印Json格式化数据
  void prettyPrintJson(dynamic jsonData) {
    try {
      var prettyString = encoder.convert(jsonData);
      prettyString.split('\n').forEach((element) => logPrint(element));
    } on FormatException catch (_) {
      logPrint(json);
    }
  }

  /// 为了便于查看对过长的字符串进行截断显示
  void prettyLongString(String str) {
    if (str.length > 150) {
      logPrint(str.substring(0, 150));
      prettyLongString(str.substring(150, str.length));
    } else {
      logPrint(str);
    }
  }
}
