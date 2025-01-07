import 'package:glados/glados.dart';
import 'package:ranges/ranges.dart';

void main() {
  group('empty', () {
    Glados2(any.int, any.positiveInt).test('positive step', (start, step) {
      final progression = IntProgression(start, start - 1, step);

      expect(progression.isEmpty, true);
      expect(progression.toList(), <int>[]);
      expect(progression.length, 0);
      expect(() => progression.first, throwsA(isA<StateError>()));
      expect(() => progression.last, throwsA(isA<StateError>()));

      expect(progression.contains(start - 1), false);
      expect(progression.contains(start), false);
      expect(progression.contains(start + 1), false);
    });
    Glados2(any.int, any.negativeInt).test('negative step', (start, step) {
      if (step == 0) return; // Glados shouldn't generate 0, but it has a bug.

      final progression = IntProgression(start, start + 1, step);

      expect(progression.isEmpty, true);
      expect(progression.toList(), <int>[]);
      expect(progression.length, 0);
      expect(() => progression.first, throwsA(isA<StateError>()));
      expect(() => progression.last, throwsA(isA<StateError>()));

      expect(progression.contains(start - 1), false);
      expect(progression.contains(start), false);
      expect(progression.contains(start + 1), false);
    });
  });

  Glados2(any.int, any.int).test('one element', (start, step) {
    if (step == 0) return;

    final progression = IntProgression(start, start, step);

    expect(progression.isEmpty, false);
    expect(progression.toList(), [start]);
    expect(progression.length, 1);
    expect(progression.first, start);
    expect(progression.last, start);

    expect(progression.contains(start - step), false);
    expect(progression.contains(start), true);
    expect(progression.contains(start + step), false);
    expect(progression.contains(start + 2 * step), false);
  });
  Glados2(any.int, any.int).test('two elements', (start, step) {
    if (step == 0) return;

    final progression = IntProgression(start, start + step, step);

    expect(progression.isEmpty, false);
    expect(progression.toList(), [start, start + step]);
    expect(progression.length, 2);
    expect(progression.first, start);
    expect(progression.last, start + step);

    expect(progression.contains(start - step), false);
    expect(progression.contains(start), true);
    expect(progression.contains(start + step), true);
    expect(progression.contains(start + 2 * step), false);
  });

  final examples = {
    const IntProgression(0, 0, 1): [0],
    const IntProgression(0, 1, 1): [0, 1],
    const IntProgression(0, 2, 1): [0, 1, 2],
    const IntProgression(0, 3, 1): [0, 1, 2, 3],
    const IntProgression(0, 0, 2): [0],
    const IntProgression(0, 1, 2): [0],
    const IntProgression(0, 2, 2): [0, 2],
    const IntProgression(0, 3, 2): [0, 2],
    const IntProgression(0, 4, 2): [0, 2, 4],
    const IntProgression(0, 0, -1): [0],
    const IntProgression(0, -1, -1): [0, -1],
    const IntProgression(0, -2, -1): [0, -1, -2],
    const IntProgression(0, -3, -1): [0, -1, -2, -3],
    const IntProgression(0, 0, -2): [0],
    const IntProgression(0, -1, -2): [0],
    const IntProgression(0, -2, -2): [0, -2],
    const IntProgression(0, -3, -2): [0, -2],
    const IntProgression(0, -4, -2): [0, -2, -4],
  };
  group('manual examples', () {
    for (final MapEntry(key: progression, value: values) in examples.entries) {
      group(progression.toString(), () {
        test('most functions', () {
          expect(progression.isEmpty, values.isEmpty);
          expect(progression.toList(), values);
          expect(progression.length, values.length);
          if (values.isNotEmpty) {
            expect(progression.first, values.first);
            expect(progression.last, values.last);
          }
        });
        Glados<int>().test('contains(…)', (value) {
          expect(progression.contains(value), values.contains(value));
        });
      });
    }
  });
}
