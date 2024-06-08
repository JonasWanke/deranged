import 'package:glados/glados.dart';
import 'package:ranges/ranges.dart';

void main() {
  group('IntRange', () {
    Glados<int>().test('empty', (start) {
      final range = IntRange(start, start);

      expect(range.isEmpty, true);
      expect(range.endInclusive, start - 1);
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

  Glados<int>().test('IntRangeTo', (start) {
    final range = IntRangeTo(start);

    expect(range.contains(start - 10000), true);
    expect(range.contains(start - 1), true);
    expect(range.contains(start), false);
    expect(range.contains(start + 1), false);
  });
}
