import 'package:glados/glados.dart';
import 'package:ranges/ranges.dart';

void main() {
  group('IntRange', () {
    Glados<int>().test('empty', (start) {
      final range = IntRange(start, start - 1);

      expect(range.isEmpty, true);
      expect(range.endInclusive, start - 1);
      expect(range.endExclusive, start);
      expect(range.toList(), <int>[]);
      expect(range.length, 0);
      expect(() => range.first, throwsA(isA<StateError>()));
      expect(() => range.last, throwsA(isA<StateError>()));

      expect(range.contains(start - 1), false);
      expect(range.contains(start), false);
      expect(range.contains(start + 1), false);
    });

    Glados<int>().test('one element', (start) {
      final range = IntRange(start, start);

      expect(range.isEmpty, false);
      expect(range.endInclusive, start);
      expect(range.endExclusive, start + 1);
      expect(range.toList(), [start]);
      expect(range.length, 1);
      expect(range.first, start);
      expect(range.last, start);

      expect(range.contains(start - 1), false);
      expect(range.contains(start), true);
      expect(range.contains(start + 1), false);
      expect(range.contains(start + 2), false);
    });

    Glados<int>().test('two elements', (start) {
      final range = IntRange(start, start + 1);

      expect(range.isEmpty, false);
      expect(range.endInclusive, start + 1);
      expect(range.endExclusive, start + 2);
      expect(range.toList(), [start, start + 1]);
      expect(range.length, 2);
      expect(range.first, start);
      expect(range.last, start + 1);

      expect(range.contains(start), true);
      expect(range.contains(start + 1), true);
      expect(range.contains(start + 2), false);
      expect(range.contains(start + 3), false);
    });
  });

  Glados<int>().test('IntRangeFrom', (start) {
    final range = IntRangeFrom(start);

    expect(range.isEmpty, false);
    expect(range.first, start);
    expect(range.take(3).toList(), [start, start + 1, start + 2]);

    expect(range.contains(start - 1), false);
    expect(range.contains(start), true);
    expect(range.contains(start + 1), true);
    expect(range.contains(start + 10000), true);
  });

  Glados<int>().test('IntRangeTo', (endInclusive) {
    final range = IntRangeTo(endInclusive);

    expect(range.contains(endInclusive - 10000), true);
    expect(range.contains(endInclusive - 1), true);
    expect(range.contains(endInclusive), true);
    expect(range.contains(endInclusive + 1), false);
  });

  group('IntProgression', () {
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
      for (final MapEntry(key: progression, value: values)
          in examples.entries) {
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
  });
}
