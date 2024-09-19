import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<Locale> _locale = ValueNotifier(const Locale('en'));

  void setLocale(Locale locale) {
    _locale.value = locale;
  }

//   final List<String> selectedTopics = [
// '刑事司法',
// '移民',
// '堕胎',
// '通货膨胀',
// '税收',
// '大学负担能力',
// '能源生产',
// '外交政策',
// '俄罗斯-乌克兰冲突',
// '以色列-巴勒斯坦冲突',
// '枪支管制',
// '医疗保健',
// '跨性别者医疗保健',
// '边境安全',
// '阿片类药物',
// '与中国贸易'
//   ];

//   Future<void> writeTopicsToDatabase() async {
//     final DatabaseReference databaseRef =
//         FirebaseDatabase.instance.ref('topics/zh');

//     Map<String, Map<String, String>> topicsData = {};

//     // Creating the structure with 'harris' and 'trump' for each topic
//     for (var topic in selectedTopics) {
//       topicsData[topic] = {
//         'harris': '',
//         'trump': '',
//       };
//     }

//     try {
//       // Writing to the database
//       await databaseRef.set(topicsData);
//       print('Data written successfully!');
//     } catch (error) {
//       print('Failed to write data: $error');
//     }
//   }

  @override
  Widget build(BuildContext context) {
    //writeTopicsToDatabase();
    return ValueListenableBuilder<Locale>(
      valueListenable: _locale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Prezpicks',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('es'), // Spanish
            Locale('zh'),
          ],
          locale: locale,
          theme: ThemeData(
            scaffoldBackgroundColor: Color(0xFFf8f8f8),
            appBarTheme: AppBarTheme(color: Color(0xFFf8f8f8)),
            textTheme: const TextTheme(
              headlineLarge: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w200,
                  color: Color(0xFF1C1C1C),
                  fontFamily: 'Instrument'),
              headlineMedium: TextStyle(
                  fontSize: 58,
                  fontWeight: FontWeight.w200,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'Instrument'),
              bodyLarge: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                  color: Color(0xFF1C1C1C),
                  fontFamily: 'Instrument'),
              bodyMedium: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w200,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'Instrument'),
              displayLarge: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1C),
                  fontFamily: 'Instrument'),
              labelLarge: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1C),
                  fontFamily: 'Instrument'),
              bodySmall: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w200,
                  color: Color(0xFF1C1C1C),
                  fontFamily: 'Instrument'),
              displaySmall: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7A7A7A),
                  fontFamily: 'Instrument'),
              displayMedium: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1C),
                  fontFamily: 'Instrument'),
              labelSmall: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1C1C1C),
                  fontFamily: 'Instrument'),
              labelMedium: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontFamily: 'Instrument'),
            ),
          ),
          home: HomePage(title: 'PrezPicks', setLocale: setLocale),
        );
      },
    );
  }
}
/*
write/update:
DatabaseReference ref = FirebaseDatabase.instance.ref("topics/criminal_justice");
await ref.set({
  "kamala": "test",
});


read:
DatabaseReference ref = FirebaseDatabase.instance.ref();
final opinion = await ref.child("topics/criminal_justice/harris").get();
    if(opinion.exists){
      print(opinion.value);
      }
*/