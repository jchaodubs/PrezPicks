import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'results.dart';

class QuestionsPage extends StatefulWidget {
  final Locale locale;
  final List<String> selectedTopics;

  QuestionsPage({Key? key, required this.locale, required this.selectedTopics})
      : super(key: key);

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  int selectedIndex = -1;
  Random randomAns = Random();
  //list of indices
  //user selects opinion[0]
  //user mostly selected harris opinions
  //cross reference opinions, and check indices of opinions with selected opinions
  late List<int> selections =
      List<int>.generate(widget.selectedTopics.length, (int index) => -1);
  late List<bool> opinionOrders = List<bool>.generate(
      widget.selectedTopics.length, (int index) => randomAns.nextBool());

  int currIndex = 0;
  bool isLoading = true;
  Map<String, Map<String, dynamic>> opinions = {};
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchOpinions();
  }

  Future<void> _fetchOpinions() async {

    setState(() {
      isLoading = true;
    });
    List<String> topics = widget.selectedTopics;

    String lang = AppLocalizations.of(context)!.lang;
    for (String topic in topics) {
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      final opinion = await ref.child("topics/$lang/$topic").get();
      if (opinion.exists) {
        setState(() {
          opinions[topic] = Map<String, dynamic>.from(opinion.value as Map);
          //print(opinions[topic]); // Since {harris: uhm, harris_s: uh, trump: yessir, trump_s: yes}
        });
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Map<String, String> _getOpinionText() {
    if (currIndex >= widget.selectedTopics.length) {
      return {};
    }
    String currentTopic = widget.selectedTopics[currIndex];
    Map<String, dynamic>? opinionData = opinions[currentTopic];
    if (opinionData == null) {
      return {'404': 'No opinion available for $currentTopic'};
    }

    // Assuming the opinion text is stored in a field called 'text'
    // Adjust this according to your actual data structure

    return {
      'harris': opinionData['harris'] ?? 'No data',
      'trump': opinionData['trump'] ?? 'No data'
    };
  }

  void _showNext() {
    if (currIndex < widget.selectedTopics.length - 1 &&
        selections[currIndex] != -1) {
      setState(() {
        currIndex++;
        selectedIndex = selections[currIndex];
      });
    } else if (selections[currIndex] == -1) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please select one opinion.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else if (currIndex == widget.selectedTopics.length - 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ResultsPage(
            locale: widget.locale,
            selectedTopics: widget.selectedTopics,
            opinionOrders: opinionOrders,
            opinions: opinions,
            selections: selections);
      }));
    }
  }

  void _showPrevious() {
    if (currIndex > 0) {
      setState(() {
        currIndex--;
        selectedIndex = selections[currIndex];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final opinionMap = _getOpinionText();
    print(opinionMap);

    final bool isHarrisFirst = opinionOrders[currIndex];
    final firstOpinionKey = isHarrisFirst ? 'harris' : 'trump';
    final secondOpinionKey = isHarrisFirst ? 'trump' : 'harris';

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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Text('Select the card you most agree with for ${widget.selectedTopics[currIndex]}\n'),),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedIndex == 0 ? Colors.blue : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedIndex = 0;
                          selections[currIndex] = 0;
                        });
                      },
                      child: Text(opinionMap[firstOpinionKey!] ?? 'No data'),
                    ),
                    const SizedBox(width: 16), // Gap between the buttons
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            selectedIndex == 1 ? Colors.blue : Colors.grey,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      onPressed: () {
                        setState(() {
                          selectedIndex = 1;
                          selections[currIndex] = 1;
                        });
                      },
                      child: Text(opinionMap[secondOpinionKey!] ?? 'No data'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: _showPrevious,
                      child: const Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: _showNext,
                      child: (currIndex < widget.selectedTopics.length - 1)
                          ? const Text('Next')
                          : const Text('See Results'),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
