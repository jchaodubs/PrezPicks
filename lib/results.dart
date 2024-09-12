import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prezpicks/questions.dart';
import 'main.dart';
import 'questions.dart';
import 'package:firebase_database/firebase_database.dart';

class ResultsPage extends StatefulWidget {
  final Locale locale;
  final List<String> selectedTopics;
  final List<bool> opinionOrders;
  final List<int> selections;
  final Map<String, Map<String, dynamic>> opinions;

  ResultsPage(
      {Key? key,
      required this.locale,
      required this.selectedTopics,
      required this.opinionOrders,
      required this.opinions,
      required this.selections})
      : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  @override
  void initState() {
    super.initState();
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

  print('Updated data: trumpData = $trumpData, harrisData = $harrisData');
}
    int tScore = ((trumpTemp / widget.selections.length) * 100).round();
    int hScore = ((harrisTemp / widget.selections.length) * 100).round();

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
    print("buffer");

    Map<dynamic, dynamic> winner = _getResults();
    print(winner['trumpData']);
    print(winner['harrisData']);
    print(winner);

    return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const MyApp();
                }));
              },
              child: const Text("Home"),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: Center(
            child: Padding(
                padding: winner['winner'] == 'Both'
                    ? const EdgeInsets.symmetric(horizontal: 500.0)
                    : const EdgeInsets.symmetric(horizontal: 300.0),
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(winner['winner'] == 'Both'
                        ? 'Kamala Harris'
                        : winner['loser']),
                    Container(
                      height: winner['winner'] == 'Both' ? 500 : 350,
                      width: double.infinity,
                      color: winner['winner'] == 'Both'
                          ? Colors.amber
                          : Colors.blueGrey,
                      child: Column(children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: ClipOval(
                            child: SizedBox(
                              width: 250,
                              height: 250,
                              child: Image.asset(
                                  winner['loser'] == 'Donald Trump'
                                      ? '../assets/images/trumpy.jpg'
                                      : '../assets/images/kamalamamala.jpg',
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: winner['loser'] == 'Donald Trump'
                              ? Text('Fit Percentage: ${winner['trumpScore']}%')
                              : Text(
                                  'Fit Percentage: ${winner['harrisScore']}%'),
                        ),
                        Expanded(
                          child: ListView.builder(
                              itemCount: winner['loser'] == 'Donald Trump'
                                  ? winner['trumpAns'].length
                                  : winner['harrisAns'].length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: winner['loser'] == 'Donald Trump' ? Text('Topic: ${winner['trumpAns'][index]}, data: ${winner['trumpData'][winner['trumpAns'][index]]}') : Text('Topic: ${winner['harrisAns'][index]}, data: ${winner['harrisData'][winner['harrisAns'][index]]}'),
                                );
                              }),
                        )
                      ]),
                    ),
                  ])),
                  SizedBox(width: 5),
                  Expanded(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(winner['winner'] == 'Both'
                        ? 'Donald Trump'
                        : winner['winner']),
                    Container(
                        height: 500,
                        color: Colors.amber,
                        width: double.infinity,
                        child: Column(children: [
                          Align(
                              alignment: Alignment.topCenter,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: Image.asset(
                                      winner['winner'] == 'Kamala Harris'
                                          ? '../assets/images/kamalamamala.jpg'
                                          : '../assets/images/trumpy.jpg',
                                      fit: BoxFit.cover),
                                ),
                              )),
                          Align(
                            alignment: Alignment.center,
                            child: winner['winner'] == 'Kamala Harris'
                                ? Text(
                                    'Fit Percentage: ${winner['harrisScore']}%')
                                : Text(
                                    'Fit Percentage: ${winner['trumpScore']}%'),
                          ),
                          Expanded(
                            child: ListView.builder(
                                itemCount: winner['winner'] == 'Kamala Harris'
                                    ? winner['harrisAns'].length
                                    : winner['trumpAns'].length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: winner['winner'] =='Kamala Harris' ?  Text('Topic: ${winner['harrisAns'][index]}, data: ${winner['harrisData'][winner['harrisAns'][index]]}'): Text('Topic: ${winner['trumpAns'][index]}, data: ${winner['trumpData'][winner['trumpAns'][index]]}'),
                                  );
                                }),
                          )
                        ])),
                  ])),
                  Visibility(
                      visible: winner['winner'] != 'Both',
                      child: Expanded(
                        child: Container(
                          height: 100,
                          color: Colors.transparent,
                          child: Text(''),
                        ),
                      )),
                ]))));
  }
}
