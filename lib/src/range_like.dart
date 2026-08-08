import 'package:meta/meta.dart';

import '../deranged.dart';

/// Anything that describes a set of values of type [C]: A single range
/// ([RangeBounds]) or several ([RangeSet]).
///
/// This is where the set algebra lives, so it works between the two
/// interchangeably:
///
/// ```dart
/// ~IntRange(0, 5);                   // RangeSet{..<0, 5..}
/// IntRange(0, 5) | someRangeSet;     // RangeSet
/// someRangeSet.intersects(IntRange(0, 5));
/// ```
///
/// The operators mirror the bitwise ones because that is exactly what set
/// algebra is: [operator |] union, [operator &] intersection, [operator -]
/// difference, and [operator ~] complement. They always return a [RangeSet],
/// since none of them can generally be described by a single range.
@immutable
abstract class RangeLike<C extends Comparable<C>> {
  const RangeLike();

  /// Whether this describes no values at all.
  bool get isEmpty;

  /// Whether this describes at least one value.
  bool get isNotEmpty => !isEmpty;

  /// Whether this describes *every* value, i.e., the same values as a
  /// [RangeFull].
  ///
  /// The counterpart of [isEmpty]: complementing one yields the other.
  bool get isFull;

  /// Returns whether [value] is described by this.
  bool contains(C value);

  /// Returns whether every value of [other] is described by this.
  ///
  /// An empty [other] is always contained, since it has no values that could
  /// be missing.
  bool containsAll(RangeLike<C> other);

  /// Returns whether this and [other] have at least one value in common.
  bool intersects(RangeLike<C> other);

  /// A [RangeSet] describing the same values as this.
  RangeSet<C> get asRangeSet;

  /// The smallest single range containing every value of this, or `null` if
  /// this is empty.
  ///
  /// This bridges gaps: the bounds of `{0..=2, 8..=9}` are `0..=9`.
  AnyRange<C>? get bounds;

  /// The smallest single range containing every value of this and [other], or
  /// `null` if both are empty.
  ///
  /// Like [bounds], this bridges gaps. For the union, which keeps them, use
  /// [operator |].
  AnyRange<C>? span(RangeLike<C> other) {
    final a = bounds;
    final b = other.bounds;
    if (a == null) return b;
    if (b == null) return a;

    return AnyRange(
      .earlierStart(a.startBound, b.startBound),
      .laterEnd(a.endBound, b.endBound),
    );
  }

  /// Union of this and [other], i.e., every value described by either.
  ///
  /// Gaps are preserved. For the smallest single range covering both, use
  /// [span].
  RangeSet<C> operator |(RangeLike<C> other) => asRangeSet | other;

  /// Intersection of this and [other], i.e., the values described by both.
  RangeSet<C> operator &(RangeLike<C> other) => asRangeSet & other;

  /// Difference of this and [other], i.e., the values described by this but
  /// not by [other].
  RangeSet<C> operator -(RangeLike<C> other) => asRangeSet - other;

  /// Complement of this, i.e., the values it does *not* describe.
  RangeSet<C> operator ~() => ~asRangeSet;

  /// Returns this with every bound value mapped using [mapper].
  ///
  /// [mapper] must be monotonically increasing, i.e., preserve the order of
  /// values. Otherwise, the resulting bounds end up swapped.
  ///
  /// {@template deranged.RangeLike.boundsNaming}
  /// This is not called `map`/`cast` because [IntRange] & co. also implement
  /// [Iterable], where those names mean converting the *elements* rather than
  /// the bounds.
  /// {@endtemplate}
  RangeLike<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper);

  /// Returns this with every bound value cast to [D].
  ///
  /// {@macro deranged.RangeLike.boundsNaming}
  RangeLike<D> castBounds<D extends Comparable<D>>();
}
