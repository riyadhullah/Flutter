import 'package:flutter/material.dart';
import 'package:quizapp/data/questions.dart';
import 'package:quizapp/questions_summary.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key, required this.chosenAnswer});

  final List<String> chosenAnswer;

  List<Map<String, Object>> getSummaryData() {
    final List<Map<String, Object>> summary = [];

    for (var i = 0; i < chosenAnswer.length; i++) {
      summary.add({
        'question_index': i,
        'question': questions[i].text,
        'correct_answer': questions[i].answers[0],
        'user_answer': chosenAnswer[i],
      });
    }
    // print('=== Summary Data ===');
    // for (var data in summary) {
    //   print('Q${data['question_index']}:');
    //   print('  Question      : ${data['question']}');
    //   print('  Correct Answer: ${data['correct_answer']}');
    //   print('  Your Answer   : ${data['user_answer']}');
    // }
    return summary;
  }

  @override
  Widget build(BuildContext context) {
    final summaryData = getSummaryData();
    final numTotalQuestions = questions.length;
    final numCorrectQuestions = summaryData.where((data) {
      final userAnswer = data['user_answer'] as String;
      final correctAnswer = data['correct_answer'] as String;
      return userAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    }).length;

    return SizedBox(
      width: double.infinity,
      child: Container(
        margin: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'you answered $numCorrectQuestions out of $numTotalQuestions questions correctly!',
            ),
            SizedBox(height: 30),
            QuestionsSummary(summaryData: summaryData),
            SizedBox(height: 30),
            TextButton(onPressed: () {

            },
            child: Text('Restart Quiz')),
          ],
        ),
      ),
    );
  }
}
