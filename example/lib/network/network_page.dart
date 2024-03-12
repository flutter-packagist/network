import 'package:flutter/material.dart';
import 'package:mvc/base/base_page.dart';

import 'network_controller.dart';
import 'network_model.dart';

class NetworkPage extends BasePage<NetworkController, NetworkModel> {
  const NetworkPage({super.key});

  @override
  NetworkController get binding => NetworkController();

  @override
  Widget? get appBar => AppBar(
        title: const Text('网络请求'),
      );

  @override
  Widget get body {
    return ListView.builder(
      itemCount: controller.routes.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            tileColor: Colors.blue.shade300,
            title: Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                controller.description,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }
        return ListTile(
          tileColor: index % 2 == 0 ? Colors.white : Colors.grey[200],
          title: Text(controller.routes.keys.elementAt(index - 1)),
          onTap: () => controller.routes.values.elementAt(index - 1)(),
        );
      },
    );
  }
}
