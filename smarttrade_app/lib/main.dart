import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarttrade_app/app/app.dart';
import 'package:smarttrade_app/core/database/app_database.dart';
import 'package:smarttrade_app/core/providers/core_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await AppDatabase.open();

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const SmartTradeApp(),
    ),
  );
}
