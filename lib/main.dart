import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/home.dart';
import 'store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = Store();
  await store.load();
  runApp(DisziplinatorApp(store: store));
}

class DisziplinatorApp extends StatelessWidget {
  final Store store;
  const DisziplinatorApp({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    return StoreScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => MaterialApp(
          title: 'Disziplinator 3000',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(Brightness.light),
          darkTheme: buildTheme(Brightness.dark),
          themeMode: store.followSystem ? ThemeMode.system : (store.dark ? ThemeMode.dark : ThemeMode.light),
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
