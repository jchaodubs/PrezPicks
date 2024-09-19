import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prezpicks/questions.dart';
import 'main.dart';
import 'package:prezpicks/home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

class TopicsPage extends StatefulWidget {
  final Locale locale;
  final String title;
  final Function(Locale) setLocale;
  TopicsPage(
      {Key? key,
      required this.locale,
      required this.title,
      required this.setLocale})
      : super(key: key);

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<String> selectedTopics = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    ''
  ];
  final List<String> enTopics = [
    'Criminal Justice',
    'Immigration',
    'Abortion',
    'Inflation',
    'Taxes',
    'Energy Production',
    'Foreign Policy',
    'Russia-Ukraine Conflict',
    'Israel-Palestine Conflict',
    'Gun regulation',
    'Healthcare',
    'Transgender Healthcare',
    'Border Security',
    'Opioids',
    'Trade with China'
  ];
  final List<String> esTopics = [
    'Justicia Penal',
    'Inmigración',
    'Aborto provocado',
    'Inflación',
    'Impuestos',
    'Producción de Energía',
    'Política Exterior',
    'Conflicto Rusia-Ucrania',
    'Conflicto Israel-Palestina',
    'Regulación de armas',
    'Atención médica',
    'Atención médica para personas transgénero',
    'Seguridad Fronteriza',
    'Opioides',
    'Comercio con China'
  ];
  final List<String> zhTopics = [
    '刑事司法',
    '移民',
    '堕胎',
    '通货膨胀',
    '税收',
    '能源生产',
    '外交政策',
    '俄罗斯-乌克兰冲突',
    '以色列-巴勒斯坦冲突',
    '枪支管制',
    '医疗保健',
    '跨性别者医疗保健',
    '边境安全',
    '阿片类药物',
    '与中国贸易'
  ];

  late List<bool> _selectedTopics;
  List<String> selectedTopicNames = [];

  @override
  void initState() {
    super.initState();
    _selectedTopics = List.generate(selectedTopics.length, (_) => false);
    if (widget.locale == Locale('en', 'US')) {
      selectedTopics = enTopics;
    } else if (widget.locale == Locale('es')) {
      selectedTopics = esTopics;
    } else {
      selectedTopics = zhTopics;
    }
  }

  void _updateSelectedTopics(int index) {
    setState(() {
      _selectedTopics[index] = !_selectedTopics[index];
      if (_selectedTopics[index]) {
        selectedTopicNames.add(selectedTopics[index]);
      } else {
        selectedTopicNames.remove(selectedTopics[index]);
      }
    });
  }

  void _selectAll() {
    setState(() {
      for (int i = 0; i < selectedTopics.length; i++) {
        if (!_selectedTopics[i]) {
          selectedTopicNames.add(selectedTopics[i]);
          _selectedTopics[i] = true;
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      selectedTopicNames.clear();
      for (int i = 0; i < selectedTopics.length; i++) {
        if (_selectedTopics[i]) {
          _selectedTopics[i] = false;
        }
      }
    });
  }

  bool _isSelected() {
    return _selectedTopics.contains(true);
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: Theme.of(context).textTheme.bodySmall),
          content: Text('Please select at least one topic.',
              style: Theme.of(context).textTheme.bodySmall),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              child: Text('OK', style: Theme.of(context).textTheme.bodySmall),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Expanded(
                child: SizedBox(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/images/prezpicks.svg',
                      semanticsLabel: 'logo', // Replace with your SVG file path
                      height: 24.0,
                      width: 24 // Set the desired height
                      ),
                  Text(
                    "PrezPicks",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        widget.setLocale(Locale('en', 'US'));
                        Navigator.of(context)
                            .push(_createRoute(widget.title, widget.setLocale));
                      },
                      icon: Icon(Icons.home_outlined, color: Colors.black),
                      label: Text(
                        'Home',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        body: Center(
            child: SingleChildScrollView(
                child: ConstrainedBox(
          constraints: BoxConstraints(
              //minHeight: MediaQuery.of(context).size.height,
              //maxHeight: MediaQuery.of(context).size.height
              ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.findOutIssues,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Card(
                  elevation: 0,
                  color: Color(0xFFf8f8f8),
                  child: Container(
                      height: 600,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(12.0),
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240.0,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: selectedTopics.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => _updateSelectedTopics(index),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  _selectedTopics[index]
                                      ? BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        )
                                      : BoxShadow(
                                          color: Colors.transparent,
                                          blurRadius: 0,
                                          spreadRadius: 0,
                                        )
                                ],
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10.0),
                                color: _selectedTopics[index]
                                    ? Color.fromARGB(255, 199, 199, 199)
                                    : Colors.transparent,
                              ),
                              child: Center(
                                child: Text(
                                  selectedTopics[index],
                                  textAlign: TextAlign.center,
                                  style: _selectedTopics[index]
                                      ? Theme.of(context)
                                          .textTheme
                                          .displayMedium
                                      : Theme.of(context)
                                          .textTheme
                                          .displaySmall,
                                ),
                              ),
                            ),
                          );
                        },
                      )),
                ),
              ),
            ],
          ),
        ))),
        bottomNavigationBar: Container(
            height: 100,

            // child: Column(
            //   mainAxisAlignment: MainAxisAlignment.start,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_isSelected()) {
                        _clearAll();
                      } else {
                        _selectAll();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor:
                          _isSelected() ? Colors.black : Colors.white,
                      backgroundColor:
                          _isSelected() ? Color(0xFFD9CFC1) : Color(0xFF7A7A7A),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(
                      _isSelected()
                          ? AppLocalizations.of(context)!.clear_all
                          : AppLocalizations.of(context)!.select_all,
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ),

                  //Padding(padding: EdgeInsets.only(bottom: 10)),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedTopicNames.isEmpty) {
                        _showErrorDialog(context);
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return QuestionsPage(
                              locale: widget.locale,
                              setLocale: widget.setLocale,
                              title: widget.title,
                              selectedTopics: selectedTopicNames);
                        }));
                      }
                      // Navigate to next page or perform action with selectedTopicNames
                    },
                    child: Text(
                      AppLocalizations.of(context)!.next,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFF1C1C1C),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                ])));
  }
}

Route _createRoute(String title, Function(Locale) setLocale) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => HomePage(
      title: title,
      setLocale: setLocale,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, -1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}
