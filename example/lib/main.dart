import 'dart:async';

import 'package:example/network/network_page.dart';
import 'package:flutter/material.dart';
import 'package:log_wrapper/log/log.dart';
import 'package:oktoast/oktoast.dart';

import 'app_service.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await AppService.init();
    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    logStackE("$error", error, stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: const NetworkPage(),
      builder: (context, widget) {
        return OKToast(child: widget!);
      },
    );
  }
}
