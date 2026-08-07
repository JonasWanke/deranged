import 'dart:math';

import '../deranged.dart';

// IntRangeFull

/// An unbounded range of [int].
class IntRangeFull extends RangeFull<num> {
  const IntRangeFull();

  @override
  RangeFull<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(int) mapper,
  ) => const RangeFull();

  @override
  bool contains(Object? value) => value is int;

  @override
  String toString() => 'IntRangeFull(..)';
}

// IntRange

/// A half-open range of [int]: start is included, end is excluded.
///
/// [int] is discrete, so half-open and closed ranges can represent the same
/// values. This class is the canonical form: [length] is `end - start`, empty
/// ranges are always representable, and adjacent ranges tile without gaps.
/// To create one from an inclusive end, use [IntRange.inclusive].
class IntRange extends Range<num> with Iterable<int> {
  const IntRange(int super.start, int super.end);

  /// Creates a range from [start] (inclusive) to [endInclusive] (inclusive).
  ///
  /// Note that the resulting range stores an exclusive end of
  /// `endInclusive + 1`, which overflows if [endInclusive] is the maximum [int]
  /// value.
  const IntRange.inclusive(int start, int endInclusive)
    : this(start, endInclusive + 1);

  @override
  int get start => super.start as int;
  @override
  int get end => super.end as int;
  int get endInclusive => end - 1;

  /// Returns an [IntProgression] with this range's [start] and [endInclusive],
  /// as well as the given [step].
  IntProgression stepBy(int step) => IntProgression(start, endInclusive, step);

  @override
  Iterator<int> get iterator =>
      Iterable.generate(length, (i) => start + i).iterator;
  @override
  int get length => max(0, end - start);
  @override
  int get last => isEmpty ? throw StateError('No element') : endInclusive;
  @override
  int elementAt(int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(
        index,
        length,
        indexable: this,
        name: 'index',
      );
    }
    return start + index;
  }

  int operator [](int index) => elementAt(index);

  /// Returns this range with both bounds moved by [offset].
  IntRange shift(int offset) => IntRange(start + offset, end + offset);

  @override
  IntRange copyWith({covariant int? start, covariant int? end}) =>
      IntRange(start ?? this.start, end ?? this.end);

  @override
  Range<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(int) mapper,
  ) => Range(mapper(start), mapper(end));

  @override
  bool contains(Object? element) =>
      element is int && start <= element && element < end;

  @override
  String toString() => 'IntRange($start..<$end)';
}

/// Encodes an [IntRange] as a map with "start" and "end" keys.
class IntRangeAsMapCodec extends StartEndAsMapCodec<IntRange, int> {
  const IntRangeAsMapCodec() : super(null);

  @override
  (int, int) startAndEndOf(IntRange range) => (range.start, range.end);
  @override
  IntRange create(int start, int end) => IntRange(start, end);
}

// IntRangeFrom

/// A range of [int] starting from an inclusive bound and without an end bound.
class IntRangeFrom extends RangeFrom<num> with Iterable<int> {
  const IntRangeFrom(int super.start);

  @override
  int get start => super.start as int;

  @override
  Iterator<int> get iterator => _IntRangeFromIterator(this);

  /// Always throws, since this range is infinite.
  @override
  Never get length =>
      throw UnsupportedError('`IntRangeFrom` is infinite and has no length.');

  @override
  int elementAt(int index) {
    if (index < 0) throw RangeError.range(index, 0, null, 'index');
    return start + index;
  }

  int operator [](int index) => elementAt(index);

  /// Returns this range with its start moved by [offset].
  IntRangeFrom shift(int offset) => IntRangeFrom(start + offset);

  @override
  RangeFrom<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(int) mapper,
  ) => RangeFrom(mapper(start));

  @override
  bool contains(Object? element) => element is int && start <= element;

  @override
  String toString() => 'IntRangeFrom($start..)';
}

/// Encodes an [IntRangeFrom] as a map with a "start" key.
class IntRangeFromAsMapCodec
    extends SingleBoundAsMapCodec<IntRangeFrom, int> {
  const IntRangeFromAsMapCodec() : super(null);

  @override
  String get key => 'start';
  @override
  int valueOf(IntRangeFrom range) => range.start;
  @override
  IntRangeFrom create(int value) => IntRangeFrom(value);
}

class _IntRangeFromIterator implements Iterator<int> {
  _IntRangeFromIterator(IntRangeFrom range) : _current = range.start - 1;

  int _current;
  @override
  int get current => _current;

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() {
    _current++;
    return true;
  }
}

// IntRangeUntil

/// A range of [int] ending with an exclusive bound and without a start bound.
class IntRangeUntil extends RangeUntil<num> {
  const IntRangeUntil(int super.end);

  int get endInclusive => end - 1;
  @override
  int get end => super.end as int;

  /// Returns this range with its end moved by [offset].
  IntRangeUntil shift(int offset) => IntRangeUntil(end + offset);

  @override
  RangeUntil<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(int) mapper,
  ) => RangeUntil(mapper(end));

  @override
  bool contains(Object? value) => value is int && value < end;

  @override
  String toString() => 'IntRangeUntil(..<$end)';
}

/// Encodes an [IntRangeUntil] as a map with an "end" key.
class IntRangeUntilAsMapCodec
    extends SingleBoundAsMapCodec<IntRangeUntil, int> {
  const IntRangeUntilAsMapCodec() : super(null);

  @override
  String get key => 'end';
  @override
  int valueOf(IntRangeUntil range) => range.end;
  @override
  IntRangeUntil create(int value) => IntRangeUntil(value);
}

extension IntExtension on int {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  IntRange rangeUntil(int other) => IntRange(this, other);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  IntRange rangeTo(int other) => IntRange.inclusive(this, other);

  /// Creates a range from `this` (inclusive) to `this + length` (exclusive),
  /// containing [length] values.
  ///
  /// See [StepExtension.rangeUntilWithLength] for why there's no
  /// inclusive-end counterpart.
  IntRange rangeUntilWithLength(int length) => IntRange(this, this + length);
}

// IntProgression

/// A [Progression] of [int] values, defined by a [start], [endInclusive], and
/// [step].
///
/// {@macro deranged.Progression.empty}
///
/// See also:
///
/// - [Progression], the base class for progressions.
/// - [StepProgression], a progression of values that implement [Step].
class IntProgression extends Progression<int> {
  const IntProgression(super.start, super.endInclusive, super.step)
    : assert(step != 0);

  /// Returns an [IntProgression] with this progression's [start] and
  /// [endInclusive], as well as the given [step].
  IntProgression stepBy(int step) => IntProgression(start, endInclusive, step);

  @override
  Iterator<int> get iterator =>
      Iterable.generate(length, (i) => start + i * step).iterator;
  @override
  int get length => max(0, (endInclusive + step - start) ~/ step);
  @override
  int get last {
    if (isEmpty) throw StateError('No element');

    return step > 0
        ? endInclusive - (endInclusive - start) % step
        : endInclusive + (start - endInclusive) % -step;
  }

  @override
  int elementAt(int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(
        index,
        length,
        indexable: this,
        name: 'index',
      );
    }
    return start + index * step;
  }

  @override
  bool contains(Object? element) {
    if (element is! int) return false;
    if (step > 0 && (element < start || element > endInclusive)) return false;
    if (step < 0 && (element < endInclusive || element > start)) return false;
    return (element - start) % step == 0;
  }

  @override
  String toString() => 'IntProgression($start..=$endInclusive stepBy $step)';
}

/// Encodes an [IntProgression] as a map with "start", "endInclusive", and
/// "step" keys.
class IntProgressionAsMapCodec
    extends ProgressionAsMapCodec<IntProgression, int> {
  const IntProgressionAsMapCodec() : super(null);

  @override
  (int, int, int) partsOf(IntProgression progression) =>
      (progression.start, progression.endInclusive, progression.step);
  @override
  IntProgression create(int start, int endInclusive, int step) =>
      IntProgression(start, endInclusive, step);
}
