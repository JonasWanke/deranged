import 'dart:math';

import 'range.dart';

// TODO(JonasWanke): `IntRangeBounds`?

class IntRangeFull extends RangeFull<num> {
  const IntRangeFull();

  @override
  bool contains(Object? value) => value is int;

  @override
  String toString() => 'IntRangeFull()';
}

class IntProgression with Iterable<int> {
  const IntProgression(this.start, this.endInclusive, this.step)
      : assert(step != 0);

  final int start;
  final int endInclusive;
  final int step;

  IntProgression stepBy(int step) => IntProgression(start, endInclusive, step);

  @override
  Iterator<int> get iterator =>
      Iterable.generate(length, (i) => start + i * step).iterator;
  @override
  int get length => max(0, (endInclusive + step - start) ~/ step);
  @override
  int get last => isEmpty
      ? throw StateError('No element')
      : step > 0
          ? endInclusive - (endInclusive - start) % step
          : endInclusive + (start - endInclusive) % -step;
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
  String toString() => 'IntProgression($start..$endInclusive step $step)';
}

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

  @override
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
  String toString() => 'IntRange($start ≤ value ≤ $endInclusive)';
}

// TODO(JonasWanke): Handle large numbers?
class IntRangeFrom extends RangeFrom<num> with Iterable<int> {
  const IntRangeFrom(super.start);

  @override
  int get start => super.start as int;

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
  String toString() => 'IntRangeFrom($start ≤ value)';
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

class IntRangeTo extends RangeTo<num> {
  const IntRangeTo(super.end);

  @override
  int get end => super.end as int;

  @override
  bool contains(Object? value) => value is int && value < end;

  @override
  String toString() => 'IntRangeTo(value < $end)';
}

extension CreateIntRangeExtension on int {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  IntRange rangeUntil(int other) => IntRange(this, other - 1);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  IntRange rangeTo(int other) => IntRange(this, other);
}
