import 'package:deranged/deranged.dart';
import 'package:glados/glados.dart';
import 'package:meta/meta.dart';

void main() {
  group('clamp(…)', () {
    test('RangeInclusive', () {
      const range = RangeInclusive(_Foo(2), _Foo(7));

      expect(range.clamp(const _Foo(0)), const _Foo(2));
      expect(range.clamp(const _Foo(2)), const _Foo(2));
      expect(range.clamp(const _Foo(5)), const _Foo(5));
      expect(range.clamp(const _Foo(7)), const _Foo(7));
      expect(range.clamp(const _Foo(9)), const _Foo(7));
    });

    test('RangeFrom only limits from below', () {
      const range = RangeFrom(_Foo(2));

      expect(range.clamp(const _Foo(0)), const _Foo(2));
      expect(range.clamp(const _Foo(10000)), const _Foo(10000));
    });

    test('RangeTo only limits from above', () {
      const range = RangeTo(_Foo(7));

      expect(range.clamp(const _Foo(-10000)), const _Foo(-10000));
      expect(range.clamp(const _Foo(9)), const _Foo(7));
    });

    test('the Step extension converts exclusive bounds', () {
      // 2..<8 clamps to 7, not 8.
      const range = Range(_Foo(2), _Foo(8));

      expect(range.clamp(const _Foo(0)), const _Foo(2));
      expect(range.clamp(const _Foo(5)), const _Foo(5));
      expect(range.clamp(const _Foo(9)), const _Foo(7));
    });

    test('the Step extension ignores unbounded ends', () {
      expect(const RangeFull<_Foo>().clamp(const _Foo(9)), const _Foo(9));
      expect(const RangeFrom(_Foo(2)).clamp(const _Foo(0)), const _Foo(2));
    });

    Glados2(any.int, any.int).test('IntRange', (start, value) {
      final range = IntRange(start, start + 5);
      final clamped = range.clamp(value);

      expect(range.contains(clamped), true);
      if (range.contains(value)) expect(clamped, value);
    });

    test('DoubleRangeInclusive', () {
      const range = DoubleRangeInclusive(2, 7);

      expect(range.clamp(0), 2.0);
      expect(range.clamp(5.5), 5.5);
      expect(range.clamp(9), 7.0);
    });

    test('DoubleRangeFrom and DoubleRangeTo', () {
      expect(const DoubleRangeFrom(2).clamp(0), 2.0);
      expect(const DoubleRangeFrom(2).clamp(9), 9.0);
      expect(const DoubleRangeTo(7).clamp(9), 7.0);
      expect(const DoubleRangeTo(7).clamp(0), 0.0);
    });
  });

  group('mapBounds(…) & castBounds(…)', () {
    test('preserve the range shape', () {
      _Foo double(_Foo it) => _Foo(it.value * 2);

      expect(
        const Range(_Foo(1), _Foo(3)).mapBounds(double),
        const Range(_Foo(2), _Foo(6)),
      );
      expect(
        const RangeInclusive(_Foo(1), _Foo(3)).mapBounds(double),
        const RangeInclusive(_Foo(2), _Foo(6)),
      );
      expect(
        const RangeFrom(_Foo(1)).mapBounds(double),
        const RangeFrom(_Foo(2)),
      );
      expect(
        const RangeUntil(_Foo(3)).mapBounds(double),
        const RangeUntil(_Foo(6)),
      );
      expect(const RangeTo(_Foo(3)).mapBounds(double), const RangeTo(_Foo(6)));
      expect(
        const RangeFull<_Foo>().mapBounds(double),
        const RangeFull<_Foo>(),
      );
      expect(
        const AnyRange(
          ExclusiveBound(_Foo(1)),
          UnboundedBound<_Foo>(),
        ).mapBounds(double),
        const AnyRange(ExclusiveBound(_Foo(2)), UnboundedBound<_Foo>()),
      );
    });

    test('return the precise static type', () {
      // These only compile because each subclass narrows the base's
      // `RangeBounds<D>` return type — the helpers accept nothing wider.
      expect(
        _takesRange(const Range(_Foo(1), _Foo(3)).mapBounds((it) => it)),
        const Range(_Foo(1), _Foo(3)),
      );
      expect(
        _takesRangeInclusive(
          const RangeInclusive(_Foo(1), _Foo(3)).castBounds<_Foo>(),
        ),
        const RangeInclusive(_Foo(1), _Foo(3)),
      );
      expect(
        _takesRangeFrom(const RangeFrom(_Foo(1)).mapBounds((it) => it)),
        const RangeFrom(_Foo(1)),
      );
    });

    test('int and double ranges pass int/double to the mapper', () {
      // The mapper's parameter is `int`/`double`, not `num` — these lambdas
      // only compile because of that narrowing.
      expect(
        const IntRange(1, 3).mapBounds((it) => _Foo(it.toUnsigned(8))),
        const Range(_Foo(1), _Foo(3)),
      );
      expect(
        const IntRangeFrom(1).mapBounds((it) => _Foo(it.toUnsigned(8))),
        const RangeFrom(_Foo(1)),
      );
      expect(
        const IntRangeUntil(3).mapBounds((it) => _Foo(it.toUnsigned(8))),
        const RangeUntil(_Foo(3)),
      );
      expect(
        const DoubleRange(1, 3).mapBounds((it) => _Foo(it.truncate())),
        const Range(_Foo(1), _Foo(3)),
      );
      expect(
        const DoubleRangeInclusive(1, 3).mapBounds((it) => _Foo(it.truncate())),
        const RangeInclusive(_Foo(1), _Foo(3)),
      );
      expect(
        const DoubleRangeTo(3).mapBounds((it) => _Foo(it.truncate())),
        const RangeTo(_Foo(3)),
      );
      expect(
        const DoubleRangeUntil(3).mapBounds((it) => _Foo(it.truncate())),
        const RangeUntil(_Foo(3)),
      );
      expect(
        const IntRangeFull().mapBounds((it) => _Foo(it.toUnsigned(8))),
        const RangeFull<_Foo>(),
      );
    });

    test('castBounds throws when a value is of another type', () {
      const range = Range(_Foo(1), _Foo(3));

      expect(range.castBounds<_Foo>, returnsNormally);
      expect(range.castBounds<_Bar>, throwsA(isA<TypeError>()));
    });
  });

  group('shift(…)', () {
    test('moves both bounds', () {
      expect(
        const Range(_Foo(1), _Foo(3)).shift(2),
        const Range(_Foo(3), _Foo(5)),
      );
      expect(
        const RangeInclusive(_Foo(1), _Foo(3)).shift(-1),
        const RangeInclusive(_Foo(0), _Foo(2)),
      );
      expect(const IntRange(1, 3).shift(2), const IntRange(3, 5));
      expect(const IntRangeFrom(1).shift(2), const IntRangeFrom(3));
      expect(const IntRangeUntil(3).shift(2), const IntRangeUntil(5));
      expect(const DoubleRange(1, 3).shift(0.5), const DoubleRange(1.5, 3.5));
      expect(const DoubleRangeTo(3).shift(0.5), const DoubleRangeTo(3.5));
    });

    test('returns null when a bound cannot be stepped that far', () {
      // `_Foo` can't step below `_Foo.min`.
      expect(const Range(_Foo(0), _Foo(3)).shift(_Foo.min - 1), null);
      expect(const RangeInclusive(_Foo(0), _Foo(3)).shift(_Foo.min * 2), null);
    });

    Glados2(any.int, any.int).test('IntRange preserves length', (start, by) {
      final range = IntRange(start, start + 5);

      expect(range.shift(by).length, range.length);
      expect(range.shift(by).start, start + by);
    });
  });

  group('copyWith(…)', () {
    test('replaces only the given bounds', () {
      const range = Range(_Foo(1), _Foo(3));

      expect(
        range.copyWith(start: const _Foo(0)),
        const Range(_Foo(0), _Foo(3)),
      );
      expect(range.copyWith(end: const _Foo(9)), const Range(_Foo(1), _Foo(9)));
      expect(range.copyWith(), range);
    });

    test('keeps the precise type for int and double ranges', () {
      expect(const IntRange(1, 3).copyWith(end: 9), const IntRange(1, 9));
      expect(const DoubleRange(1, 3).copyWith(end: 9), const DoubleRange(1, 9));
      expect(
        const DoubleRangeInclusive(1, 3).copyWith(end: 9),
        const DoubleRangeInclusive(1, 9),
      );
    });

    test('copyWithBounds replaces whole bounds, on any range', () {
      const range = AnyRange(InclusiveBound(_Foo(1)), UnboundedBound<_Foo>());

      expect(
        range.copyWithBounds(endBound: const ExclusiveBound(_Foo(9))),
        const AnyRange(InclusiveBound(_Foo(1)), ExclusiveBound(_Foo(9))),
      );
      // It's on `RangeBounds`, so it also works for the fixed-shape ranges —
      // returning an `AnyRange`, since the shape may change.
      expect(
        const Range(
          _Foo(1),
          _Foo(3),
        ).copyWithBounds(endBound: const InclusiveBound(_Foo(9))),
        const AnyRange(InclusiveBound(_Foo(1)), InclusiveBound(_Foo(9))),
      );
      expect(
        const IntRangeUntil(
          3,
        ).copyWithBounds(startBound: const InclusiveBound(0)),
        const AnyRange<num>(InclusiveBound(0), ExclusiveBound(3)),
      );
    });
  });

  group('reverse', () {
    test('IntRange', () {
      expect(const IntRange(0, 4).reverse.toList(), [3, 2, 1, 0]);
      expect(const IntRange(0, 0).reverse.toList(), <int>[]);
      expect(const IntRange(5, 3).reverse.toList(), <int>[]);
    });

    test('IntProgression starts at `last`, not `endInclusive`', () {
      // 0, 2, 4, 6, 8 — `endInclusive` is 9, but `last` is 8.
      expect(const IntProgression(0, 9, 2).reverse.toList(), [8, 6, 4, 2, 0]);
      expect(const IntProgression(0, 10, 2).reverse.toList(), [
        10,
        8,
        6,
        4,
        2,
        0,
      ]);
      expect(const IntProgression(10, 0, -2).reverse.toList(), [
        0,
        2,
        4,
        6,
        8,
        10,
      ]);
    });

    test('reversing an empty progression stays empty', () {
      const empty = IntProgression(5, 0, 1);

      expect(empty.isEmpty, true);
      expect(empty.reverse.isEmpty, true);
      expect(empty.reverse.toList(), <int>[]);
    });

    Glados2(any.int, any.int).test('IntProgression round-trips', (start, size) {
      final progression = IntProgression(start, start + size.abs() % 20, 3);

      expect(
        progression.reverse.toList(),
        progression.toList().reversed.toList(),
      );
      expect(progression.reverse.reverse.toList(), progression.toList());
    });

    test('StepProgression', () {
      const progression = StepProgression(_Foo(0), _Foo(9), 2);

      expect(progression.toList(), const [
        _Foo(0),
        _Foo(2),
        _Foo(4),
        _Foo(6),
        _Foo(8),
      ]);
      expect(progression.reverse.toList(), const [
        _Foo(8),
        _Foo(6),
        _Foo(4),
        _Foo(2),
        _Foo(0),
      ]);
      expect(const StepProgression(_Foo(5), _Foo(0), 1).reverse.isEmpty, true);
    });
  });

  group('isSingle', () {
    test('Range', () {
      expect(const Range(_Foo(1), _Foo(2)).isSingle, true);
      expect(const Range(_Foo(1), _Foo(3)).isSingle, false);
      expect(const Range(_Foo(1), _Foo(1)).isSingle, false);
    });

    test('IntRange', () {
      expect(const IntRange(1, 2).isSingle, true);
      expect(const IntRange(1, 3).isSingle, false);
      expect(const IntRange(1, 1).isSingle, false);
      expect(const IntRange(3, 1).isSingle, false);
    });

    test('RangeInclusive', () {
      expect(const RangeInclusive(_Foo(1), _Foo(1)).isSingle, true);
      expect(const RangeInclusive(_Foo(1), _Foo(2)).isSingle, false);
    });
  });
}

Range<_Foo> _takesRange(Range<_Foo> it) => it;
RangeInclusive<_Foo> _takesRangeInclusive(RangeInclusive<_Foo> it) => it;
RangeFrom<_Foo> _takesRangeFrom(RangeFrom<_Foo> it) => it;

/// A [Step] type with a smallest value, so `stepBy(…)` can return `null`.
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

@immutable
class _Bar implements Comparable<_Bar> {
  const _Bar(this.value);

  final int value;

  @override
  int compareTo(_Bar other) => value.compareTo(other.value);
}
