import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:quickalert/quickalert.dart';

enum Reaction { happy, sad, neutral, angry, none }






class HomePage extends StatefulWidget {
  final String matricule;

  const HomePage({Key? key, required this.matricule}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}







class _HomePageState extends State<HomePage> {
  Reaction _reaction = Reaction.none;
  bool _reactionView = false;
  TextEditingController _descriptionController = TextEditingController();
  bool _showDescriptionError = false;
  bool _showEmojiError = false;

  // Define the reactions list with emojis
  List<String> emojis = [
    "😄", // Happy emoji
    "😢", // Sad emoji
    "😐", // Neutral emoji
    "😠", // Angry emoji
  ];





  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Container(
          width: 80,
          height: 70,
          child: Image.asset('assets/images/sofrecom.png'),
        ),
        backgroundColor: Color.fromARGB(255, 239, 239, 239),
      ),
      backgroundColor: Color(0xFF234E70),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_reactionView)
              Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  color: Color(0xFFFBF8BE),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: emojis.length,
                  itemBuilder: (BuildContext context, int index) {
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                _reaction = Reaction.values[index];
                                _reactionView = false;
                                _showEmojiError = false;
                              });
                            },
                            icon: Text(
                              emojis[index],
                              style: TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
         
         
         
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _reactionView = !_reactionView;
                  _showEmojiError = false;
                });
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                primary: Color(0xFFFBF8BE),
              ),
              child: _reaction == Reaction.none
                  ? const Text(
                      'React',
                      style: TextStyle(fontSize: 24, color: Color(0xFF234E70)),
                    )
                  : Text(
                      getReactionEmoji(_reaction),
                      style: TextStyle(fontSize: 24),
                    ),
            ),
          
          
          
            SizedBox(height: 16),
            // Description area
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Text(
                    'Description:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFFBF8BE)),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _showDescriptionError ? Colors.red : Colors.grey,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      style: TextStyle(color: Color(0xFFFBF8BE)),
                      decoration: InputDecoration(
                        hintText: 'Enter your description here',
                        hintStyle: TextStyle(color: Color(0xFFFBF8BE)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      ),
                    ),
                  ),
                 
                 
                 
                  ElevatedButton(
                    onPressed: saveReactionDataToDb,
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFFBF8BE),
                    ),
                    child: Text(
                      'Validate',
                      style: TextStyle(color: Color(0xFF234E70)),
                    ),
                  ),
                  if (_showDescriptionError)
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: _showDescriptionError ? 1.0 : 0.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Please enter a description',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                  if (_showEmojiError)
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 200),
                      opacity: _showEmojiError ? 1.0 : 0.0,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Please select a reaction',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 
 
 
 
  String getReactionEmoji(Reaction reaction) {
    switch (reaction) {
      case Reaction.happy:
        return "😄";
      case Reaction.sad:
        return "😢";
      case Reaction.neutral:
        return "😐";
      case Reaction.angry:
        return "😠";
      default:
        return "";
    }
  }

  int getReactionId(Reaction reaction) {
    switch (reaction) {
      case Reaction.happy:
        return 1;
      case Reaction.sad:
        return 2;
      case Reaction.neutral:
        return 3;
      case Reaction.angry:
        return 4;
      default:
        return 0;
    }
  }







  Future<void> saveReactionDataToDb() async {
    setState(() {
      _showDescriptionError = _descriptionController.text.isEmpty;
      _showEmojiError = _reaction == Reaction.none;
    });

    if (!_showDescriptionError && !_showEmojiError) {
      try {
        final matricule = widget.matricule;
        final reactionId = getReactionId(_reaction);
        final description = _descriptionController.text;
        final currentDate = DateTime.now();

        final apiService = ApiService();
        final success = await apiService.saveReactionData(matricule, reactionId, description, currentDate);

        print('Response Status Code: $success'); // Print the success value
        if (success) {
          final responseText = success as String; // Success value should be the response text
          if (responseText.contains('Mood added successfully')) {
            // Show the success alert
            QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              text: 'Form Submitted Successfully!',
              textColor: const Color(0xFF234E70),
              backgroundColor: const Color(0xFFFBF8BE),
            );

            setState(() {
              _reaction = Reaction.none;
              _reactionView = false;
              _descriptionController.clear();
              _showDescriptionError = false;
              _showEmojiError = false;
            });
          } else {
            // Handle other responses or errors
            // ...
          }
        } else {
          print('Failed to save data to the database.');
        }
      } catch (error, stackTrace) {
        print('Error: $error');
        print('Stack Trace: $stackTrace');
      }
    }
  }
}












class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/Humeur_salarie/api';

  Future<bool> saveReactionData(
    String matricule,
    int reactionId,
    String description,
    DateTime date,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addMood'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'matricule': matricule,
          'id_humeur': reactionId,
          'description': description,
          'dateHumeur': date.toIso8601String(),
        }),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}'); // Print the response body

      if (response.statusCode >= 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      } else {
        print('Data save failed. Status Code: ${response.statusCode}');
        print('Response Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during data save: $e');
      return false;
    }
  }

  static fetchUsers() {}
}
