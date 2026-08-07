import 'package:deranged/deranged.dart';
import 'package:glados/glados.dart';

void main() {
  Glados(any.double).test('DoubleRangeFull', (value) {
    expect(const DoubleRangeFull().contains(value), true);
  });

  group('DoubleRange', () {
    test('contains(…) excludes the end', () {
      const range = DoubleRange(0, 5);

      expect(range.contains(-0.1), false);
      expect(range.contains(0.0), true);
      expect(range.contains(2.5), true);
      expect(range.contains(4.999), true);
      expect(range.contains(5.0), false);
      expect(range.contains(5.1), false);
    });

    Glados(any.double).test('empty', (start) {
      final range = DoubleRange(start, start);

      expect(range.isEmpty, true);
      expect(range.contains(start), false);
    });
  });

  group('DoubleRangeInclusive', () {
    test('contains(…) includes the end', () {
      const range = DoubleRangeInclusive(0, 5);

      expect(range.contains(-0.1), false);
      expect(range.contains(0.0), true);
      expect(range.contains(2.5), true);
      expect(range.contains(5.0), true);
      expect(range.contains(5.1), false);
    });
  });

  test('DoubleRangeFrom.contains(…)', () {
    const range = DoubleRangeFrom(5);

    expect(range.contains(4.999), false);
    expect(range.contains(5.0), true);
    expect(range.contains(10000.0), true);
  });

  group('DoubleRangeTo', () {
    test('contains(…) excludes the end', () {
      const range = DoubleRangeTo(5);

      expect(range.contains(-10000.0), true);
      expect(range.contains(4.999), true);
      expect(range.contains(5.0), false);
      expect(range.contains(5.1), false);
    });

    test('toString(…) uses the exclusive notation', () {
      expect(const DoubleRangeTo(5).toString(), 'DoubleRangeTo(..<5.0)');
    });
  });

  test('DoubleRangeToInclusive.contains(…) includes the end', () {
    const range = DoubleRangeToInclusive(5);

    expect(range.contains(-10000.0), true);
    expect(range.contains(5.0), true);
    expect(range.contains(5.1), false);
  });

  group('DoubleExtension', () {
    test('rangeUntil(…) keeps the end as-is and excludes it', () {
      final range = 0.0.rangeUntil(5);

      expect(range.start, 0.0);
      expect(range.end, 5.0);
      expect(range.contains(4.999), true);
      expect(range.contains(5.0), false);
    });

    test('rangeTo(…) is inclusive', () {
      final range = 0.0.rangeTo(5);

      expect(range, isA<DoubleRangeInclusive>());
      expect(range.start, 0.0);
      expect(range.end, 5.0);
      expect(range.contains(5.0), true);
    });
  });
}
