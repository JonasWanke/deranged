import 'package:deranged/deranged.dart';
import 'package:glados/glados.dart';
import 'package:meta/meta.dart';

RangeSet<num> _set(List<RangeBounds<num>> ranges) => RangeSet.of(ranges);

/// All values in `-20..=20` that [set] describes – the sets under test stay
/// well inside that window, so this is a faithful sample.
List<int> _values(RangeSet<num> set) => [
  for (var i = -20; i <= 20; i++)
    if (set.contains(i)) i,
];

void main() {
  group('normalization', () {
    test('drops empty ranges', () {
      expect(_set([const IntRange(5, 5), const IntRange(9, 3)]).isEmpty, true);
      expect(_set([]).isEmpty, true);
    });

    test('merges overlapping ranges', () {
      final set = _set([const IntRange(0, 6), const IntRange(4, 10)]);

      expect(set.ranges.length, 1);
      expect(_values(set), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('merges ranges that touch at a bound', () {
      // `..<5` and `5..<10` leave no value uncovered.
      final set = _set([const IntRange(0, 5), const IntRange(5, 10)]);

      expect(set.ranges.length, 1);
      expect(
        set.ranges.single,
        const AnyRange<num>(.inclusive(0), .exclusive(10)),
      );
    });

    test('keeps a gap when both bounds exclude the same value', () {
      // `..<5` and `>5..` both exclude 5.
      final set = _set([
        const IntRange(0, 5),
        const AnyRange<num>(.exclusive(5), .inclusive(10)),
      ]);

      expect(set.ranges.length, 2);
      expect(set.contains(5), false);
      expect(set.contains(4), true);
      expect(set.contains(6), true);
    });

    test('does not merge merely adjacent ranges without Step', () {
      // Nothing here knows that no `int` lies between 4 and 5.
      final set = _set([
        const RangeInclusive<num>(0, 4),
        const RangeInclusive<num>(5, 9),
      ]);

      expect(set.ranges.length, 2);
      expect(_values(set), [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]);
    });

    test('sorts and handles unbounded ends', () {
      final set = _set([
        const IntRangeFrom(10),
        const IntRangeUntil(0),
        const IntRange(3, 5),
      ]);

      expect(set.ranges.length, 3);
      expect(set.contains(-100), true);
      expect(set.contains(0), false);
      expect(set.contains(4), true);
      expect(set.contains(7), false);
      expect(set.contains(1000), true);
    });

    test('a full range absorbs everything', () {
      final set = _set([const IntRange(3, 5), const IntRangeFull()]);

      expect(set.ranges.length, 1);
      expect(set.ranges.single.isFull, true);
    });
  });

  group('operators', () {
    test('| keeps gaps, span bridges them', () {
      final union =
          _set([const IntRange(0, 3)]) | _set([const IntRange(7, 10)]);

      expect(union.ranges.length, 2);
      expect(_values(union), [0, 1, 2, 7, 8, 9]);
      expect(union.bounds, const AnyRange<num>(.inclusive(0), .exclusive(10)));
    });

    test('&', () {
      final a = _set([const IntRange(0, 10), const IntRange(20, 30)]);
      final b = _set([const IntRange(5, 25)]);

      expect(_values(a & b), [5, 6, 7, 8, 9, 20]);
      expect((a & _set([])).isEmpty, true);
      expect(a & b, b & a);
    });

    test('- splits a range when removing from its middle', () {
      final result =
          _set([const RangeInclusive<num>(0, 9)]) -
          _set([const RangeInclusive<num>(3, 4)]);

      expect(result.ranges.length, 2);
      expect(_values(result), [0, 1, 2, 5, 6, 7, 8, 9]);
      expect(result.ranges, const [
        AnyRange<num>(.inclusive(0), .exclusive(3)),
        AnyRange<num>(.exclusive(4), .inclusive(9)),
      ]);
    });

    test('- with no overlap changes nothing', () {
      final a = _set([const IntRange(0, 3)]);

      expect(a - _set([const IntRange(10, 20)]), a);
      expect(a - _set([]), a);
      expect((a - a).isEmpty, true);
    });

    test('~', () {
      final set = _set([const RangeInclusive<num>(0, 4)]);

      expect(_values(~set), [
        for (var i = -20; i < 0; i++) i,
        for (var i = 5; i <= 20; i++) i,
      ]);
      expect(~~set, set);

      expect(~const RangeSet<num>.empty(), RangeSet<num>.full());
      expect(~RangeSet<num>.full(), const RangeSet<num>.empty());
    });

    test('range operators produce sets', () {
      expect(
        const IntRange(0, 3) | const IntRange(7, 10),
        isA<RangeSet<num>>(),
      );
      expect(_values(const IntRange(0, 3) | const IntRange(7, 10)), [
        0,
        1,
        2,
        7,
        8,
        9,
      ]);
      expect(_values(const IntRange(0, 10) - const IntRange(3, 5)), [
        0,
        1,
        2,
        5,
        6,
        7,
        8,
        9,
      ]);
      expect(
        const IntRange(0, 3).span(const IntRange(7, 10)),
        const AnyRange<num>(.inclusive(0), .exclusive(10)),
      );
    });
  });

  group('RangeLike mixes ranges and sets', () {
    final set = _set([const IntRange(0, 5), const IntRange(10, 15)]);
    const range = IntRange(3, 12);

    test('the operators accept either side', () {
      expect(_values(range | set), [for (var i = 0; i < 15; i++) i]);
      expect(_values(set | range), _values(range | set));
      expect(_values(range & set), [3, 4, 10, 11]);
      expect(_values(set & range), _values(range & set));
      expect(_values(range - set), [5, 6, 7, 8, 9]);
      expect(_values(set - range), [0, 1, 2, 12, 13, 14]);
    });

    test('~ works on a plain range', () {
      expect(
        ~const IntRange(0, 5),
        _set([const IntRangeUntil(0), const IntRangeFrom(5)]),
      );
      expect(_values(~const IntRange(0, 5)), [
        for (var i = -20; i < 0; i++) i,
        for (var i = 5; i <= 20; i++) i,
      ]);
    });

    test('queries accept either side', () {
      expect(range.intersects(set), true);
      expect(set.intersects(range), true);
      expect(const IntRange(6, 9).intersects(set), false);
      expect(set.intersects(const IntRange(6, 9)), false);

      expect(set.containsAll(const IntRange(1, 4)), true);
      expect(const IntRangeFull().containsAll(set), true);
      expect(const IntRange(0, 5).containsAll(set), false);
    });

    test('bounds and span', () {
      expect(set.bounds, const AnyRange<num>(.inclusive(0), .exclusive(15)));
      expect(
        const IntRange(0, 3).bounds,
        const AnyRange<num>(.inclusive(0), .exclusive(3)),
      );
      // An empty range describes no values, so it has no covering range.
      expect(const IntRange(5, 3).bounds, null);

      expect(
        const IntRange(0, 3).span(const IntRange(7, 10)),
        const AnyRange<num>(.inclusive(0), .exclusive(10)),
      );
      // Now works between a range and a set, in both directions.
      expect(
        set.span(const IntRange(20, 30)),
        const AnyRange<num>(.inclusive(0), .exclusive(30)),
      );
      expect(
        const IntRange(20, 30).span(set),
        set.span(const IntRange(20, 30)),
      );
      // An empty operand contributes nothing.
      expect(
        const IntRange(5, 3).span(const IntRange(0, 2)),
        const IntRange(0, 2).bounds,
      );
    });

    test('RangeSet.of accepts sets as well as ranges', () {
      expect(RangeSet.of([set, range]), set | range);
      expect([set, range].asRangeSet, set | range);
    });
  });

  group('queries', () {
    final set = _set([const IntRange(0, 5), const IntRange(10, 15)]);

    test('containsRange', () {
      expect(set.containsAll(const IntRange(1, 4)), true);
      expect(set.containsAll(const IntRange(0, 5)), true);
      // Spans the gap, so it isn't contained even though both ends are.
      expect(set.containsAll(const IntRange(4, 11)), false);
      expect(set.containsAll(const IntRange(6, 8)), false);
      expect(set.containsAll(const IntRange(5, 5)), true); // empty
    });

    test('intersects', () {
      expect(set.intersects(const IntRange(4, 11)), true);
      expect(set.intersects(const IntRange(6, 9)), false);
      expect(set.intersects(const IntRangeFull()), true);
    });

    test('isFull means "describes every value"', () {
      expect(RangeSet<num>.full().isFull, true);
      expect(const IntRangeFull().isFull, true);

      expect(const RangeSet<num>.empty().isFull, false);
      expect(set.isFull, false);
      // Unbounded in both directions, but with a gap, so not full. This is
      // exactly why it isn't called `isUnbounded`.
      final gapped = _set([const IntRangeUntil(0), const IntRangeFrom(5)]);
      expect(gapped.ranges.first.startBound.isUnbounded, true);
      expect(gapped.ranges.last.endBound.isUnbounded, true);
      expect(gapped.bounds!.isFull, true);
      expect(gapped.isFull, false);

      // Complementing swaps it with `isEmpty`.
      expect((~const RangeSet<num>.empty()).isFull, true);
      expect((~RangeSet<num>.full()).isEmpty, true);
    });

    test('bounds is null for an empty set', () {
      expect(const RangeSet<num>.empty().bounds, null);
    });
  });

  test('equality ignores how a set was built', () {
    expect(
      _set([const IntRange(0, 5), const IntRange(5, 10)]),
      _set([const IntRange(0, 10)]),
    );
    expect(
      _set([const IntRange(0, 5), const IntRange(5, 10)]).hashCode,
      _set([const IntRange(0, 10)]).hashCode,
    );
    expect(_set([const IntRange(0, 5)]) == _set([const IntRange(0, 6)]), false);
  });

  test('toString', () {
    expect(
      _set([
        const IntRangeUntil(0),
        const RangeInclusive<num>(3, 4),
        const IntRangeFrom(10),
      ]).toString(),
      'RangeSet{..<0, 3..=4, 10..}',
    );
    expect(const RangeSet<num>.empty().toString(), 'RangeSet{}');
  });

  test('asRangeSet', () {
    expect(const IntRange(0, 5).asRangeSet, _set([const IntRange(0, 5)]));
    expect([const IntRange(0, 5)].asRangeSet, _set([const IntRange(0, 5)]));
  });

  test('mapBounds', () {
    final set = _set([const IntRange(0, 3), const IntRange(10, 12)]);

    expect(
      set.mapBounds((it) => _Foo(it.toInt() * 2)),
      RangeSet.of(const [
        AnyRange(InclusiveBound(_Foo(0)), ExclusiveBound(_Foo(6))),
        AnyRange(InclusiveBound(_Foo(20)), ExclusiveBound(_Foo(24))),
      ]),
    );
  });

  test('castBounds', () {
    final set = _set([const IntRange(0, 3), const IntRange(10, 12)]);

    expect(set.castBounds<num>(), set);
    expect(set.castBounds<num>().contains(1), true);
    expect(set.castBounds<num>().contains(5), false);

    // Casting to a type the values aren't throws, as it does for one range.
    expect(set.castBounds<_Foo>, throwsA(isA<TypeError>()));
  });

  group('coalesced', () {
    test('merges ranges with no values between them', () {
      final set = RangeSet.of(const [
        RangeInclusive(_Foo(0), _Foo(4)),
        RangeInclusive(_Foo(5), _Foo(9)),
      ]);

      expect(set.ranges.length, 2);
      expect(set.coalesced.ranges.length, 1);
      expect(
        set.coalesced.ranges.single,
        const AnyRange(InclusiveBound(_Foo(0)), InclusiveBound(_Foo(9))),
      );
    });

    test('keeps ranges with a value between them', () {
      final set = RangeSet.of(const [
        RangeInclusive(_Foo(0), _Foo(4)),
        RangeInclusive(_Foo(6), _Foo(9)),
      ]);

      expect(set.coalesced.ranges.length, 2);
      expect(set.coalesced, set);
    });

    test('coalescedAsInts is the int counterpart', () {
      final set = _set([
        const RangeInclusive<num>(0, 4),
        const RangeInclusive<num>(5, 9),
      ]);

      expect(set.ranges.length, 2);
      expect(set.coalescedAsInts.ranges.length, 1);
      expect(
        set.coalescedAsInts.ranges.single,
        const AnyRange<num>(.inclusive(0), .inclusive(9)),
      );

      // Half-open int ranges already merge during normalization.
      expect(
        _set([const IntRange(0, 5), const IntRange(5, 10)]).ranges.length,
        1,
      );
      // A real gap survives.
      expect(
        _set([
          const IntRange(0, 5),
          const IntRange(6, 10),
        ]).coalescedAsInts.ranges.length,
        2,
      );
    });

    test('leaves short sets alone', () {
      expect(const RangeSet<_Foo>.empty().coalesced.isEmpty, true);
      expect(
        RangeSet.of(const [RangeInclusive(_Foo(0), _Foo(4))]).coalesced.ranges,
        hasLength(1),
      );
    });
  });

  group('codec', () {
    const codec = RangeSetAsListCodec<num>();

    test('round-trips', () {
      final set = _set([const IntRangeUntil(0), const IntRange(3, 5)]);

      expect(codec.encode(set), [
        {
          'start': {'type': 'unbounded'},
          'end': {'type': 'exclusive', 'value': 0},
        },
        {
          'start': {'type': 'inclusive', 'value': 3},
          'end': {'type': 'exclusive', 'value': 5},
        },
      ]);
      expect(codec.decode(codec.encode(set)), set);
    });

    test('empty', () {
      expect(codec.encode(const RangeSet<num>.empty()), <Object?>[]);
      expect(codec.decode(<Object?>[]), const RangeSet<num>.empty());
    });
  });

  group('properties', () {
    Glados2(any.intRangeSet, any.intRangeSet).test('union is a superset', (
      a,
      b,
    ) {
      final union = a | b;

      for (var i = -20; i <= 20; i++) {
        expect(union.contains(i), a.contains(i) || b.contains(i));
      }
    });

    Glados2(any.intRangeSet, any.intRangeSet).test('intersection', (a, b) {
      final intersection = a & b;

      for (var i = -20; i <= 20; i++) {
        expect(intersection.contains(i), a.contains(i) && b.contains(i));
      }
    });

    Glados2(any.intRangeSet, any.intRangeSet).test('difference', (a, b) {
      final difference = a - b;

      for (var i = -20; i <= 20; i++) {
        expect(difference.contains(i), a.contains(i) && !b.contains(i));
      }
    });

    Glados(any.intRangeSet).test('~', (set) {
      final complement = ~set;

      for (var i = -20; i <= 20; i++) {
        expect(complement.contains(i), !set.contains(i));
      }
      expect(~complement, set);
    });

    Glados2(any.intRangeSet, any.intRangeSet).test(
      '| and & return normalized sets',
      (a, b) {
        // Both sweep their sorted inputs and skip the normalization pass, so
        // their output has to come out normalized on its own.
        for (final set in [a | b, a & b]) {
          expect(RangeSet.of(set.ranges).ranges, set.ranges);
        }
      },
    );

    Glados(any.intRangeSet).test('ranges are sorted and disjoint', (set) {
      for (var i = 1; i < set.ranges.length; i++) {
        final previous = set.ranges[i - 1];
        final current = set.ranges[i];

        expect(previous.isNotEmpty, true);
        expect(previous.intersects(current), false);
        // They must not adjoin either, or they'd have been merged.
        expect(RangeSet.of([previous, current]).ranges.length, 2);
      }
    });
  });
}

extension on Any {
  Generator<RangeSet<num>> get intRangeSet => listWithLengthInRange(
    0,
    4,
    intInRange(-15, 15).bind(
      (start) => intInRange(0, 8).map((size) => IntRange(start, start + size)),
    ),
  ).map(RangeSet<num>.of);
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
