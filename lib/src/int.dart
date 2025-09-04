import 'dart:math';

import 'progression.dart';
import 'range.dart';

/// An unbounded range of [int].
class IntRangeFull extends RangeFull<num> {
  const IntRangeFull();

  @override
  bool contains(Object? value) => value is int;

  @override
  String toString() => 'IntRangeFull(..)';
}

// A closed range of [int]: both start and end are included.
class IntRange extends RangeInclusive<num>
    with Iterable<int>
    implements IntProgression {
  const IntRange(super.start, super.endInclusive);

  @override
  int get start => super.start as int;
  @override
  int get endInclusive => super.endInclusive as int;
  int get endExclusive => endInclusive + 1;
  @override
  int get step => 1;

  /// Returns an [IntProgression] with this range's [start] and [endInclusive],
  /// as well as the given [step].
  IntProgression stepBy(int step) => IntProgression(start, endInclusive, step);

  @override
  Iterator<int> get iterator =>
      Iterable.generate(length, (i) => start + i).iterator;
  @override
  int get length => endExclusive - start;
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

  @override
  bool contains(Object? element) =>
      element is int && start <= element && element <= endInclusive;

  @override
  String toString() => 'IntRange($start..=$endInclusive)';
}

/// A range of [int] starting from an inclusive bound and without an end bound.
class IntRangeFrom extends RangeFrom<num> with Iterable<int> {
  const IntRangeFrom(super.start);

  @override
  int get start => super.start as int;

  @override
  RangeFrom<D> map<D extends Comparable<D>>(D Function(int) mapper) =>
      RangeFrom(mapper(start));
  @override
  RangeFrom<D> cast<D extends Comparable<D>>() => RangeFrom(start as D);

  @override
  Iterator<int> get iterator => _IntRangeFromIterator(this);
  @override
  int elementAt(int index) {
    if (index < 0) {
      throw IndexError.withLength(
        index,
        length,
        indexable: this,
        name: 'index',
      );
    }
    return start + index;
  }

  @override
  bool contains(Object? element) => element is int && start <= element;

  @override
  String toString() => 'IntRangeFrom($start..)';
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

/// A range of [int] ending with an inclusive bound and without a start bound.
class IntRangeTo extends RangeToInclusive<num> {
  const IntRangeTo(super.endInclusive);

  int get endExclusive => endInclusive - 1;
  @override
  int get endInclusive => super.endInclusive as int;

  @override
  bool contains(Object? value) => value is int && value <= endInclusive;

  @override
  String toString() => 'IntRangeTo(..=$endInclusive)';
}

extension IntExtension on int {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  IntRange rangeUntil(int other) => IntRange(this, other - 1);

  /// Creates a range from `this` (inclusive) to `this + length` (exclusive).
  IntRange rangeUntilWithLength(int length) => IntRange(this, this + length);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  IntRange rangeTo(int other) => IntRange(this, other);

  /// Creates a range from `this` (inclusive) to `this + length` (inclusive).
  IntRange rangeToWithLength(int length) => IntRange(this, this + length);
}

/// A [Progression] of [int] values, defined by a [start], [endInclusive], and
/// [step].
///
/// {@macro deranged.Progression.empty}
///
/// See also:
///
/// - [Progression], the base class for progressions.
/// - [StepProgression], a progression of values that implement [Step].
class IntProgression extends Progression<int> with Iterable<int> {
  const IntProgression(super.start, super.endInclusive, super.step)
      : assert(step != 0);

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
