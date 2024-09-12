import 'package:flutter/material.dart';
import 'package:prezpicks/home.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FaqPage extends StatefulWidget {
  final String title;
  final Function(Locale) setLocale;

  const FaqPage({Key? key, required this.title, required this.setLocale})
      : super(key: key);

  @override
  State<FaqPage> createState() => _FaqPage();
}

class _FaqPage extends State<FaqPage> {
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

        //  body: SingleChildScrollView(
        //   padding: EdgeInsets.symmetric(horizontal: 200),
        //     child: Column(
        body: LayoutBuilder(builder: (context, constraints) {
          double horizontalPadding = constraints.maxWidth > 600 ? 200 : 16;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding, vertical: 24),
            child: Column(
              children: <Widget>[
                Text(
                  "Frequently Asked Questions",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                _buildFaqItem(
                  context,
                  "What is PrezPicks?",
                  "Prezpicks is a website meant to help people discover which presidential candidate they align closest with.",
                ),
                _buildFaqItem(
                  context,
                  "How does PrezPicks work?",
                  "Prezpicks retrieves the top 2 presidential candidates opinions on a variety of subject matter. Then opinions you select are added up to see which candidate you align closest with.",
                ),
                _buildFaqItem(
                  context,
                  "How often are candidate stances updated?",
                  "They are updated as often as possible, if you see an outdated stance that hasn't been updated, it's likely that it's still under verification",
                ),
                _buildFaqItem(
                  context,
                  "How are candidate recommendations generated?",
                  "PrezPicks simply adds up the opinions you selected and chooses the candidate you selected most",
                ),
                _buildFaqItem(
                  context,
                  "My candidate match was inaccurate",
                  "If you believe your results were inaccurate, contact me at chaojeffrey831@gmail.com",
                ),
                _buildFaqItem(
                  context,
                  "How can I provide feedback/suggestions",
                  "You can either email me at chaojeffrey831@gmail.com or check out the github repo XXXPUTLINKXXX",
                ),
                _buildFaqItem(
                  context,
                  "Why do you accept donations",
                  "This is due to the service costs of PrezPicks and to keep it updated and running for users. ",
                ),

                // Add more ExpansionTiles here as needed
              ],
            ),
          );
        }));
  }
}

Widget _buildFaqItem(BuildContext context, String question, String answer) {
  return Container(
    decoration: BoxDecoration(
      border: Border.symmetric(
          horizontal: BorderSide(width: 0.5, color: Color(0xFF7A7A7A))),
    ),
    child: ExpansionTile(
      childrenPadding: EdgeInsets.symmetric(horizontal: 0),
      backgroundColor: Color.fromARGB(255, 240, 238, 238),
      iconColor: Color(0xFF7A7A7A),
      tilePadding: EdgeInsets.all(-50),
      collapsedIconColor: Color(0xFF7A7A7A),
      title: Text(
        question,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      children: <Widget>[
        ListTile(
        title: Text(
          answer,
          style: Theme.of(context).textTheme.labelSmall,
        )),
      ],
    ),
  );
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
