import 'package:dio/dio.dart';
import 'package:example/web/js/js.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide MultipartFile;
import 'package:log_wrapper/log/log.dart';
import 'package:mvc/base/base_controller.dart';
import 'package:network/network.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';

import 'network_model.dart';

class NetworkController extends BaseController<NetworkModel> {
  @override
  NetworkModel model = NetworkModel();

  @override
  void onClose() {
    // 取消当前控制器绑定的网络请求
    CancelTokenPool().cancel(this);
    super.onClose();
  }
}

extension Data on NetworkController {
  String get description => model.description;

  Map<String, Function> get routes {
    return {
      "get请求": get,
      "get请求Option": get2,
      "post请求": post,
      "put请求": put,
      "delete请求": delete,
      "head请求": head,
      "download请求": download,
      "upload请求": pickFile,
    };
  }
}

extension Action on NetworkController {
  Future pickFile() async {
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
    upload(multipartFile);
  }
}

extension Network on NetworkController {
  /// 网络请求未绑定当前控制器，当控制器销毁时，不会自动取消网络请求
  Future get() async {
    await Future.delayed(const Duration(milliseconds: 200), () {});
    await HttpRequest().get(
      'get',
      onSuccess: (data) {
        showToast("请求成功: ${data.toString()}");
      },
      onFailed: (code, DioException? error) {
        logE('code: $code, msg: $error');
      },
    );
  }

  /// 网络请求绑定当前控制器，当控制器销毁时，会自动取消网络请求
  Future get2() async {
    await Future.delayed(const Duration(milliseconds: 200), () {});
    await HttpRequest().get(
      'get',
      options: Options(
        headers: {'token': '123'},
      ),
      onSuccess: (data) {
        showToast("已绑定当前控制器，请求成功: ${data.toString()}");
      },
      onFailed: (code, DioException? error) {
        logE('code: $code, msg: $error');
      },
      bind: this, // 绑定当前控制器
    );
  }

  Future post() async {
    await HttpRequest().post(
      'post',
      onSuccess: (data) {
        showToast("请求成功: ${data.toString()}");
      },
      onFailed: (code, DioException? error) {
        logE('code: $code, msg: $error');
      },
    );
  }

  Future put() async {
    await HttpRequest().put(
      'put',
      onSuccess: (data) {
        showToast("请求成功: ${data.toString()}");
      },
      onFailed: (code, DioException? error) {
        logE('code: $code, msg: $error');
      },
    );
  }

  Future delete() async {
    await HttpRequest().delete(
      'delete',
      onSuccess: (data) {
        showToast("请求成功: ${data.toString()}");
      },
      onFailed: (code, DioException? error) {
        logE('code: $code, msg: $error');
      },
    );
  }

  Future head() async {
    await HttpRequest().head(
      'head',
      onSuccess: (data) {
        showToast("请求成功: ${data.toString()}");
      },
      onFailed: (code, DioException? error) {
        logE('code: $code, msg: $error');
      },
    );
  }

  Future download() async {
    String url =
        'https://cp4.100.com.tw/images/works/202306/09/api_1904411_1686304395_OTYuIIucc2.jpg!8887t1500-v4.jpg';
    if (GetPlatform.isWeb) {
      Js.download(url);
      return;
    }
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
  }

  Future upload(MultipartFile file) async {
    await HttpRequest().post(
      'upload',
      formData: {'file': file},
      onSuccess: (data) {},
      onFailed: (code, msg) {},
      onSendProgress: (count, total) {
        logD('进度：$count / $total');
      },
    );
  }
}
