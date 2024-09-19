import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';
import 'results.dart';
import 'package:prezpicks/home.dart';
import 'package:flutter_svg/flutter_svg.dart';

class QuestionsPage extends StatefulWidget {
  final Locale locale;
  final List<String> selectedTopics;
  final String title;
  final Function(Locale) setLocale;
  QuestionsPage(
      {Key? key,
      required this.locale,
      required this.selectedTopics,
      required this.title,
      required this.setLocale})
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
        
          title:  Text('Error',style: Theme.of(context).textTheme.bodySmall),
          content:  Text('Please select at least one card.',style: Theme.of(context).textTheme.bodySmall),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              child:  Text('OK' ,style: Theme.of(context).textTheme.bodySmall),
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
          setLocale: widget.setLocale,
          title: widget.title,
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
    //print(opinionMap);

    final bool isHarrisFirst = opinionOrders[currIndex];
    final firstOpinionKey = isHarrisFirst ? 'harris' : 'trump';
    final secondOpinionKey = isHarrisFirst ? 'trump' : 'harris';

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
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : LayoutBuilder(builder:
                (BuildContext context, BoxConstraints viewportConstraints) {
                return Center(
                    child: SingleChildScrollView(
                        child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: viewportConstraints.maxHeight,
                              //minHeight: MediaQuery.of(context).size.height-100,
                              //maxHeight: 1000
                            ),
                            child: IntrinsicHeight(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                  Text(
                                      AppLocalizations.of(context)!.selectCardYouAgreeWith+' ${widget.selectedTopics[currIndex]}\n',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall),
                                  Expanded(
                                    child: Padding(
                                        padding: EdgeInsets.all(0),
                                        child: Card(
                                            elevation: 0,
                                            color: Color(0xFFf8f8f8),
                                            child: Container(
                                              height: 800,
                                              width: 600,
                                              child: GridView.builder(
                                                  shrinkWrap: true,
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 3 / 2,
                                                    crossAxisSpacing: 20,
                                                    crossAxisCount:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                800
                                                            ? 2
                                                            : 1,
                                                    mainAxisSpacing: 20,
                                                  ),
                                                  itemCount: 2,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return ElevatedButton(
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          elevation:
                                                              selectedIndex ==
                                                                      index
                                                                  ? 12
                                                                  : 0,
                                                          backgroundColor:
                                                              selectedIndex ==
                                                                      index
                                                                  ? Color(
                                                                      0xFF7A1CAC)
                                                                  : const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      196,
                                                                      196,
                                                                      196),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      16.0,
                                                                  vertical:
                                                                      16.0),
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            selectedIndex =
                                                                index;
                                                            selections[
                                                                    currIndex] =
                                                                index;
                                                          });
                                                        },
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Text(
                                                            index == 0
                                                                ? AppLocalizations.of(context)!.candidateA+' ${opinionMap[firstOpinionKey!]}' ??
                                                                    'No data'
                                                                : (AppLocalizations.of(context)!.candidateB+' ${opinionMap[secondOpinionKey!]}' ??
                                                                    'No data'),
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: selectedIndex ==
                                                                    index
                                                                ? Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelMedium
                                                                    ?.copyWith(
                                                                        color: Colors
                                                                            .white)
                                                                : Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .labelSmall,
                                                          ),
                                                        ));
                                                  }),
                                            ))),
                                  )
                                ])))));
              }),
        bottomNavigationBar: Container(
            height: 100,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showPrevious;
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                      backgroundColor: Color(0xFF7A7A7A),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: Text(AppLocalizations.of(context)!.back),
                  ),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 15)),
                  ElevatedButton(
                         onPressed: _showNext,
                      child: (currIndex < widget.selectedTopics.length - 1)
                          ?  Text(AppLocalizations.of(context)!.next, style: Theme.of(context).textTheme.labelMedium,)
                          :  Text(AppLocalizations.of(context)!.seeResults, style: Theme.of(context).textTheme.labelMedium,),

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

//   child: Text('Select the card you most agree with for ${widget.selectedTopics[currIndex]}\n'),),
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             selectedIndex == 0 ? Colors.blue : Colors.grey,
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           selectedIndex = 0;
//                           selections[currIndex] = 0;
//                         });
//                       },
//                       child: Text(opinionMap[firstOpinionKey!] ?? 'No data'),
//                     ),
//                     const SizedBox(width: 16), // Gap between the buttons
//                     ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             selectedIndex == 1 ? Colors.blue : Colors.grey,
//                         padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           selectedIndex = 1;
//                           selections[currIndex] = 1;
//                         });
//                       },
//                       child: Text(opinionMap[secondOpinionKey!] ?? 'No data'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     ElevatedButton(
//                       onPressed: _showPrevious,
//                       child: const Text('Back'),
//                     ),
//                     ElevatedButton(
//                       onPressed: _showNext,
//                       child: (currIndex < widget.selectedTopics.length - 1)
//                           ? const Text('Next')
//                           : const Text('See Results'),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//     );
//   }
// }
//                             Padding(
//                               padding: const EdgeInsets.all(15.0),
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//   mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [ ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         minimumSize: Size(10.0,10.0),
//                                         backgroundColor: selectedIndex == 0
//                                             ? Colors.blue
//                                             : Colors.grey,
//                                         padding:  EdgeInsets.symmetric(
//                                             horizontal: 140.0,vertical: 80),
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           selectedIndex = 0;
//                                           selections[currIndex] = 0;
//                                         });
//                                       },
//                                       child: Text(
//                                           opinionMap[firstOpinionKey!] ??
//                                               'No data'),
//                                     ),

//                                     ElevatedButton(
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: selectedIndex == 1
//                                             ? Colors.blue
//                                             : Colors.grey,
//                                         padding:  EdgeInsets.symmetric(
//                                             horizontal: 140.0,vertical: 80),
//                                       ),
//                                       onPressed: () {
//                                         setState(() {
//                                           selectedIndex = 1;
//                                           selections[currIndex] = 1;
//                                         });
//                                       },
//                                       child: Text(
//                                           opinionMap[secondOpinionKey!] ??
//                                               'No data'),
//                                     ),
//                                   ],
//                                   ),
//                                   Row(
// crossAxisAlignment: CrossAxisAlignment.center,
//   mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                                           ElevatedButton(
//                        style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor:  Color(0xFF7A7A7A),
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),),
//                       onPressed: _showPrevious,
//                       child: const Text('Back'),
//                     ),
//                     ElevatedButton(

//                                                                            style: ElevatedButton.styleFrom(
//               foregroundColor: Colors.white,
//               backgroundColor: Color(0xFF1C1C1C),
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//             ),
//                       onPressed: _showNext,
//                       child: (currIndex < widget.selectedTopics.length - 1)
//                           ? const Text('Next')
//                           : const Text('See Results'),
//                     ),
//                                   ],)
//                                 ],
//                               ),
//                             )