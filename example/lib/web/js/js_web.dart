// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js' as js;

class JsInterface {
  /// 在新的标签页打开链接
  static void open(String url) {
    js.context.callMethod('open', [url]);
  }

  /// 下载链接内容
  static void download(String url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = url;
    anchorElement.click();
  }
}
