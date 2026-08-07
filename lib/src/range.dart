import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../deranged.dart';
import 'codec.dart';
import 'utils.dart';

// RangeBounds

/// Base class for [Range] & co., providing common methods.
///
/// Names follow one convention: **`until` means an exclusive end, `to` means an
/// inclusive end** — in class names ([RangeUntil] vs. [RangeTo]) as well as in
/// method names ([ComparableExtension.rangeUntil] vs.
/// [ComparableExtension.rangeTo]).
///
/// Here's an overview of the different subclasses:
///
// ignore: lines_longer_than_80_chars
/// | Start Bound | End Bound | Generic          | For [int]            | For [double]           |
// ignore: lines_longer_than_80_chars
/// | :---------- | :-------- | :--------------- | :------------------- | :--------------------- |
// ignore: lines_longer_than_80_chars
/// | Inclusive   | Inclusive | [RangeInclusive] | [IntRange.inclusive] | [DoubleRangeInclusive] |
// ignore: lines_longer_than_80_chars
/// | Inclusive   | Exclusive | [Range]          | [IntRange]           | [DoubleRange]          |
// ignore: lines_longer_than_80_chars
/// | Inclusive   | Unbounded | [RangeFrom]      | [IntRangeFrom]       | [DoubleRangeFrom]      |
// ignore: lines_longer_than_80_chars
/// | Exclusive   | Inclusive | —                | —                    | —                      |
// ignore: lines_longer_than_80_chars
/// | Exclusive   | Exclusive | —                | —                    | —                      |
// ignore: lines_longer_than_80_chars
/// | Exclusive   | Unbounded | —                | —                    | —                      |
// ignore: lines_longer_than_80_chars
/// | Unbounded   | Inclusive | [RangeTo]        | —                    | [DoubleRangeTo]        |
// ignore: lines_longer_than_80_chars
/// | Unbounded   | Exclusive | [RangeUntil]     | [IntRangeUntil]      | [DoubleRangeUntil]     |
// ignore: lines_longer_than_80_chars
/// | Unbounded   | Unbounded | [RangeFull]      | [IntRangeFull]       | [DoubleRangeFull]      |
///
/// [int] is discrete, so a bounded inclusive-end range is a constructor on the
/// half-open [IntRange] rather than a separate class – see
/// [IntRange.inclusive]. There is no unbounded-start inclusive-end [int] class;
/// write `IntRangeUntil(end + 1)` instead.
@immutable
abstract class RangeBounds<C extends Comparable<C>> {
  const RangeBounds();

  const factory RangeBounds.full() = RangeFull;
  factory RangeBounds.inclusiveOrUnbounded(C? start, C? end) =>
      AnyRange.inclusiveOrUnbounded(start, end);
  factory RangeBounds.exclusiveOrUnbounded(C? start, C? end) =>
      AnyRange.exclusiveOrUnbounded(start, end);
  const factory RangeBounds.from(C start) = RangeFrom;
  const factory RangeBounds.until(C end) = RangeUntil;
  const factory RangeBounds.to(C end) = RangeTo;

  /// The start bound of this range.
  Bound<C> get startBound;

  /// The end bound of this range.
  Bound<C> get endBound;

  /// Returns whether this range is empty, i.e., contains no values.
  bool get isEmpty {
    return switch ((startBound, endBound)) {
      (UnboundedBound(), _) || (_, UnboundedBound()) => false,
      (InclusiveBound(value: final start), InclusiveBound(value: final end)) =>
        start.compareTo(end) > 0,
      (
        InclusiveBound(value: final start) ||
            ExclusiveBound(value: final start),
        InclusiveBound(value: final end) || ExclusiveBound(value: final end),
      ) =>
        start.compareTo(end) >= 0,
    };
  }

  /// Returns whether this range is not empty, i.e., contains at least one
  /// value.
  bool get isNotEmpty => !isEmpty;

  /// Returns whether this range is unbounded, i.e., has no start or end bound.
  bool get isUnbounded =>
      startBound is UnboundedBound && endBound is UnboundedBound;

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
        ExclusiveBound(
          value: final otherStart,
        ) => thisStart.compareTo(otherStart) <= 0,
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
        ExclusiveBound(
          value: final otherEnd,
        ) => thisEnd.compareTo(otherEnd) >= 0,
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
        ExclusiveBound(
          value: final otherEnd,
        ) => thisStart.compareTo(otherEnd) < 0,
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
        ExclusiveBound(
          value: final otherStart,
        ) => thisEnd.compareTo(otherStart) > 0,
        UnboundedBound() => true,
      },
      UnboundedBound() => true,
    };
    return startMatches && endMatches;
  }

  AnyRange<C> copyWithBounds({Bound<C>? startBound, Bound<C>? endBound}) =>
      AnyRange(startBound ?? this.startBound, endBound ?? this.endBound);

  /// Returns a range of the same shape with every bound value mapped using
  /// [mapper].
  ///
  /// [mapper] must be monotonically increasing, i.e., preserve the order of
  /// values. Otherwise, the resulting range's bounds end up swapped.
  ///
  /// This is not called `map` because [IntRange] & co. also implement
  /// [Iterable], whose [Iterable.map] maps the range's *elements* rather than
  /// its bounds.
  RangeBounds<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper);

  /// Returns a range of the same shape with every bound value cast to [D].
  ///
  /// This is not called `cast` because [IntRange] & co. also implement
  /// [Iterable], whose [Iterable.cast] casts the range's *elements* rather than
  /// its bounds.
  RangeBounds<D> castBounds<D extends Comparable<D>>();

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

extension RangeBoundsOfStepExtension<T extends Step<T>> on RangeBounds<T> {
  /// Returns the inclusive start of this range, or `null` if this range has no
  /// bounded start.
  ///
  /// An exclusive bound is converted to an inclusive bound.
  T? get startInclusive => switch (startBound) {
    InclusiveBound(value: final value) => value,
    ExclusiveBound(value: final value) => value.stepBy(1),
    UnboundedBound() => null,
  };

  /// Returns the exclusive start of this range, or `null` if this range has no
  /// bounded start.
  ///
  /// An inclusive bound is converted to an exclusive bound.
  T? get startExclusive => switch (startBound) {
    InclusiveBound(value: final value) => value.stepBy(-1),
    ExclusiveBound(value: final value) => value,
    UnboundedBound() => null,
  };

  /// Returns the inclusive end of this range, or `null` if this range has no
  /// bounded end.
  ///
  /// An exclusive bound is converted to an inclusive bound.
  T? get endInclusive => switch (endBound) {
    InclusiveBound(value: final value) => value,
    ExclusiveBound(value: final value) => value.stepBy(-1),
    UnboundedBound() => null,
  };

  /// Returns the exclusive end of this range, or `null` if this range has no
  /// bounded end.
  ///
  /// An inclusive bound is converted to an exclusive bound.
  T? get endExclusive => switch (endBound) {
    InclusiveBound(value: final value) => value.stepBy(1),
    ExclusiveBound(value: final value) => value,
    UnboundedBound() => null,
  };

  AnyRange<T> operator &(RangeBounds<T> other) => AnyRange(
    .maxLower(startBound, other.startBound),
    .minUpper(endBound, other.endBound),
  );
}

// AnyRange

/// A range supporting all possible [Bound]s.
class AnyRange<C extends Comparable<C>> extends RangeBounds<C> {
  const AnyRange(this.startBound, this.endBound);

  AnyRange.inclusiveOrUnbounded(C? start, C? end)
    : startBound = .inclusiveOrUnbounded(start),
      endBound = .inclusiveOrUnbounded(end);
  AnyRange.exclusiveOrUnbounded(C? start, C? end)
    : startBound = .exclusiveOrUnbounded(start),
      endBound = .exclusiveOrUnbounded(end);

  @override
  final Bound<C> startBound;
  @override
  final Bound<C> endBound;

  @override
  AnyRange<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      AnyRange(startBound.map(mapper), endBound.map(mapper));
  @override
  AnyRange<D> castBounds<D extends Comparable<D>>() =>
      AnyRange(startBound.cast(), endBound.cast());

  @override
  String toString() => 'AnyRange($startBound, $endBound)';
}

/// Encodes an [AnyRange] as a map with "start" and "end" keys, each holding an
/// encoded [Bound].
///
/// Unlike the other range codecs, this one round-trips the *kind* of each bound
/// as well as its value, so it can represent every range shape.
class AnyRangeAsMapCodec<C extends Comparable<C>>
    extends AsMapCodec<AnyRange<C>, C> {
  const AnyRangeAsMapCodec([super.innerCodec]);

  /// Codec used for the [AnyRange.startBound] and [AnyRange.endBound].
  BoundAsMapCodec<C> get boundCodec => BoundAsMapCodec(innerCodec);

  @override
  Map<String, dynamic> encode(AnyRange<C> input) {
    final boundCodec = this.boundCodec;
    return {
      'start': boundCodec.encode(input.startBound),
      'end': boundCodec.encode(input.endBound),
    };
  }

  @override
  AnyRange<C> decode(Map<String, dynamic> encoded) {
    final boundCodec = this.boundCodec;
    return AnyRange(
      boundCodec.decode(Map.from(encoded['start'] as Map)),
      boundCodec.decode(Map.from(encoded['end'] as Map)),
    );
  }
}

// RangeFull

/// An unbounded range.
class RangeFull<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeFull();

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  UnboundedBound<C> get endBound => const UnboundedBound();

  @override
  RangeFull<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      const RangeFull();
  @override
  RangeFull<D> castBounds<D extends Comparable<D>>() => const RangeFull();

  @override
  String toString() => 'RangeFull(..)';
}

// Range

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

  Range<C> copyWith({covariant C? start, covariant C? end}) =>
      Range(start ?? this.start, end ?? this.end);

  @override
  Range<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      Range(mapper(start), mapper(end));
  @override
  Range<D> castBounds<D extends Comparable<D>>() => Range(start as D, end as D);

  @override
  String toString() => 'Range($start..<$end)';
}

extension RangeOfStepExtension<T extends Step<T>> on Range<T> {
  T? get endInclusive => end.stepBy(-1);

  /// Returns a [RangeInclusive] representing a range with the same values, or
  /// `null` if that is not possible.
  ///
  /// When [endInclusive] is `null`, [end] is the smallest possible value, so
  /// this range is empty. An empty [RangeInclusive] requires a start greater
  /// than its end, which can't be expressed here, so `null` is returned.
  RangeInclusive<T>? get inclusive {
    final endInclusive = this.endInclusive;
    return endInclusive == null ? null : RangeInclusive(start, endInclusive);
  }

  /// Returns a [StepProgression] with this range's [start] and [end],
  /// as well as the given [step].
  StepProgression<T>? stepBy(int step) {
    final endInclusive = this.endInclusive;
    return endInclusive == null
        ? null
        : StepProgression(start, endInclusive, step);
  }

  /// Returns an [Iterable] that steps through every value of this range in
  /// ascending order.
  Iterable<T>? get iter => stepBy(1);

  /// Returns the length of this range, i.e., how many steps it contains.
  ///
  /// For example, the length of a [Range] from 0 to 2 is 2 because it contains
  /// the two elements 0 and 1.
  ///
  /// Empty ranges have a length of zero.
  int get length => math.max(0, start.stepsUntil(end));

  StepProgression<T>? get reverse {
    final endInclusive = this.endInclusive;
    return endInclusive == null
        ? null
        : StepProgression(endInclusive, start, -1);
  }

  T operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(
        index,
        length,
        indexable: this,
        name: 'index',
      );
    }
    return start.stepBy(index)!;
  }
}

extension RangeOfStepUnlimitedExtension<T extends StepUnlimited<T>>
    on Range<T> {
  T get endInclusive => end.stepBy(-1);

  /// Returns a [RangeInclusive] representing a range with the same values.
  RangeInclusive<T> get inclusive => RangeInclusive(start, endInclusive);

  /// Returns a [StepProgression] with this range's [start] and [end],
  /// as well as the given [step].
  StepProgression<T> stepBy(int step) =>
      StepProgression(start, endInclusive, step);

  /// Returns an [Iterable] that steps through every value of this range in
  /// ascending order.
  Iterable<T> get iter => stepBy(1);

  StepProgression<T> get reverse => StepProgression(endInclusive, start, -1);
}

/// Encodes a [Range] as a map with "start" and "end" keys.
class RangeAsMapCodec<C extends Comparable<C>>
    extends StartEndAsMapCodec<Range<C>, C> {
  const RangeAsMapCodec([super.innerCodec]);

  @override
  (C, C) startAndEndOf(Range<C> range) => (range.start, range.end);
  @override
  Range<C> create(C start, C end) => Range(start, end);
}

// RangeInclusive

/// A closed range: both start and end are included.
///
/// If [C] implements [Step], you can:
///
/// - iterate through the range using the [RangeInclusiveOfStepExtension.iter]
///   extension getter
/// - convert this range to a [Range] (with an exclusive end bound) using the
///  [RangeInclusiveOfStepExtension.exclusive] extension getter
class RangeInclusive<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeInclusive(this.start, this.end);
  const RangeInclusive.single(C value) : start = value, end = value;

  final C start;
  final C end;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  InclusiveBound<C> get endBound => InclusiveBound(end);

  /// Returns whether this range contains only a single value, i.e., its start
  /// and end are equal.
  bool get isSingle => start == end;

  RangeInclusive<C> copyWith({covariant C? start, covariant C? end}) =>
      RangeInclusive(start ?? this.start, end ?? this.end);

  @override
  RangeInclusive<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeInclusive(mapper(start), mapper(end));
  @override
  RangeInclusive<D> castBounds<D extends Comparable<D>>() =>
      RangeInclusive(start as D, end as D);

  /// Union of this and [other], i.e., the smallest range containing all values
  /// of both ranges.
  ///
  /// For example, the union of the ranges 0..=2 and 1..=3 is the range 0..=3.
  ///
  /// Note that this method does not check whether the two ranges actually
  /// intersect. For example, the union of the ranges 0..=2 and 4..=6 is the
  /// range 0..=6, even though the two ranges have no values in common.
  RangeInclusive<C> operator |(RangeInclusive<C>? other) {
    return other == null
        ? this
        : RangeInclusive(min(start, other.start), max(end, other.end));
  }

  /// Intersection of this and [other], i.e., the largest range containing only
  /// values of both ranges.
  ///
  /// For example, the intersection of the ranges 0..=2 and 1..=3 is the range
  /// 1..=2.
  ///
  /// If the two ranges have no values in common, `null` is returned. For
  /// example, the intersection of the ranges 0..=2 and 3..=5 is `null`.
  RangeInclusive<C>? operator &(RangeInclusive<C>? other) {
    if (other == null) return null;

    final result = RangeInclusive(max(start, other.start), min(end, other.end));
    if (result.isEmpty) return null;
    return result;
  }

  @override
  String toString() => 'RangeInclusive($start..=$end)';
}

extension RangeInclusiveOfStepExtension<T extends Step<T>>
    on RangeInclusive<T> {
  T? get endExclusive => end.stepBy(1);

  /// Returns a [Range] representing a range with the same values.
  Range<T>? get exclusive {
    final endExclusive = this.endExclusive;
    return endExclusive == null ? null : Range(start, endExclusive);
  }

  /// Returns a [StepProgression] with this range's [start] and [end],
  /// as well as the given [step].
  StepProgression<T> stepBy(int step) => StepProgression(start, end, step);

  /// Returns an [Iterable] that steps through every value of this range in
  /// ascending order.
  Iterable<T> get iter => stepBy(1);

  /// Returns the length of this range, i.e., how many steps it contains.
  ///
  /// For example, the length of a [RangeInclusive] from 0 to 2 is 3 because it
  /// contains the three elements 0, 1, and 2.
  ///
  /// Empty ranges have a length of zero.
  int get length => math.max(0, start.stepsUntil(end) + 1);

  StepProgression<T> get reverse => StepProgression(end, start, -1);

  T operator [](int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(
        index,
        length,
        indexable: this,
        name: 'index',
      );
    }
    return start.stepBy(index)!;
  }

  /// Generalization of [&] accepting any [RangeBounds] as the other range.
  RangeInclusive<T> intersectRangeBounds(RangeBounds<T>? other) {
    if (other == null) return this;

    final T start;
    switch (other.startBound) {
      case InclusiveBound(value: final otherStart):
        start = max(this.start, otherStart);

      case ExclusiveBound(value: final otherStart):
        final otherNext = otherStart.next;
        if (otherNext == null) return RangeInclusive(otherStart, otherStart);

        start = max(this.start, otherNext);

      case UnboundedBound():
        start = this.start;
    }

    final T end;
    switch (other.endBound) {
      case InclusiveBound(value: final otherEnd):
        end = min(this.end, otherEnd);

      case ExclusiveBound(value: final otherEnd):
        final otherPrevious = otherEnd.previous;
        if (otherPrevious == null) return RangeInclusive(otherEnd, otherEnd);

        end = min(this.end, otherPrevious);

      case UnboundedBound():
        end = this.end;
    }

    return RangeInclusive(start, end);
  }
}

extension RangeInclusiveOfStepUnlimitedExtension<T extends StepUnlimited<T>>
    on RangeInclusive<T> {
  T get endExclusive => end.stepBy(1);

  /// Returns a [Range] representing a range with the same values.
  Range<T> get exclusive => Range(start, endExclusive);
}

extension IterableOfRangeInclusiveExtension<C extends Comparable<C>>
    on Iterable<RangeInclusive<C>> {
  /// The union of all contained [RangeInclusive]s.
  ///
  /// See [RangeInclusive.|] for details.
  RangeInclusive<C>? get union => fold(
    null,
    (previousValue, element) =>
        previousValue == null ? element : previousValue | element,
  );

  /// The intersection of all contained [RangeInclusive]s.
  ///
  /// See [RangeInclusive.&] for details.
  RangeInclusive<C>? get intersection {
    var result = firstOrNull;
    if (result == null) return null;

    for (final range in skip(1)) {
      result = result! & range;
      if (result == null) return null;
    }
    return result;
  }
}

/// Encodes a [RangeInclusive] as a map with "start" and "end" keys.
class RangeInclusiveAsMapCodec<C extends Comparable<C>>
    extends StartEndAsMapCodec<RangeInclusive<C>, C> {
  const RangeInclusiveAsMapCodec([super.innerCodec]);

  @override
  (C, C) startAndEndOf(RangeInclusive<C> range) => (range.start, range.end);
  @override
  RangeInclusive<C> create(C start, C end) => RangeInclusive(start, end);
}

// RangeFrom

/// A range starting from an inclusive bound and without an end bound.
class RangeFrom<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeFrom(this.start);

  final C start;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  UnboundedBound<C> get endBound => const UnboundedBound();

  @override
  RangeFrom<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeFrom(mapper(start));
  @override
  RangeFrom<D> castBounds<D extends Comparable<D>>() => RangeFrom(start as D);

  @override
  String toString() => 'RangeFrom($start..)';
}

extension RangeFromOfStepExtension<T extends Step<T>> on RangeFrom<T> {
  /// Returns an [Iterable] that steps through every value of this range in
  /// ascending order.
  Iterable<T> get iter sync* {
    var value = start;
    while (true) {
      yield value;
      final nextValue = value.stepBy(1);
      if (nextValue == null) break;

      value = nextValue;
    }
  }

  T operator [](int index) {
    final result = start.stepBy(index);
    // ignore: deprecated_member_use
    if (result == null) throw IndexError(index, this, 'index');
    return result;
  }
}

/// Encodes a [RangeFrom] as a map with a "start" key.
class RangeFromAsMapCodec<C extends Comparable<C>>
    extends SingleBoundAsMapCodec<RangeFrom<C>, C> {
  const RangeFromAsMapCodec([super.innerCodec]);

  @override
  String get key => 'start';
  @override
  C valueOf(RangeFrom<C> range) => range.start;
  @override
  RangeFrom<C> create(C value) => RangeFrom(value);
}

// RangeUntil

/// A range ending with an exclusive bound and without a start bound.
class RangeUntil<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeUntil(this.end);

  final C end;

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  ExclusiveBound<C> get endBound => ExclusiveBound(end);

  @override
  RangeUntil<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeUntil(mapper(end));
  @override
  RangeUntil<D> castBounds<D extends Comparable<D>>() => RangeUntil(end as D);

  @override
  String toString() => 'RangeUntil(..<$end)';
}

/// Encodes a [RangeUntil] as a map with an "end" key.
class RangeUntilAsMapCodec<C extends Comparable<C>>
    extends SingleBoundAsMapCodec<RangeUntil<C>, C> {
  const RangeUntilAsMapCodec([super.innerCodec]);

  @override
  String get key => 'end';
  @override
  C valueOf(RangeUntil<C> range) => range.end;
  @override
  RangeUntil<C> create(C value) => RangeUntil(value);
}

// RangeTo

/// A range ending with an inclusive bound and without a start bound.
class RangeTo<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeTo(this.end);

  final C end;

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  InclusiveBound<C> get endBound => InclusiveBound(end);

  @override
  RangeTo<D> mapBounds<D extends Comparable<D>>(D Function(C) mapper) =>
      RangeTo(mapper(end));
  @override
  RangeTo<D> castBounds<D extends Comparable<D>>() => RangeTo(end as D);

  @override
  String toString() => 'RangeTo(..=$end)';
}

/// Encodes a [RangeTo] as a map with an "end" key.
class RangeToAsMapCodec<C extends Comparable<C>>
    extends SingleBoundAsMapCodec<RangeTo<C>, C> {
  const RangeToAsMapCodec([super.innerCodec]);

  @override
  String get key => 'end';
  @override
  C valueOf(RangeTo<C> range) => range.end;
  @override
  RangeTo<C> create(C value) => RangeTo(value);
}

// Utils

extension ComparableExtension<C extends Comparable<C>> on C {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  Range<C> rangeUntil(C other) => Range(this, other);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  RangeInclusive<C> rangeTo(C other) => RangeInclusive(this, other);
}
