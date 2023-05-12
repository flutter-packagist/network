## network

## 简介
**基于dio封装多种请求方式**  
**支持 post get put patch delete等请求方式**
**支持前后拦截器**  
**提供json安全解析功能**


## 引入
```
network:
    git:
      url: https://github.com/flutter-packagist/network.git
```

## 初始化
```dart
/// 初始网络请求模块
HttpRequest().init();
```

## 使用
get
```dart
HttpRequest().get("url", params: {}, callBack: (data){});
```

post
```dart
HttpRequest().post("url", params: {}, callBack: (data){});
```


### License
The MIT License (MIT). Please see [License File](LICENSE) for more information.
