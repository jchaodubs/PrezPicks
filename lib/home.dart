import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prezpicks/topics.dart';
import 'faq.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  final String title;
  final Function(Locale) setLocale;

  const HomePage({Key? key, required this.title, required this.setLocale})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> items = [
    'English',
    'Español',
    '中文',
  ];
  final Map<String, Locale> localeMapping = {
    'English': const Locale('en', 'US'),
    'Español': const Locale('es'),
    '中文': const Locale('zh'),
  };

  String? selectedValue;
  Future<void> _launchBuyMeCoffee() async {
    final Uri url = Uri.parse('https://www.buymeacoffee.com/jchaodubs');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
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
                    TextButton(
                      onPressed: () {
                        
                        Navigator.of(context)
                            .push(_createRoute(widget.title, widget.setLocale));
                        // Navigator.push(context,
                        //     MaterialPageRoute(builder: (context) {
                        //   return const FaqPage();
                        // }));
                      },
                      style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.transparent),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.faq,
                        style: Theme.of(context).textTheme.displaySmall,
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
              constraints: BoxConstraints(),
              child: IntrinsicHeight(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(flex: 2),
                  Text(
                    AppLocalizations.of(context)!.intro,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20), //Find out which pres...
                  DropdownButtonHideUnderline(
                    // Select language
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      hint: Text(
                        'Select Language',
                        style: Theme.of(context).textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      items: items
                          .map((String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item,
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ))
                          .toList(),
                      value: selectedValue,
                      onChanged: (String? value) {
                        setState(() {
                          selectedValue = value;
                        });
                        if (value != null) {
                          widget.setLocale(localeMapping[value]!);
                        }
                      },
                      buttonStyleData: ButtonStyleData(
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(233, 233, 233, 1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.black26,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        height: 40,
                        width: 200,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Color.fromRGBO(233, 233, 233, 1),
                        ),
                      ),
                      menuItemStyleData: const MenuItemStyleData(
                        height: 40,
                        padding: EdgeInsets.only(left: 14, right: 14),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  ElevatedButton(
                    //get started

                    onPressed: () {
                      if (selectedValue != null) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return TopicsPage(
                              title: widget.title,
                              setLocale: widget.setLocale,
                              locale: localeMapping[selectedValue]!);
                        }));
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return TopicsPage(
                              title: widget.title,
                              setLocale: widget.setLocale,
                              locale: localeMapping['English']!);
                        }));
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.get_started,
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

                  SizedBox(height: 150),
                ],
              )),
            ),
          ),
        ),
        bottomNavigationBar: Container(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 190,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _launchBuyMeCoffee(); // Call the method properly
                    },
                    icon: Icon(Icons.cookie_outlined),
                    label: Text(
                      AppLocalizations.of(context)!.buymeacookie,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFFFDD00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      padding: EdgeInsets.all(15),
                    ),
                  ),
                )
              ],
            )));
  }
}

Route _createRoute(String title, Function(Locale) setLocale) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => FaqPage(
      title: title,
      setLocale: setLocale,
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}
