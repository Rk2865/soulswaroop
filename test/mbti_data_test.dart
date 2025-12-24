import 'package:flutter_test/flutter_test.dart';
import 'package:soulswaroop/data/mbti_questions.dart';

void main() {
  group('MBTI Data Tests', () {
    test('Question class should be instantiated correctly', () {
      const q = Question(q: 'Test?', A: 'Option A', B: 'Option B', type: 'EI');
      expect(q.q, 'Test?');
      expect(q.A, 'Option A');
      expect(q.B, 'Option B');
      expect(q.type, 'EI');
    });

    test('All 16 MBTI types should have descriptions', () {
      final types = [
        'ISTJ', 'ISFJ', 'INFJ', 'INTJ',
        'ISTP', 'ISFP', 'INFP', 'INTP',
        'ESTP', 'ESFP', 'ENFP', 'ENTP',
        'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ'
      ];

      for (var type in types) {
        expect(typeDescriptions.containsKey(type), true, reason: 'Missing description for $type');
        expect(typeDescriptions[type]!['title'], isNotNull);
        expect(typeDescriptions[type]!['desc'], isNotNull);
      }
    });

    test('Type descriptions should be non-empty', () {
      typeDescriptions.forEach((key, value) {
        expect(value['title']!.isNotEmpty, true);
        expect(value['desc']!.isNotEmpty, true);
      });
    });
  });
}
