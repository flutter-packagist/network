# Network

- [Example](https://github.com/flutter-packagist/example/)

## Usage

To use this plugin, add `network` as a [dependency in your pubspec.yaml file]().

``` yaml
dependencies:
  network: 
    git:
      url: https://github.com/flutter-packagist/network.git
```

## Supported methods

- [x] GET
- [x] POST
- [x] PUT
- [x] DELETE
- [x] PATCH
- [x] HEAD
- [x] DOWNLOAD

## Example

### Initialization

``` dart
HttpRequest().init(HttpRequestSetting(
  baseUrl: EnvConfig.host,
  interceptors: [
    RetryOnConnectionChangeInterceptor(),
    DioLogInterceptor(),
    CancelTokenInterceptor(),
  ],
));
```

### GET

``` dart
await HttpRequest().get(
  'get',
  onSuccess: (data) {
    showToast("请求成功: ${data.toString()}");
  },
  onFailed: (code, DioException? error) {
    logE('code: $code, msg: $error');
  },
);
```

### POST

``` dart
await HttpRequest().post(
  'post',
  onSuccess: (data) {
    showToast("请求成功: ${data.toString()}");
  },
  onFailed: (code, DioException? error) {
    logE('code: $code, msg: $error');
  },
);
```

### PUT

``` dart
await HttpRequest().put(
  'put',
  onSuccess: (data) {
    showToast("请求成功: ${data.toString()}");
  },
  onFailed: (code, DioException? error) {
    logE('code: $code, msg: $error');
  },
);
```

### DELETE

``` dart
await HttpRequest().delete(
  'delete',
  onSuccess: (data) {
    showToast("请求成功: ${data.toString()}");
  },
  onFailed: (code, DioException? error) {
    logE('code: $code, msg: $error');
  },
);
```

### PATCH

``` dart
await HttpRequest().patch(
  'patch',
  onSuccess: (data) {
    showToast("请求成功: ${data.toString()}");
  },
  onFailed: (code, DioException? error) {
    logE('code: $code, msg: $error');
  },
);
```

### HEAD

``` dart
await HttpRequest().head(
  'head',
  onSuccess: (data) {
    showToast("请求成功: ${data.toString()}");
  },
  onFailed: (code, DioException? error) {
    logE('code: $code, msg: $error');
  },
);
```

### DOWNLOAD

``` dart
await HttpRequest().download(
  url,
  '${(await getTemporaryDirectory()).path}/test.jpg',
  onReceiveProgress: (count, total) {
    logD('进度：$count / $total');
  },
  onSuccess: (data) {
    showToast("下载完成");
  },
  onFailed: (code, error) {
    logE('code: $code, msg: $error');
  },
);
```

on Web, you can use `download(url)` to download file. Such as:

``` dart
/// 下载链接内容
static void download(String url) {
  html.AnchorElement anchorElement = html.AnchorElement(href: url);
  anchorElement.download = url;
  anchorElement.click();
}
```

## UPLOAD

### Picker File

``` dart
MultipartFile? multipartFile;
if (GetPlatform.isWeb) {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  Uint8List? fileBytes = result!.files.first.bytes;
  String fileName = result.files.first.name;
  if (fileBytes == null) {
    showToast("文件为空");
    return;
  }
  multipartFile = MultipartFile.fromBytes(
    fileBytes,
    filename: fileName,
  );
} else {
  FilePickerResult? result = await FilePicker.platform.pickFiles();
  if (result?.files.single.path == null) {
    showToast("文件为空");
    return;
  }
  showToast("文件路径: ${result!.files.single.path}");
  multipartFile = await MultipartFile.fromFile(result.files.single.path!);
}
```

### Upload File

``` dart
await HttpRequest().post(
  'upload',
  formData: {'file': multipartFile},
  onSuccess: (data) {},
  onFailed: (code, msg) {},
  onSendProgress: (count, total) {
    logD('进度：$count / $total');
  },
);
```

## Interceptor

+ `RetryOnConnectionChangeInterceptor`: Retry when network connection change
+ `DioLogInterceptor`: Log interceptor
+ `CancelTokenInterceptor`: when sending a request, it will auto create a cancelToken then add it to
  CancelTokenPool. And remove cancelToken from CancelTokenPool, after request was finished or
  canceled.

### Custom Interceptor

``` dart
class CustomInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    super.onRequest(options, handler);
    
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
    
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    super.onError(err, handler);
    
  }
}
```

### Add Interceptor

``` dart
HttpRequest().init(HttpRequestSetting(
  baseUrl: EnvConfig.host,
  interceptors: [
    ...
    CustomInterceptor(),
  ],
));
```

## Cancel Request

### Cancel Token

``` dart
final cancelToken = CancelToken();
await HttpRequest().get(
  'get',
  cancelToken: cancelToken,
);

cancelToken.cancel();
```

### Binding Controller

If you want to cancel network request when the controller was disposed, you can
use `CancelTokenPool().cancel(this)` to cancel it. And bind the request to the controller.

``` dart
class NetworkController extends BaseController<NetworkModel> {
  @override
  NetworkModel model = NetworkModel();
  
  @override
  onReady() {
    super.onReady();
    get();
  }

  @override
  void onClose() {
    // 取消当前控制器绑定的网络请求
    CancelTokenPool().cancel(this);
    super.onClose();
  }
  
  void get() {
    HttpRequest().get(
      'get',
      bind: this,
    );
  }
}
```

Remember to add `CancelTokenInterceptor()` to interceptors when you init `HttpRequest`.

``` dart
HttpRequest().init(HttpRequestSetting(
  baseUrl: EnvConfig.host,
  interceptors: [
    ...
    CancelTokenInterceptor(),
  ],
));
```

## Safe Convert

+ `toInt(value, {int defaultValue = 0})`
+ `toDouble(value, {double defaultValue = 0.0})`
+ `toBool(value, {bool defaultValue = false})`
+ `toString(value, {String defaultValue = ""})`
+ `toMap(value, {Map<String, dynamic>? defaultValue})`
+ `toList(value, {List? defaultValue})`
+ `asInt(Map<String, dynamic>? json, String key, {int defaultValue = 0})`
+ `asDouble(Map<String, dynamic>? json, String key, {double defaultValue = 0.0})`
+ `asBool(Map<String, dynamic>? json, String key, {bool defaultValue = false})`
+ `asString(Map<String, dynamic>? json, String key, {String defaultValue = ""})`
+ `asMap(Map<String, dynamic>? json, String key, {Map<String, dynamic>? defaultValue})`
+ `asList(Map<String, dynamic>? json, String key, {List? defaultValue})`

### Example

``` dart
test("convert dynamic to safe type", () {
  Object? a;
  print(a.runtimeType); // print: Null
  print(toInt(a).runtimeType); // print: int
  print(toInt(a)); // print: 0
});

test("convert from json key to safe type", () {
  final json = {
    'int': 1,
    'double': 1.0,
    'bool': true,
    'string': 'string',
    'map': {'key': 'value'},
    'list': ["1", "2", "3"],
  };

  print(asInt(json, 'int')); // print: 1
  print(asDouble(json, 'double')); // print: 1.0
  print(asBool(json, 'bool')); // print: true
  print(asString(json, 'string')); // print: string
  print(asMap(json, 'map')); // print: {key: value}
  print(asList(json, 'list').map((e) => toString(e)).toList()); // print [1, 2, 3]

  print("\n");
  print(asMap(json, 'int')); // print: {}
  print(asMap(json, 'double')); // print: {}
  print(asMap(json, 'bool')); // print: {}
  print(asMap(json, 'string')); // print: {}
  print(asMap(json, 'map')); // print: {}
  print(asMap(json, 'list')); // print: {}

  print("\n");
  print(asList(json, 'map').map((e) => toString(e)).toList()); // print []
});
```