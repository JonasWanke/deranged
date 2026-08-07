import '../deranged.dart';

// DoubleRangeFull

class DoubleRangeFull extends RangeFull<num> {
  const DoubleRangeFull();

  @override
  RangeFull<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(double) mapper,
  ) => const RangeFull();
  @override
  bool contains(Object? value) => value is double;

  @override
  String toString() => 'DoubleRangeFull(..)';
}

// DoubleRange

class DoubleRange extends Range<num> {
  const DoubleRange(double super.start, double super.end);

  @override
  double get start => super.start as double;
  @override
  double get end => super.end as double;

  @override
  Range<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(double) mapper,
  ) => Range(mapper(start), mapper(end));

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

// DoubleRangeInclusive

class DoubleRangeInclusive extends RangeInclusive<num> {
  const DoubleRangeInclusive(double super.start, double super.end);

  @override
  double get start => super.start as double;
  @override
  double get end => super.end as double;

  @override
  RangeInclusive<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(double) mapper,
  ) => RangeInclusive(mapper(start), mapper(end));

  @override
  bool contains(num value) => value is double && start <= value && value <= end;

  @override
  String toString() => 'DoubleRangeInclusive($start..=$end)';
}

/// Encodes a [DoubleRangeInclusive] as a map with "start" and "end" keys.
class DoubleRangeInclusiveAsMapCodec
    extends StartEndAsMapCodec<DoubleRangeInclusive, double> {
  const DoubleRangeInclusiveAsMapCodec() : super(_numAsDoubleCodec);

  @override
  (double, double) startAndEndOf(DoubleRangeInclusive range) =>
      (range.start, range.end);
  @override
  DoubleRangeInclusive create(double start, double end) =>
      DoubleRangeInclusive(start, end);
}

// DoubleRangeFrom

class DoubleRangeFrom extends RangeFrom<num> {
  const DoubleRangeFrom(double super.start);

  @override
  double get start => super.start as double;

  @override
  RangeFrom<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(double) mapper,
  ) => RangeFrom(mapper(start));

  @override
  bool contains(num value) => value is double && start <= value;

  @override
  String toString() => 'DoubleRangeFrom($start..)';
}

/// Encodes a [DoubleRangeFrom] as a map with a "start" key.
class DoubleRangeFromAsMapCodec
    extends SingleBoundAsMapCodec<DoubleRangeFrom, double> {
  const DoubleRangeFromAsMapCodec() : super(_numAsDoubleCodec);

  @override
  String get key => 'start';
  @override
  double valueOf(DoubleRangeFrom range) => range.start;
  @override
  DoubleRangeFrom create(double value) => DoubleRangeFrom(value);
}

// DoubleRangeUntil

class DoubleRangeUntil extends RangeUntil<num> {
  const DoubleRangeUntil(double super.end);

  @override
  double get end => super.end as double;

  @override
  RangeUntil<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(double) mapper,
  ) => RangeUntil(mapper(end));

  @override
  bool contains(Object? value) => value is double && value < end;

  @override
  String toString() => 'DoubleRangeUntil(..<$end)';
}

/// Encodes a [DoubleRangeUntil] as a map with an "end" key.
class DoubleRangeUntilAsMapCodec
    extends SingleBoundAsMapCodec<DoubleRangeUntil, double> {
  const DoubleRangeUntilAsMapCodec() : super(_numAsDoubleCodec);

  @override
  String get key => 'end';
  @override
  double valueOf(DoubleRangeUntil range) => range.end;
  @override
  DoubleRangeUntil create(double value) => DoubleRangeUntil(value);
}

// DoubleRangeTo

class DoubleRangeTo extends RangeTo<num> {
  const DoubleRangeTo(double super.end);

  @override
  double get end => super.end as double;

  @override
  RangeTo<D> mapBounds<D extends Comparable<D>>(
    covariant D Function(double) mapper,
  ) => RangeTo(mapper(end));

  @override
  bool contains(Object? value) => value is double && value <= end;

  @override
  String toString() => 'DoubleRangeTo(..=$end)';
}

/// Encodes a [DoubleRangeTo] as a map with an "end" key.
class DoubleRangeToAsMapCodec
    extends SingleBoundAsMapCodec<DoubleRangeTo, double> {
  const DoubleRangeToAsMapCodec() : super(_numAsDoubleCodec);

  @override
  String get key => 'end';
  @override
  double valueOf(DoubleRangeTo range) => range.end;
  @override
  DoubleRangeTo create(double value) => DoubleRangeTo(value);
}

extension DoubleExtension on double {
  /// Creates a range from `this` (inclusive) to [other] (exclusive).
  DoubleRange rangeUntil(double other) => DoubleRange(this, other);

  /// Creates a range from `this` (inclusive) to [other] (inclusive).
  DoubleRangeInclusive rangeTo(double other) =>
      DoubleRangeInclusive(this, other);
}
