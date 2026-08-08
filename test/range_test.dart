import 'package:deranged/deranged.dart';
import 'package:glados/glados.dart';
import 'package:meta/meta.dart';

void main() {
  group('until = exclusive, to = inclusive', () {
    test('RangeUntil excludes its end, RangeTo includes it', () {
      expect(const RangeUntil(_Foo(5)).contains(const _Foo(4)), true);
      expect(const RangeUntil(_Foo(5)).contains(const _Foo(5)), false);

      expect(const RangeTo(_Foo(5)).contains(const _Foo(5)), true);
      expect(const RangeTo(_Foo(5)).contains(const _Foo(6)), false);
    });

    test('the RangeBounds factories agree with the classes', () {
      expect(const RangeBounds.until(_Foo(5)), const RangeUntil(_Foo(5)));
      expect(const RangeBounds.to(_Foo(5)), const RangeTo(_Foo(5)));
    });
  });

  group('RangeBoundsOfStepExtension', () {
    test('converts bounds in both directions', () {
      const range = Range(_Foo(0), _Foo(5));

      expect(range.startInclusive, const _Foo(0));
      expect(range.startExclusive, const _Foo(-1));
      expect(range.endInclusive, const _Foo(4));
      expect(range.endExclusive, const _Foo(5));
    });

    test('is null for unbounded ends', () {
      const range = RangeFrom(_Foo(0));

      expect(range.startInclusive, const _Foo(0));
      expect(range.endInclusive, null);
      expect(range.endExclusive, null);
    });
  });

  group('Range', () {
    Glados2(any.foo, any.positiveInt).test('length', (start, size) {
      expect(Range(start, start.stepBy(size)!).length, size);
      expect(Range(start, start).length, 0);
      // Empty ranges have a length of zero, never a negative one.
      expect(Range(start.stepBy(size)!, start).length, 0);
    });

    test('inclusive', () {
      expect(
        const Range(_Foo(0), _Foo(3)).inclusive,
        const RangeInclusive(_Foo(0), _Foo(2)),
      );
      // The end can't be stepped back, so the empty range can't be expressed
      // as a `RangeInclusive`.
      expect(const Range(_Foo(0), _Foo(_Foo.min)).inclusive, null);
    });
  });

  group('RangeInclusive', () {
    Glados2(any.foo, any.positiveInt).test('length', (start, size) {
      expect(RangeInclusive(start, start.stepBy(size)!).length, size + 1);
      expect(RangeInclusive(start, start).length, 1);
      // Empty ranges have a length of zero, never a negative one.
      expect(RangeInclusive(start.stepBy(size)!, start).length, 0);
    });

    test('span & intersection', () {
      const a = RangeInclusive(_Foo(0), _Foo(2));
      const b = RangeInclusive(_Foo(1), _Foo(3));
      const c = RangeInclusive(_Foo(4), _Foo(6));

      expect(
        a.span(b),
        const AnyRange(InclusiveBound(_Foo(0)), InclusiveBound(_Foo(3))),
      );
      // `span` bridges the gap, `|` keeps it.
      expect(
        a.span(c),
        const AnyRange(InclusiveBound(_Foo(0)), InclusiveBound(_Foo(6))),
      );
      expect((a | c).ranges.length, 2);

      expect(a & b, const RangeInclusive(_Foo(1), _Foo(2)));
      expect(a & c, null);

      expect([a, b, c].span, const RangeInclusive(_Foo(0), _Foo(6)));
      expect([a, b].intersection, const RangeInclusive(_Foo(1), _Foo(2)));
      expect([a, c].intersection, null);
      expect(<RangeInclusive<_Foo>>[].span, null);
      expect(<RangeInclusive<_Foo>>[].intersection, null);
    });
  });
}

/// A [Step] type with a smallest value, so that `stepBy(…)` can return `null`.
@immutable
class _Foo with Step<_Foo> {
  const _Foo(this.value);

  static const min = -1000000;

  final int value;

  @override
  int compareTo(_Foo other) => value.compareTo(other.value);

  @override
  _Foo? stepBy(int step) {
    final result = value + step;
    return result < min ? null : _Foo(result);
  }

  @override
  int stepsUntil(_Foo other) => other.value - value;

  @override
  bool operator ==(Object other) => other is _Foo && value == other.value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Foo($value)';
}

extension on Any {
  Generator<_Foo> get foo =>
      intInRange(_Foo.min + 1000, _Foo.min + 2000).map(_Foo.new);
}
