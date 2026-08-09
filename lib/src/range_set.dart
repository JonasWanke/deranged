import 'dart:convert';

import 'package:collection/collection.dart';

import '../deranged.dart';
import 'codec.dart';

/// A set of values described by zero or more disjoint [RangeBounds].
///
/// Unlike a single range, a [RangeSet] can describe values with gaps between
/// them, which is what makes [operator |], [operator -], and [operator ~]
/// total operations.
///
/// The contained [ranges] are always normalized: empty ranges are dropped,
/// overlapping and directly adjoining ranges are merged, and what remains is
/// sorted by start bound. Two [RangeSet]s are equal exactly when they describe
/// the same values.
///
/// ```dart
/// final set = RangeSet.of([Range(0, 5), Range(5, 10), Range(20, 30)]);
/// set.ranges.length; // 2 – the first two ranges adjoin and were merged
/// set.contains(15); // false
/// ```
///
/// Whether two ranges adjoin is decided from their bounds alone, so
/// `0..<5` and `5..<10` merge, but `0..=4` and `5..=9` don't – nothing here
/// knows that no [int] lies between 4 and 5. For types that do know, see
/// [DerangedRangeSetOfStep.coalesced].
class RangeSet<C extends Comparable<C>> extends RangeLike<C> {
  /// Creates a set describing the values of all given [ranges].
  factory RangeSet.of(Iterable<RangeLike<C>> ranges) =>
      RangeSet._(_normalize(ranges));

  /// Creates a set describing the values of a single [range].
  factory RangeSet.single(RangeLike<C> range) => .of([range]);

  /// Creates a set describing no values at all.
  const RangeSet.empty() : ranges = const [];

  /// Creates a set describing all values.
  factory RangeSet.full() => .single(RangeFull<C>());

  const RangeSet._(this.ranges);

  /// The disjoint, non-empty ranges of this set, sorted by their start bound.
  ///
  /// No two of these adjoin – otherwise, they would have been merged.
  final List<AnyRange<C>> ranges;

  @override
  bool get isEmpty => ranges.isEmpty;
  @override
  bool get isFull => ranges.length == 1 && ranges.single.isFull;

  @override
  RangeSet<C> get asRangeSet => this;

  @override
  bool contains(C value) => ranges.any((it) => it.contains(value));

  @override
  bool containsAll(RangeLike<C> other) => switch (other) {
    // A range spanning two of our ranges would have to cross the gap between
    // them, so it's enough to look for a single one containing it.
    RangeBounds<C>() =>
      other.isEmpty || ranges.any((it) => it.containsAll(other)),
    _ => other.asRangeSet.ranges.every(containsAll),
  };

  @override
  bool intersects(RangeLike<C> other) =>
      ranges.any((it) => it.intersects(other));

  @override
  AnyRange<C>? get bounds =>
      isEmpty ? null : AnyRange(ranges.first.startBound, ranges.last.endBound);

  @override
  RangeSet<C> operator |(RangeLike<C> other) {
    final otherRanges = other.asRangeSet.ranges;
    // Both lists are already sorted, so they can be merged without sorting
    // again.
    final merged = <AnyRange<C>>[];
    var i = 0;
    var j = 0;
    while (i < ranges.length || j < otherRanges.length) {
      final takeThis =
          j == otherRanges.length ||
          (i < ranges.length &&
              Bound.compareStarts(
                    ranges[i].startBound,
                    otherRanges[j].startBound,
                  ) <=
                  0);
      merged.add(takeThis ? ranges[i++] : otherRanges[j++]);
    }
    return RangeSet._(_mergeSorted(merged));
  }

  @override
  RangeSet<C> operator &(RangeLike<C> other) {
    final otherRanges = other.asRangeSet.ranges;
    // Both lists are sorted, so a single sweep suffices.
    final result = <AnyRange<C>>[];
    var i = 0;
    var j = 0;
    while (i < ranges.length && j < otherRanges.length) {
      final a = ranges[i];
      final b = otherRanges[j];

      final intersection = AnyRange(
        .laterStart(a.startBound, b.startBound),
        .earlierEnd(a.endBound, b.endBound),
      );
      if (intersection.isNotEmpty) result.add(intersection);

      if (Bound.compareEnds(a.endBound, b.endBound) <= 0) {
        i++;
      } else {
        j++;
      }
    }
    // Sweeping disjoint, non-adjoining inputs in order yields output that is
    // already normalized.
    return RangeSet._(result);
  }

  /// Difference of this and [other], i.e., the values described by this set
  /// but not by [other].
  ///
  /// For example, `{0..=9} - {3..=4}` is `{0..<3, >4..=9}`: removing a range
  /// from the middle splits the remainder in two, and the new bounds exclude
  /// the values that were removed.
  @override
  RangeSet<C> operator -(RangeLike<C> other) => this & ~other;

  @override
  RangeSet<C> operator ~() {
    if (isEmpty) return .full();

    final result = <AnyRange<C>>[];

    // An unbounded end has nothing beyond it, so it contributes no gap. Only
    // the first range can start unbounded and only the last can end that way.
    if (ranges.first.startBound is! UnboundedBound<C>) {
      result.add(
        AnyRange(UnboundedBound<C>(), ranges.first.startBound.inverted),
      );
    }
    // The ranges neither overlap nor adjoin, so every gap between two of them
    // holds at least one value.
    for (var i = 1; i < ranges.length; i++) {
      result.add(
        AnyRange(
          ranges[i - 1].endBound.inverted,
          ranges[i].startBound.inverted,
        ),
      );
    }
    if (ranges.last.endBound is! UnboundedBound<C>) {
      result.add(AnyRange(ranges.last.endBound.inverted, UnboundedBound<C>()));
    }

    return RangeSet._(result);
  }

  /// This set with ranges merged that have no values between them, where
  /// [next] returns the value directly after a given one, or `null` if there
  /// is none.
  ///
  /// Normalization only compares bound values, so it keeps `{0..=4, 5..=9}` as
  /// two ranges –  it can't know whether anything lies between 4 and 5.
  /// [next] supplies exactly that knowledge.
  ///
  /// Prefer [DerangedRangeSetOfStep.coalesced], which derives [next] from the
  /// type, or [DerangedRangeSetOfInt.coalescedAsInts] for [int] sets.
  RangeSet<C> coalescedBy(C? Function(C) next) {
    if (ranges.length < 2) return this;

    final result = [ranges.first];
    for (final range in ranges.skip(1)) {
      final last = result.last;
      // Widening the previous end by one value closes exactly the gaps that
      // hold none. An unbounded end can only occur on the last range, which
      // has nothing after it to merge with.
      final widened = switch (last.endBound) {
        InclusiveBound(value: final value) => next(value),
        ExclusiveBound(value: final value) => value,
        UnboundedBound() => null,
      };
      if (widened != null &&
          Bound.adjoins(InclusiveBound(widened), range.startBound)) {
        result.last = AnyRange(last.startBound, range.endBound);
      } else {
        result.add(range);
      }
    }
    return RangeSet._(result);
  }

  @override
  RangeSet<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      .of(ranges.map((it) => it.mapBounds(mapper)));

  @override
  RangeSet<D> castBounds<D extends Comparable<D>>() =>
      .of(ranges.map((it) => it.castBounds<D>()));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RangeSet<C> &&
          const ListEquality<Object?>().equals(ranges, other.ranges);
  @override
  int get hashCode => const ListEquality<Object?>().hash(ranges);

  @override
  String toString() => 'RangeSet{${ranges.map(_format).join(', ')}}';

  static String _format<C extends Comparable<C>>(AnyRange<C> range) {
    final start = switch (range.startBound) {
      InclusiveBound(value: final value) => '$value',
      ExclusiveBound(value: final value) => '>$value',
      UnboundedBound() => '',
    };
    final end = switch (range.endBound) {
      InclusiveBound(value: final value) => '..=$value',
      ExclusiveBound(value: final value) => '..<$value',
      UnboundedBound() => '..',
    };
    return '$start$end';
  }

  static List<AnyRange<C>> _normalize<C extends Comparable<C>>(
    Iterable<RangeLike<C>> ranges,
  ) {
    final sorted = ranges
        .expand(_flatten<C>)
        .where((it) => it.isNotEmpty)
        .sorted((a, b) {
          final byStart = Bound.compareStarts(a.startBound, b.startBound);
          return byStart != 0
              ? byStart
              : Bound.compareEnds(a.endBound, b.endBound);
        });
    return _mergeSorted(sorted);
  }

  /// Merges the overlapping and adjoining ranges of a list that is already
  /// sorted by start bound and holds no empty ranges.
  static List<AnyRange<C>> _mergeSorted<C extends Comparable<C>>(
    List<AnyRange<C>> sorted,
  ) {
    final result = <AnyRange<C>>[];
    for (final range in sorted) {
      final last = result.lastOrNull;
      if (last == null || !Bound.adjoins(last.endBound, range.startBound)) {
        result.add(range);
      } else if (Bound.compareEnds(range.endBound, last.endBound) > 0) {
        result.last = AnyRange(last.startBound, range.endBound);
      }
    }
    return result;
  }

  /// The plain ranges of a [RangeLike], so that a [RangeSet] can be built from
  /// single ranges and other sets alike.
  static Iterable<AnyRange<C>> _flatten<C extends Comparable<C>>(
    RangeLike<C> range,
  ) => switch (range) {
    RangeBounds<C>() => [AnyRange(range.startBound, range.endBound)],
    RangeSet<C>() => range.ranges,
    _ => range.asRangeSet.ranges,
  };
}

extension DerangedRangeSetOfStep<T extends Step<T>> on RangeSet<T> {
  /// This set with ranges merged that have no values between them.
  ///
  /// [RangeSet] normalization only looks at bound values, so it keeps
  /// `{0..=4, 5..=9}` as two ranges. For a [Step] type, nothing lies between 4
  /// and 5, so this merges them into `{0..=9}`.
  RangeSet<T> get coalesced => coalescedBy((it) => it.next);
}

extension DerangedRangeSetOfInt on RangeSet<num> {
  /// This set with ranges merged that have no [int]s between them.
  ///
  /// The [int] counterpart of [DerangedRangeSetOfStep.coalesced]: [int] can't
  /// implement [Step], because it is a `Comparable<num>` rather than a
  /// `Comparable<int>`.
  ///
  /// ⚠️ Only call this on a set of [int] ranges. A `RangeSet<num>` can just as
  /// well hold [double] ranges –  [IntRange] and [DoubleRange] are both
  /// `Range<num>` –  and no [double] set should be coalesced in steps of one.
  RangeSet<num> get coalescedAsInts => coalescedBy((it) => it + 1);
}

extension DerangedIterableOfRangeLike<C extends Comparable<C>>
    on Iterable<RangeLike<C>> {
  /// A [RangeSet] describing the values of all of these.
  RangeSet<C> get asRangeSet => .of(this);
}

/// Encodes a [RangeSet] as a list.
class RangeSetAsListCodec<C extends Comparable<C>>
    extends CodecAndJsonConverter<RangeSet<C>, List<dynamic>> {
  const RangeSetAsListCodec([this.innerCodec]);

  /// Codec for the individual ranges within the set.
  final Codec<AnyRange<C>, Object?>? innerCodec;

  Codec<AnyRange<C>, Object?> get _innerCodec =>
      innerCodec ?? AnyRangeAsMapCodec<C>();

  @override
  List<dynamic> encode(RangeSet<C> input) =>
      input.ranges.map(_innerCodec.encode).toList();
  @override
  RangeSet<C> decode(List<dynamic> encoded) =>
      .of(encoded.cast<Map<String, dynamic>>().map(_innerCodec.decode));
}
