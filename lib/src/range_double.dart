import 'range.dart';

class DoubleRangeFull extends RangeFull<num> {
  const DoubleRangeFull();

  @override
  bool contains(Object? value) => value is double;

  @override
  String toString() => 'DoubleRangeFull(..)';
}

class DoubleRange extends Range<num> {
  const DoubleRange(super.start, super.end);

  @override
  double get start => super.start as double;
  @override
  double get end => super.end as double;

  @override
  bool contains(num value) => value is double && start <= value && value <= end;

  @override
  String toString() => 'DoubleRange($start..$end)';
}

class DoubleRangeInclusive extends RangeInclusive<num> {
  const DoubleRangeInclusive(super.start, super.endInclusive);

  @override
  double get start => super.start as double;
  @override
  double get endInclusive => super.endInclusive as double;

  @override
  bool contains(num value) =>
      value is double && start <= value && value <= endInclusive;

  @override
  String toString() => 'DoubleRangeInclusive($start..=$endInclusive)';
}

class DoubleRangeFrom extends RangeFrom<num> {
  const DoubleRangeFrom(super.start);

  @override
  double get start => super.start as double;

  @override
  bool contains(num value) => value is double && start <= value;

  @override
  String toString() => 'DoubleRangeFrom($start..)';
}

class DoubleRangeTo extends RangeTo<num> {
  const DoubleRangeTo(super.end);

  double get endExclusive => end - 1;
  @override
  double get end => super.end as double;

  @override
  bool contains(Object? value) => value is double && value < end;

  @override
  String toString() => 'DoubleRangeTo(..=$end)';
}

class DoubleRangeToInclusive extends RangeToInclusive<num> {
  const DoubleRangeToInclusive(super.endInclusive);

  double get endExclusive => endInclusive - 1;
  @override
  double get endInclusive => super.endInclusive as double;

  @override
  bool contains(Object? value) => value is double && value <= endInclusive;

  @override
  String toString() => 'DoubleRangeToInclusive(..=$endInclusive)';
}

extension CreateDoubleRangeExtension on double {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  DoubleRange rangeUntil(double other) => DoubleRange(this, other - 1);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  DoubleRange rangeTo(double other) => DoubleRange(this, other);
}
