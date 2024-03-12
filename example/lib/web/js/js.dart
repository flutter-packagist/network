import 'js_stub.dart'
    if (dart.library.io) 'js_native.dart'
    if (dart.library.js) 'js_web.dart';

class Js {
  static void open(String url) => JsInterface.open(url);

  static void download(String url) => JsInterface.download(url);
}
