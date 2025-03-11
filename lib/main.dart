import 'package:chat_app/data/services/service_locator.dart';
import 'package:flutter/material.dart';

import 'app.dart';

void main() async {
  await setupServiceLocator();

  runApp(const MyApp());
}
