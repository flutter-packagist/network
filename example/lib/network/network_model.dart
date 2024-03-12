import 'package:mvc/base/base_model.dart';

class NetworkModel extends BaseModel {
  String description = '''
相关说明：
1. restful 风格的请求，支持 get、post、put、delete、patch、head、download、upload 方法；
2. 支持网络日志格式化打印，详见 app_service.dart 文件中网络初始化模块代码；
  ''';
}
