import 'package:flutter/material.dart';
import 'package:mobileprogramming/models/Question.dart';

class QuestionEditor extends StatelessWidget {
  final Question question;
  final ValueChanged<Question> onChanged;

  const QuestionEditor({
    super.key,
    required this.question,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: (value) => onChanged(question..text = value),
          decoration: InputDecoration(labelText: 'Question'),
        ),
        DropdownButtonFormField<String>(
          value: question.type,
          items: const [
            DropdownMenuItem(value: 'multiple choice', child: Text('Multiple Choice')),
            DropdownMenuItem(value: 'short answer', child: Text('Short Answer')),
          ],
          onChanged: (value) {
            if (value == 'short answer') {
              question.options = [];
              question.correctAnswer = '';
            }
            onChanged(question..type = value!);
          },
          decoration: const InputDecoration(labelText: 'Question Type'),
        ),
        if (question.type == 'multiple choice') ...[
          const Text('Options:'),
          ...question.options!.asMap().entries.map((entry) {
            int optionIndex = entry.key;
            String option = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      question.options![optionIndex] = value;
                      onChanged(question);
                    },
                    decoration: InputDecoration(labelText: 'Option ${optionIndex + 1}'),
                  ),
                ),
                Radio<String>(
                  value: option,
                  groupValue: question.correctAnswer,
                  onChanged: (value) {
                    question.correctAnswer = value!;
                    onChanged(question);
                  },
                ),
              ],
            );
          }),
          ElevatedButton(
            onPressed: () {
              question.options!.add('');
              onChanged(question);
            },
            child: const Text('Add Option'),
          ),
        ],
      ],
    );
  }
}
