import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:prezpicks/questions.dart';
import 'main.dart';

class TopicsPage extends StatefulWidget {
  final Locale locale;

  TopicsPage({Key? key, required this.locale}) : super(key: key);

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  final List<String> selectedTopics = [
    'Criminal Justice',
    'Immigration',
    'Carrots',
    'Peaches',
    'Pony',
  ];
  late List<bool> _selectedTopics;
  List<String> selectedTopicNames = [];

  @override
  void initState() {
    super.initState();
    _selectedTopics = List.generate(selectedTopics.length, (_) => false);
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
          title: const Text('Error'),
          content: const Text('Please select at least one topic.'),
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
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          ToggleButtons(
            onPressed: (int index) {
              _updateSelectedTopics(index);
            },
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            selectedBorderColor: Colors.black87,
            selectedColor: Colors.white,
            fillColor: Colors.grey,
            color: Colors.black38,
            isSelected: _selectedTopics,
            children: selectedTopics.map((topic) => Text(topic)).toList(),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_isSelected()) {
                _clearAll();
              } else {
                _selectAll();
              }
            },
            child: Text(_isSelected()
                ? AppLocalizations.of(context)!.clear_all
                : AppLocalizations.of(context)!.select_all),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedTopicNames.isEmpty) {
                _showErrorDialog(context);
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return QuestionsPage(
                      locale: widget.locale,
                      selectedTopics: selectedTopicNames);
                }));
              }
              // Navigate to next page or perform action with selectedTopicNames
            },
            child: Text(AppLocalizations.of(context)!.next),
          ),
        ],
      ),
    );
  }
}
