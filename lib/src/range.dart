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

  /// Map the values of both bounds using [mapper].
  RangeBounds<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      AnyRange(startBound.map(mapper), endBound.map(mapper));

  /// Cast the values of both bounds to [D].
  RangeBounds<D> cast<D extends Comparable<D>>() =>
      AnyRange(startBound.cast(), endBound.cast());

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
  final Bound<C> startBound;
  @override
  final Bound<C> endBound;

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
  RangeFull<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeFull();
  @override
  RangeFull<D> cast<D extends Comparable<D>>() => RangeFull();

  @override
  String toString() => 'RangeFull(..)';
}

/// A half-open range: start is included, end is excluded.
///
/// If [C] implements [Step], you can:
///
/// - iterate through the range using the [RangeOfStepExtension.iter] extension
///   getter
/// - convert this range to a [RangeInclusive] (with an inclusive end bound)
///  using the [RangeOfStepExtension.inclusive] extension getter
class Range<C extends Comparable<C>> extends RangeBounds<C> {
  const Range(this.start, this.end);

  final C start;
  final C end;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  ExclusiveBound<C> get endBound => ExclusiveBound(end);

  @override
  Range<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      Range(mapper(start), mapper(end));
  @override
  Range<D> cast<D extends Comparable<D>>() => Range(start as D, end as D);

  @override
  String toString() => 'Range($start..$end)';
}

extension RangeOfStepExtension<T extends Step<T>> on Range<T> {
  /// Returns a [RangeInclusive] representing a range with the same values.
  RangeInclusive<T> get inclusive => RangeInclusive(start, end.stepBy(-1));

  /// Returns a [StepProgression] with this range's [start] and [end],
  /// as well as the given [step].
  StepProgression<T> stepBy(int step) =>
      StepProgression(start, end.stepBy(-1), step);

  /// Returns an [Iterable] that steps through every value of this range in
  /// ascending order.
  Iterable<T> get iter => stepBy(1);

  /// Returns the length of this range, i.e., how many steps it contains.
  ///
  /// For example, the length of a [Range] from 0 to 2 is 2 because it contains
  /// the two elements 0 and 1.
  int get length => start.stepsUntil(end);
}

/// A closed range: both start and end are included.
///
/// If [C] implements [Step], you can:
///
/// - iterate through the range using the [RangeInclusiveOfStepExtension.iter]
///   extension getter
/// - convert this range to a [Range] (with an exclusive end bound) using the
///  [RangeInclusiveOfStepExtension.exclusive] extension getter
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
  RangeInclusive<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeInclusive(mapper(start), mapper(endInclusive));
  @override
  RangeInclusive<D> cast<D extends Comparable<D>>() =>
      RangeInclusive(start as D, endInclusive as D);

  @override
  String toString() => 'RangeInclusive($start..=$endInclusive)';
}

extension RangeInclusiveOfStepExtension<T extends Step<T>>
    on RangeInclusive<T> {
  /// Returns a [Range] representing a range with the same values.
  Range<T> get exclusive => Range(start, endInclusive.stepBy(1));

  /// Returns a [StepProgression] with this range's [start] and [endInclusive],
  /// as well as the given [step].
  StepProgression<T> stepBy(int step) =>
      StepProgression(start, endInclusive, step);

  /// Returns an [Iterable] that steps through every value of this range in
  /// ascending order.
  Iterable<T> get iter => stepBy(1);

  /// Returns the length of this range, i.e., how many steps it contains.
  ///
  /// For example, the length of a [RangeInclusive] from 0 to 2 is 3 because it
  /// contains the three elements 0, 1, and 2.
  int get length => start.stepsUntil(endInclusive) + 1;
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
  RangeFrom<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeFrom(mapper(start));
  @override
  RangeFrom<D> cast<D extends Comparable<D>>() => RangeFrom(start as D);

  @override
  String toString() => 'RangeFrom($start..)';
}

extension RangeFromOfStepExtension<T extends Step<T>> on RangeFrom<T> {
  /// Returns an [Iterable] that steps through every value of this range in
  /// ascending order.
  Iterable<T> get iter => const IntRangeFrom(0).map(start.stepBy);
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
  RangeTo<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeTo(mapper(end));
  @override
  RangeTo<D> cast<D extends Comparable<D>>() => RangeTo(end as D);

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
  RangeToInclusive<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeToInclusive(mapper(endInclusive));
  @override
  RangeToInclusive<D> cast<D extends Comparable<D>>() =>
      RangeToInclusive(endInclusive as D);

  @override
  String toString() => 'RangeToInclusive(..=$endInclusive)';
}

extension ComparableExtension<C extends Comparable<C>> on C {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  Range<C> rangeUntil(C other) => Range(this, other);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  RangeInclusive<C> rangeTo(C other) => RangeInclusive(this, other);
}
