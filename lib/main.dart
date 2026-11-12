import 'package:material_ui/material_ui.dart';
import 'package:path_provider/path_provider.dart';
import 'data/store.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = LearningStore(await getApplicationSupportDirectory());
  await store.load();
  runApp(MathApp(store: store));
}

class MathApp extends StatelessWidget {
  final LearningStore store;
  const MathApp({super.key, required this.store});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mathe mit Katzen',
      locale: Locale(store.language),
      supportedLocales: const [Locale('de'), Locale('en')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff26786f)),
        scaffoldBackgroundColor: const Color(0xfffffaf0),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xffd8e5df)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(48, 50)),
        ),
      ),
      home: Home(store: store),
    ),
  );
}
