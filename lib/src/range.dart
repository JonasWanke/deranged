import 'package:meta/meta.dart';

import 'bound.dart';
import 'double.dart';
import 'int.dart';
import 'progression.dart';

/// Base class for [Range] & co., providing common methods.
///
/// Here's an overview of the different subclasses:
///
// ignore: lines_longer_than_80_chars
/// | Start Bound | End Bound | Generic            | For [int]      | For [double]             |
// ignore: lines_longer_than_80_chars
/// | :---------- | :-------- | :----------------- | :------------- | :----------------------- |
// ignore: lines_longer_than_80_chars
/// | Inclusive   | Inclusive | [RangeInclusive]   | [IntRange]     | [DoubleRangeInclusive]   |
// ignore: lines_longer_than_80_chars
/// | Inclusive   | Exclusive | [Range]            | [IntRange]     | [DoubleRange]            |
// ignore: lines_longer_than_80_chars
/// | Inclusive   | Unbounded | [RangeFrom]        | [IntRangeFrom] | [DoubleRangeFrom]        |
// ignore: lines_longer_than_80_chars
/// | Exclusive   | Inclusive | —                  | —              | —                        |
// ignore: lines_longer_than_80_chars
/// | Exclusive   | Exclusive | —                  | —              | —                        |
// ignore: lines_longer_than_80_chars
/// | Exclusive   | Unbounded | —                  | —              | —                        |
// ignore: lines_longer_than_80_chars
/// | Unbounded   | Inclusive | [RangeToInclusive] | [IntRangeTo]   | [DoubleRangeToInclusive] |
// ignore: lines_longer_than_80_chars
/// | Unbounded   | Exclusive | [RangeTo]          | [IntRangeTo]   | [DoubleRangeTo]          |
// ignore: lines_longer_than_80_chars
/// | Unbounded   | Unbounded | [RangeFull]        | [IntRangeFull] | [DoubleRangeFull]        |
@immutable
abstract class RangeBounds<C extends Comparable<C>> {
  const RangeBounds();

  /// The start bound of this range.
  Bound<C> get startBound;

  /// The end bound of this range.
  Bound<C> get endBound;

  /// Returns whether [value] is contained in this range.
  bool contains(C value) {
    final startMatches = switch (startBound) {
      InclusiveBound(value: final start) => start.compareTo(value) <= 0,
      ExclusiveBound(value: final start) => start.compareTo(value) < 0,
      UnboundedBound() => true,
    };
    final endMatches = switch (endBound) {
      InclusiveBound(value: final end) => end.compareTo(value) >= 0,
      ExclusiveBound(value: final end) => end.compareTo(value) > 0,
      UnboundedBound() => true,
    };
    return startMatches && endMatches;
  }

  /// Returns whether this range contains the entire other [range].
  bool containsRange(RangeBounds<C> range) {
    final startMatches = switch (startBound) {
      InclusiveBound(value: final thisStart) => switch (range.startBound) {
          InclusiveBound(value: final otherStart) ||
          ExclusiveBound(value: final otherStart) =>
            thisStart.compareTo(otherStart) <= 0,
          UnboundedBound() => false,
        },
      ExclusiveBound(value: final thisStart) => switch (range.startBound) {
          InclusiveBound(value: final otherStart) =>
            thisStart.compareTo(otherStart) < 0,
          ExclusiveBound(value: final otherStart) =>
            thisStart.compareTo(otherStart) <= 0,
          UnboundedBound() => false,
        },
      UnboundedBound() => true,
    };
    final endMatches = switch (endBound) {
      InclusiveBound(value: final thisEnd) => switch (range.endBound) {
          InclusiveBound(value: final otherEnd) ||
          ExclusiveBound(value: final otherEnd) =>
            thisEnd.compareTo(otherEnd) >= 0,
          UnboundedBound() => false,
        },
      ExclusiveBound(value: final thisEnd) => switch (range.endBound) {
          InclusiveBound(value: final otherEnd) =>
            thisEnd.compareTo(otherEnd) > 0,
          ExclusiveBound(value: final otherEnd) =>
            thisEnd.compareTo(otherEnd) >= 0,
          UnboundedBound() => false,
        },
      UnboundedBound() => true,
    };
    return startMatches && endMatches;
  }

  /// Returns whether this and the other [range] have at least one element in
  /// common.
  bool intersects(RangeBounds<C> range) {
    final startMatches = switch (startBound) {
      InclusiveBound(value: final thisStart) => switch (range.endBound) {
          InclusiveBound(value: final otherEnd) =>
            thisStart.compareTo(otherEnd) <= 0,
          ExclusiveBound(value: final otherEnd) =>
            thisStart.compareTo(otherEnd) < 0,
          UnboundedBound() => true,
        },
      ExclusiveBound(value: final thisStart) => switch (range.endBound) {
          InclusiveBound(value: final otherEnd) ||
          ExclusiveBound(value: final otherEnd) =>
            thisStart.compareTo(otherEnd) < 0,
          UnboundedBound() => true,
        },
      UnboundedBound() => true,
    };
    final endMatches = switch (endBound) {
      InclusiveBound(value: final thisEnd) => switch (range.startBound) {
          InclusiveBound(value: final otherStart) =>
            thisEnd.compareTo(otherStart) >= 0,
          ExclusiveBound(value: final otherStart) =>
            thisEnd.compareTo(otherStart) > 0,
          UnboundedBound() => true,
        },
      ExclusiveBound(value: final thisEnd) => switch (range.startBound) {
          InclusiveBound(value: final otherStart) ||
          ExclusiveBound(value: final otherStart) =>
            thisEnd.compareTo(otherStart) > 0,
          UnboundedBound() => true,
        },
      UnboundedBound() => true,
    };
    return startMatches && endMatches;
  }

  @override
  bool operator ==(Object other) =>
      other is RangeBounds<C> &&
      startBound == other.startBound &&
      endBound == other.endBound;
  @override
  int get hashCode => Object.hash(startBound, endBound);

  @override
  String toString() => 'RangeBounds($startBound, $endBound)';
}

/// A range supporting all possible [Bound]s.
class AnyRange<C extends Comparable<C>> extends RangeBounds<C> {
  const AnyRange(this.startBound, this.endBound);

  @override
  final InclusiveBound<C> startBound;
  @override
  final ExclusiveBound<C> endBound;

  @override
  String toString() => 'AnyRange($startBound, $endBound)';
}

/// An unbounded range.
class RangeFull<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeFull();

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  UnboundedBound<C> get endBound => const UnboundedBound();

  @override
  String toString() => 'RangeFull(..)';
}

/// A half-open range: start is included, end is excluded.
class Range<C extends Comparable<C>> extends RangeBounds<C> {
  const Range(this.start, this.end);

  final C start;
  final C end;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  ExclusiveBound<C> get endBound => ExclusiveBound(end);

  @override
  String toString() => 'Range($start..$end)';
}

/// A closed range: both start and end are included.
class RangeInclusive<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeInclusive(this.start, this.endInclusive);
  const RangeInclusive.single(C value)
      : start = value,
        endInclusive = value;

  final C start;
  final C endInclusive;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  InclusiveBound<C> get endBound => InclusiveBound(endInclusive);

  @override
  String toString() => 'RangeInclusive($start..=$endInclusive)';
}

extension RangeInclusiveOfStepExtension<T extends Step<T>>
    on RangeInclusive<T> {
  /// Returns a [StepProgression] with this range's [start] and [endInclusive],
  /// as well as the given [step].
  StepProgression<T> stepBy(int step) =>
      StepProgression(start, endInclusive, step);
}

/// A range starting from an inclusive bound and without an end bound.
class RangeFrom<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeFrom(this.start);

  final C start;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  UnboundedBound<C> get endBound => const UnboundedBound();

  @override
  String toString() => 'RangeFrom($start..)';
}

/// A range ending with an exclusive bound and without a start bound.
class RangeTo<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeTo(this.end);

  final C end;

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  ExclusiveBound<C> get endBound => ExclusiveBound(end);

  @override
  String toString() => 'RangeTo(..$end)';
}

/// A range ending with an inclusive bound and without a start bound.
class RangeToInclusive<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeToInclusive(this.endInclusive);

  final C endInclusive;

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  InclusiveBound<C> get endBound => InclusiveBound(endInclusive);

  @override
  String toString() => 'RangeToInclusive(..=$endInclusive)';
}

extension ComparableExtension<C extends Comparable<C>> on C {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  Range<C> rangeUntil(C other) => Range(this, other);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  RangeInclusive<C> rangeTo(C other) => RangeInclusive(this, other);
}
