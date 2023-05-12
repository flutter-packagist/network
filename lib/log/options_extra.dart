const singleRequestShowLogKey = 'singleRequestShowLog';
const singleRequestHeaderShowLogKey = 'singleRequestHeaderShowLog';
const singleRequestBodyShowLogKey = 'singleRequestBodyShowLog';
const singleResponseHeaderShowLogKey = 'singleResponseHeaderShowLog';
const singleResponseBodyShowLogKey = 'singleResponseBodyShowLog';
const singleErrorShowLogKey = 'singleErrorShowLog';
const singleShowErrorToastKey = 'singleShowErrorToast';

///请求扩展
class OptionsExtra {
  /// 单个请求-打印-请求参数
  final bool singleRequestShowLog;

  /// 单个请求-打印-请求头部
  final bool singleRequestHeaderShowLog;

  /// 单个请求-打印-请求body
  final bool singleRequestBodyShowLog;

  /// 单个请求-打印-响应头部
  final bool singleResponseHeaderShowLog;

  /// 单个请求-打印-响应body
  final bool singleResponseBodyShowLog;

  /// 单个请求-打印-错误日志
  final bool singleErrorShowLog;

  /// 单个请求-显示-错误提示
  final bool singleErrorToastKey;

  OptionsExtra({
    this.singleRequestShowLog = true,
    this.singleRequestHeaderShowLog = true,
    this.singleRequestBodyShowLog = true,
    this.singleResponseHeaderShowLog = true,
    this.singleResponseBodyShowLog = true,
    this.singleErrorShowLog = true,
    this.singleErrorToastKey = true,
  });
}
