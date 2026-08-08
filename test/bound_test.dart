import 'package:deranged/deranged.dart';
import 'package:glados/glados.dart';
import 'package:meta/meta.dart';

void main() {
  const unbounded = UnboundedBound<_Foo>();
  const inclusive2 = InclusiveBound(_Foo(2));
  const exclusive2 = ExclusiveBound(_Foo(2));
  const inclusive5 = InclusiveBound(_Foo(5));

  group('compareStarts', () {
    test('unbounded begins before everything', () {
      expect(Bound.compareStarts(unbounded, inclusive2), isNegative);
      expect(Bound.compareStarts(inclusive2, unbounded), isPositive);
      expect(Bound.compareStarts(unbounded, unbounded), 0);
    });

    test('orders by value first', () {
      expect(Bound.compareStarts(inclusive2, inclusive5), isNegative);
      expect(Bound.compareStarts(inclusive5, inclusive2), isPositive);
      expect(Bound.compareStarts(inclusive2, inclusive2), 0);
    });

    test('an inclusive start begins before an exclusive one', () {
      // `2..` describes 2, `>2..` doesn't, so it starts earlier.
      expect(Bound.compareStarts(inclusive2, exclusive2), isNegative);
      expect(Bound.compareStarts(exclusive2, inclusive2), isPositive);
    });
  });

  group('compareEnds', () {
    test('unbounded stops after everything', () {
      expect(Bound.compareEnds(unbounded, inclusive2), isPositive);
      expect(Bound.compareEnds(inclusive2, unbounded), isNegative);
      expect(Bound.compareEnds(unbounded, unbounded), 0);
    });

    test('an exclusive end stops before an inclusive one', () {
      // `..<2` doesn't describe 2, `..=2` does, so it stops later.
      expect(Bound.compareEnds(exclusive2, inclusive2), isNegative);
      expect(Bound.compareEnds(inclusive2, exclusive2), isPositive);
    });
  });

  test('laterStart and earlierEnd pick the narrower bound', () {
    expect(Bound.laterStart(inclusive2, inclusive5), inclusive5);
    expect(Bound.laterStart(unbounded, inclusive2), inclusive2);
    expect(Bound.laterStart(inclusive2, exclusive2), exclusive2);

    expect(Bound.earlierEnd(inclusive2, inclusive5), inclusive2);
    expect(Bound.earlierEnd(unbounded, inclusive2), inclusive2);
    expect(Bound.earlierEnd(inclusive2, exclusive2), exclusive2);
  });

  group('adjoins', () {
    test('an unbounded side always adjoins', () {
      expect(Bound.adjoins(unbounded, inclusive2), true);
      expect(Bound.adjoins(inclusive2, unbounded), true);
    });

    test('leaves no gap when the ranges overlap', () {
      expect(Bound.adjoins(inclusive5, inclusive2), true);
    });

    test('at the same value, one inclusive side is enough', () {
      // `..<2` then `2..` covers 2 via the second.
      expect(Bound.adjoins(exclusive2, inclusive2), true);
      // `..=2` then `>2..` covers 2 via the first.
      expect(Bound.adjoins(inclusive2, exclusive2), true);
      // `..<2` then `>2..` covers 2 nowhere.
      expect(Bound.adjoins(exclusive2, exclusive2), false);
    });

    test("can't see adjacency that depends on the values", () {
      // Nothing lies between `_Foo(2)` and `_Foo(3)`, so `..=2` and `3..`
      // really do adjoin – but bounds alone can't tell. That's what
      // `RangeSet.coalescedBy(…)` is for.
      expect(Bound.adjoins(inclusive2, const InclusiveBound(_Foo(3))), false);
    });

    test('works with the Never-typed bounds ranges actually hold', () {
      // Every range's unbounded bound is an `UnboundedBound<Never>`, so this
      // would throw if `adjoins` were a method on the first bound.
      final fromRange = const RangeFull<_Foo>().endBound;

      expect(Bound.adjoins(fromRange, inclusive2), true);
      expect(Bound.adjoins(inclusive2, fromRange), true);
    });
  });

  group('inverted', () {
    test('swaps inclusive and exclusive', () {
      expect(inclusive2.inverted, exclusive2);
      expect(exclusive2.inverted, inclusive2);
      expect(unbounded.inverted, unbounded);
    });

    Glados(any.foo).test('inverting twice restores the bound', (value) {
      for (final bound in <Bound<_Foo>>[
        InclusiveBound(value),
        ExclusiveBound(value),
        const UnboundedBound(),
      ]) {
        expect(bound.inverted.inverted, bound);
      }
    });

    Glados(any.foo).test('an inverted end covers exactly the rest', (value) {
      const range = RangeFull<_Foo>();
      const Bound<_Foo> end = InclusiveBound(_Foo(0));

      // Everything the range describes is either at or before the end, or
      // after its inversion — never both, never neither.
      final before = AnyRange(range.startBound, end);
      final after = AnyRange(end.inverted, range.endBound);

      expect(before.contains(value) != after.contains(value), true);
    });
  });
}

@immutable
class _Foo with Step<_Foo> {
  const _Foo(this.value);

  final int value;

  @override
  int compareTo(_Foo other) => value.compareTo(other.value);
  @override
  _Foo stepBy(int step) => _Foo(value + step);
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
  Generator<_Foo> get foo => this.int.map(_Foo.new);
}
