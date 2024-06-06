import 'range.dart';

// TODO(JonasWanke): `IntRangeBounds`?

class IntRangeFull extends RangeFull<num> {
  const IntRangeFull();

  @override
  bool contains(Object? value) => value is int;

  @override
  String toString() => 'IntRangeFull()';
}

class IntRange extends Range<num> with Iterable<int> {
  const IntRange(super.start, super.end);

  @override
  int get start => super.start as int;
  @override
  int get end => super.end as int;

  @override
  Iterator<int> get iterator =>
      Iterable.generate(length, (i) => start + i).iterator;
  @override
  int get length => end - start;
  @override
  int get last => end;
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
      element is int && start <= element && element < end;

  @override
  String toString() => 'IntRange($start ≤ value < $end)';
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
  IntRange rangeUntil(int other) => IntRange(this, other);
  IntRange rangeTo(int other) => IntRange(this, other + 1);
}
