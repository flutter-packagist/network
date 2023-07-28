import 'package:dio/dio.dart';

import 'dio_adapter_stub.dart'
    if (dart.library.io) 'dio_adapter_native.dart'
    if (dart.library.js) 'dio_adapter_web.dart';

/// Dio HttpClient 适配器（应用端和web端实现不同）
HttpClientAdapter getClientAdapter() => getAdapter();
