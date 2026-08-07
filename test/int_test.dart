import 'package:deranged/deranged.dart';
import 'package:glados/glados.dart';

void main() {
  Glados<int>().test('IntRangeFull', (value) {
    expect(const IntRangeFull().contains(value), true);
  });
  group('IntRange', () {
    Glados<int>().test('empty', (start) {
      final range = IntRange(start, start);

      expect(range.isEmpty, true);
      expect(range.endInclusive, start - 1);
      expect(range.end, start);
      expect(range.toList(), <int>[]);
      expect(range.length, 0);
      expect(() => range.first, throwsA(isA<StateError>()));
      expect(() => range.last, throwsA(isA<StateError>()));

      expect(range.contains(start - 1), false);
      expect(range.contains(start), false);
      expect(range.contains(start + 1), false);
    });

    Glados<int>().test('one element', (start) {
      final range = IntRange(start, start + 1);

      expect(range.isEmpty, false);
      expect(range.endInclusive, start);
      expect(range.end, start + 1);
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
      final range = IntRange(start, start + 2);

      expect(range.isEmpty, false);
      expect(range.endInclusive, start + 1);
      expect(range.end, start + 2);
      expect(range.toList(), [start, start + 1]);
      expect(range.length, 2);
      expect(range.first, start);
      expect(range.last, start + 1);

      expect(range.contains(start), true);
      expect(range.contains(start + 1), true);
      expect(range.contains(start + 2), false);
      expect(range.contains(start + 3), false);
    });

    Glados2(any.int, any.positiveInt).test('reversed is empty', (start, size) {
      final range = IntRange(start + size, start);

      expect(range.isEmpty, true);
      expect(range.length, 0);
      expect(range.toList(), <int>[]);
    });

    test('stepBy(…) stays within the exclusive end', () {
      // `0.rangeTo(9)` is `IntRange(0, 10)`, so the last value must be 8 — the
      // exclusive end must not be handed to `IntProgression`, whose end is
      // inclusive.
      expect(0.rangeTo(9).stepBy(2).toList(), [0, 2, 4, 6, 8]);
      expect(0.rangeUntil(4).stepBy(2).toList(), [0, 2]);
      expect(0.rangeUntil(5).stepBy(2).toList(), [0, 2, 4]);
      expect(const IntRange(0, 0).stepBy(2).toList(), <int>[]);
    });

    test('is not an IntProgression', () {
      // `IntRange` used to `implement IntProgression`, which made `==`
      // asymmetric because the two use different equality implementations.
      expect(const IntRange(0, 3), isNot(isA<IntProgression>()));

      // ignore: unrelated_type_equality_checks
      expect(const IntRange(0, 3) == const IntProgression(0, 3, 1), false);
      // ignore: unrelated_type_equality_checks
      expect(const IntProgression(0, 3, 1) == const IntRange(0, 3), false);
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

    expect(range.elementAt(0), start);
    expect(range.elementAt(3), start + 3);
    // Must throw instead of hanging: `length` can't be computed for an
    // infinite range, so it must not be used to validate the index.
    expect(() => range.elementAt(-1), throwsA(isA<RangeError>()));
    expect(() => range.length, throwsA(isA<UnsupportedError>()));
  });

  Glados<int>().test('IntRangeTo', (end) {
    final range = IntRangeTo(end);

    expect(range.endInclusive, end - 1);
    expect(range.contains(end - 10000), true);
    expect(range.contains(end - 1), true);
    expect(range.contains(end), false);
    expect(range.contains(end + 1), false);
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
