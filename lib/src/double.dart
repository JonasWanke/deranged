import '../deranged.dart';
import 'codec.dart';

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
  bool contains(num value) => value is double && start <= value && value <= end;

  @override
  String toString() => 'DoubleRange($start..<$end)';
}

/// Encodes an [DoubleRange] as a map with "start" and "end" keys.
class DoubleRangeAsMapCodec
    extends CodecAndJsonConverter<DoubleRange, Map<String, dynamic>> {
  const DoubleRangeAsMapCodec();

  @override
  Map<String, dynamic> encode(DoubleRange input) => {
    'start': input.start,
    'end': input.end,
  };
  @override
  DoubleRange decode(Map<String, dynamic> encoded) => DoubleRange(
    (encoded['start'] as num).toDouble(),
    (encoded['end'] as num).toDouble(),
  );
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

class DoubleRangeTo extends RangeTo<num> {
  const DoubleRangeTo(double super.end);

  double get endExclusive => end - 1;
  @override
  double get end => super.end as double;

  @override
  bool contains(Object? value) => value is double && value < end;

  @override
  String toString() => 'DoubleRangeTo(..=$end)';
}

class DoubleRangeToInclusive extends RangeToInclusive<num> {
  const DoubleRangeToInclusive(double super.end);

  double get endExclusive => end - 1;
  @override
  double get end => super.end as double;

  @override
  bool contains(Object? value) => value is double && value <= end;

  @override
  String toString() => 'DoubleRangeToInclusive(..=$end)';
}

extension DoubleExtension on double {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  DoubleRange rangeUntil(double other) => DoubleRange(this, other - 1);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  DoubleRange rangeTo(double other) => DoubleRange(this, other);
}
