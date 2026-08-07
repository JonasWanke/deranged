import '../deranged.dart';

class DoubleRangeFull extends RangeFull<num> {
  const DoubleRangeFull();

  @override
  bool contains(Object? value) => value is double;

  @override
  String toString() => 'DoubleRangeFull(..)';
}

class DoubleRange extends Range<num> {
  const DoubleRange(double super.start, double super.end);

  @override
  double get start => super.start as double;
  @override
  double get end => super.end as double;

  @override
  bool contains(num value) => value is double && start <= value && value < end;

  @override
  String toString() => 'DoubleRange($start..<$end)';
}

/// Decodes JSON numbers as [double]s, since a whole number such as `5.0` may
/// come back from a JSON parser as an [int].
const _numAsDoubleCodec = FunctionBasedCodec<double, num>(
  encode: _encodeDouble,
  decode: _decodeDouble,
);
num _encodeDouble(double value) => value;
double _decodeDouble(num encoded) => encoded.toDouble();

/// Encodes a [DoubleRange] as a map with "start" and "end" keys.
class DoubleRangeAsMapCodec extends StartEndAsMapCodec<DoubleRange, double> {
  const DoubleRangeAsMapCodec() : super(_numAsDoubleCodec);

  @override
  (double, double) startAndEndOf(DoubleRange range) => (range.start, range.end);
  @override
  DoubleRange create(double start, double end) => DoubleRange(start, end);
}

class DoubleRangeInclusive extends RangeInclusive<num> {
  const DoubleRangeInclusive(double super.start, double super.end);

  @override
  double get start => super.start as double;
  @override
  double get end => super.end as double;

  @override
  bool contains(num value) => value is double && start <= value && value <= end;

  @override
  String toString() => 'DoubleRangeInclusive($start..=$end)';
}

class DoubleRangeFrom extends RangeFrom<num> {
  const DoubleRangeFrom(double super.start);

  @override
  double get start => super.start as double;

  @override
  bool contains(num value) => value is double && start <= value;

  @override
  String toString() => 'DoubleRangeFrom($start..)';
}

class DoubleRangeUntil extends RangeUntil<num> {
  const DoubleRangeUntil(double super.end);

  @override
  double get end => super.end as double;

  @override
  bool contains(Object? value) => value is double && value < end;

  @override
  String toString() => 'DoubleRangeUntil(..<$end)';
}

class DoubleRangeTo extends RangeTo<num> {
  const DoubleRangeTo(double super.end);

  @override
  double get end => super.end as double;

  @override
  bool contains(Object? value) => value is double && value <= end;

  @override
  String toString() => 'DoubleRangeTo(..=$end)';
}

extension DoubleExtension on double {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  DoubleRange rangeUntil(double other) => DoubleRange(this, other);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  DoubleRangeInclusive rangeTo(double other) =>
      DoubleRangeInclusive(this, other);
}
