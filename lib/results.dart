import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prezpicks/questions.dart';
import 'main.dart';
import 'dart:math';
import 'questions.dart';
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:prezpicks/home.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:confetti/confetti.dart';

class ResultsPage extends StatefulWidget {
  final Locale locale;
  final List<String> selectedTopics;
  final List<bool> opinionOrders;
  final List<int> selections;
  final Map<String, Map<String, dynamic>> opinions;
  final String title;
  final Function(Locale) setLocale;

  ResultsPage(
      {Key? key,
      required this.locale,
      required this.setLocale,
      required this.title,
      required this.selectedTopics,
      required this.opinionOrders,
      required this.opinions,
      required this.selections})
      : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool isPlayingConfetti = false;
  final controller = ConfettiController();
  @override
  void initState() {
    super.initState();
    controller.play();
    Timer(Duration(seconds: 8), () {
      controller.stop();
    });
  }

  Map<String, dynamic> _getResults() {
    int trumpTemp = 0;
    int harrisTemp = 0;
    //selections = [0,1]
    //opinionOrders=[true/false,true/false]
    //0 = harris, trump = 1
    List<String> trumpTopics = [];
    List<String> harrisTopics = [];
    Map<String, String> trumpData = {};
    Map<String, String> harrisData = {};
    for (int i = 0; i < widget.selections.length; i++) {
      if (widget.opinionOrders[i]) {
        // Harris is first
        if (widget.selections[i] == 0) {
          harrisTemp++;
          harrisTopics.add(widget.selectedTopics[i]);
          harrisData[widget.selectedTopics[i]] =
              widget.opinions[widget.selectedTopics[i]]?['harris'];
        } else {
          trumpTemp++;
          trumpTopics.add(widget.selectedTopics[i]);
          trumpData[widget.selectedTopics[i]] =
              widget.opinions[widget.selectedTopics[i]]?['trump'];
        }
      } else {
        // Trump is first
        if (widget.selections[i] == 0) {
          trumpTemp++;
          trumpTopics.add(widget.selectedTopics[i]);
          trumpData[widget.selectedTopics[i]] =
              widget.opinions[widget.selectedTopics[i]]?['trump'];
        } else {
          harrisTemp++;
          harrisTopics.add(widget.selectedTopics[i]);
          harrisData[widget.selectedTopics[i]] =
              widget.opinions[widget.selectedTopics[i]]?['harris'];
        }
      }

      //print('Updated data: trumpData = $trumpData, harrisData = $harrisData');
    }
    // int tScore = ((trumpTemp / widget.selections.length) * 100).round();
    // int hScore = ((harrisTemp / widget.selections.length) * 100).round();
    int tScore = trumpTemp;
    int hScore = harrisTemp;

    String winner;
    String loser;
    if (trumpTemp > harrisTemp) {
      winner = 'Donald Trump';
      loser = 'Kamala Harris';
    } else if (harrisTemp > trumpTemp) {
      winner = 'Kamala Harris';
      loser = 'Donald Trump';
    } else {
      winner = 'Both';
      loser = "";
    }

    return {
      'winner': winner,
      'loser': loser,
      'trumpAns': trumpTopics,
      'harrisAns': harrisTopics,
      'trumpData': trumpData,
      'harrisData': harrisData,
      'trumpScore': tScore,
      'harrisScore': hScore
    };
  }

  @override
  Widget build(BuildContext context) {
    //print("buffer");

    Map<String, dynamic> winner = _getResults();
    //print(winner['trumpData']);
    //print(winner['harrisData']);
    //print(winner);

    return Stack(alignment: Alignment.topCenter, children: [
      Scaffold(
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
                        semanticsLabel:
                            'logo', // Replace with your SVG file path
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
                          Navigator.of(context).push(
                              _createRoute(widget.title, widget.setLocale));
                        },
                        icon: Icon(Icons.home_outlined, color: Colors.black),
                        label: Text(
                          AppLocalizations.of(context)!.home,
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = MediaQuery.of(context).size.width > 600;
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? 20.0 : 10.0,
                    vertical: 20.0,
                  ),
                  child: isLargeScreen
                      ? _buildPodiumLayout(context, constraints, winner)
                      : _buildMobileLayout(context, constraints, winner),
                ),
              );
            },
          ),
          bottomNavigationBar: Container(
              height: 100,
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final String text = winner['winner'] == 'Both'
                            ? 'Check out https://prezpicks.web.app/ Turns out I fucking love Trump and Harris!!!'
                            : 'Check out https://prezpicks.web.app/ Turns out I fucking love ${winner['winner']}!!!';
                        await Share.share(text);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                        backgroundColor: Color(0xFF7A7A7A),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      child: Text(AppLocalizations.of(context)!.share),
                    ),
                    Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                    ElevatedButton(
                      onPressed: () {
                        widget.setLocale(Locale('en', 'US'));
                        Navigator.of(context)
                            .push(_createRoute(widget.title, widget.setLocale));
                      },
                      child: Text(
                        AppLocalizations.of(context)!.goBackHome,
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
                  ]))),
      ConfettiWidget(
        confettiController: controller,
        shouldLoop: false,
        //emissionFrequency: .80,

        blastDirectionality: BlastDirectionality.explosive,
      )
    ]);
  }

  Widget _buildPodiumLayout(BuildContext context, BoxConstraints constraints,
      Map<String, dynamic> winner) {
    return Column(children: [
      winner['winner'] == 'Both'
          ? Text(AppLocalizations.of(context)!.resultsTied,
              style: Theme.of(context).textTheme.bodyLarge)
          : winner['winner'] == 'Donald Trump'
              ? Text(AppLocalizations.of(context)!.yourWinnerIs+' Donald Trump!!!',
                  style: Theme.of(context).textTheme.bodyLarge)
              : Text(AppLocalizations.of(context)!.yourWinnerIs+' Kamala Harris!!!',
                  style: Theme.of(context).textTheme.bodyLarge),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(width: 80),
          Expanded(
            child: ComparisonCard(
              name: winner['winner'] == 'Both'
                  ? 'Kamala Harris'
                  : winner['loser'],
              score: winner['loser'] == 'Donald Trump'
                  ? winner['trumpScore']
                  : winner['harrisScore'],
              imagePath: winner['loser'] == 'Donald Trump'
                  ? 'assets/images/trumpy.jpg'
                  : 'assets/images/kamalamamala.jpg',
              answers: winner['loser'] == 'Donald Trump'
                  ? winner['trumpAns']
                  : winner['harrisAns'],
              data: winner['loser'] == 'Donald Trump'
                  ? winner['trumpData']
                  : winner['harrisData'],
              isWinner: winner['winner'] == 'Both',
              constraints: constraints,
              total: widget.selectedTopics.length,
              height: winner['winner'] == 'Both' ? 600 : 500,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: ComparisonCard(
              name: winner['winner'] == 'Both'
                  ? 'Donald Trump'
                  : winner['winner'],
              score: winner['winner'] == 'Kamala Harris'
                  ? winner['harrisScore']
                  : winner['trumpScore'],
              imagePath: winner['winner'] == 'Kamala Harris'
                  ? 'assets/images/kamalamamala.jpg'
                  : 'assets/images/trumpy.jpg',
              answers: winner['winner'] == 'Kamala Harris'
                  ? winner['harrisAns']
                  : winner['trumpAns'],
              data: winner['winner'] == 'Kamala Harris'
                  ? winner['harrisData']
                  : winner['trumpData'],
              isWinner: true,
              constraints: constraints,
              total: widget.selectedTopics.length,
              height: 600,
            ),
          ),
          SizedBox(width: 80),
        ],
      )
    ]);
  }

  Widget _buildMobileLayout(BuildContext context, BoxConstraints constraints,
      Map<String, dynamic> winner) {
    return Column(
      children: [
        winner['winner'] == 'Both'
            ? Text('The results are tied!!!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge)
            : winner['winner'] == 'Donald Trump'
                ? Text(
                    'Your winner is Donald Trump!!!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  )
                : Text(
                    'Your winner is Kamala Harris!!!',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
        ComparisonCard(
          name: winner['winner'] == 'Both' ? 'Donald Trump' : null,
          score: winner['winner'] == 'Kamala Harris'
              ? winner['harrisScore']
              : winner['trumpScore'],
          imagePath: winner['winner'] == 'Kamala Harris'
              ? 'assets/images/kamalamamala.jpg'
              : 'assets/images/trumpy.jpg',
          answers: winner['winner'] == 'Kamala Harris'
              ? winner['harrisAns']
              : winner['trumpAns'],
          data: winner['winner'] == 'Kamala Harris'
              ? winner['harrisData']
              : winner['trumpData'],
          isWinner: true,
          constraints: constraints,
          total: widget.selectedTopics.length,
          height: 500,
        ),
        SizedBox(height: 20),
        ComparisonCard(
          name: winner['winner'] == 'Both' ? 'Kamala Harris' : winner['loser'],
          score: winner['loser'] == 'Donald Trump'
              ? winner['trumpScore']
              : winner['harrisScore'],
          imagePath: winner['loser'] == 'Donald Trump'
              ? 'assets/images/trumpy.jpg'
              : 'assets/images/kamalamamala.jpg',
          answers: winner['loser'] == 'Donald Trump'
              ? winner['trumpAns']
              : winner['harrisAns'],
          data: winner['loser'] == 'Donald Trump'
              ? winner['trumpData']
              : winner['harrisData'],
          isWinner: winner['winner'] == 'Both',
          constraints: constraints,
          total: widget.selectedTopics.length,
          height: 500,
        ),
      ],
    );
  }
}

class ComparisonCard extends StatelessWidget {
  final String? name;
  final int score;
  final String imagePath;
  final List<String> answers;
  final Map<String, dynamic> data;
  final bool isWinner;
  final int total;
  final BoxConstraints constraints;
  final double height;

  const ComparisonCard({
    Key? key,
    this.name,
    required this.total,
    required this.score,
    required this.imagePath,
    required this.answers,
    required this.data,
    required this.isWinner,
    required this.constraints,
    required this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (name != null)
          Text(name!, style: Theme.of(context).textTheme.bodyMedium),
        Material(
          elevation: 8,
          child: Container(
            height: height,
            width: double.infinity,
            color: isWinner
                ? Color.fromARGB(255, 255, 211, 77)
                : Color.fromARGB(255, 119, 143, 155),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ClipOval(
                    child: Image.asset(
                      imagePath,
                      width: constraints.maxWidth > 600 ? 200 : 150,
                      height: constraints.maxWidth > 600 ? 200 : 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text('${score * 23} points',
                    style: Theme.of(context).textTheme.displayLarge),
                Text('$score out of $total',
                    style: Theme.of(context).textTheme.displayLarge),
                Expanded(
                  child: ListView.builder(
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title:
                            //     Text(
                            //         'Topic: ${answers[index]}\n Stance: ${data[answers[index]]}',
                            // style: constraints.maxWidth > 600 ? Theme.of(context).textTheme. labelLarge :Theme.of(context).textTheme.displayMedium ),
                            Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${answers[index]}\n',
                                style: constraints.maxWidth > 600
                                    ? Theme.of(context).textTheme.labelLarge
                                    : Theme.of(context).textTheme.labelLarge,
                              ),
                              TextSpan(
                                text: 'Stance: ${data[answers[index]]}',
                                style: constraints.maxWidth > 600
                                    ? Theme.of(context)
                                        .textTheme
                                        .bodySmall // Different style
                                    : Theme.of(context)
                                        .textTheme
                                        .bodySmall, // Different style
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Text('Sources: BallotPedia',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ),
      ],
    );
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
