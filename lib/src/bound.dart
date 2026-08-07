import 'package:meta/meta.dart';

import '../deranged.dart';
import 'codec.dart';
import 'utils.dart' as utils;

/// One end of a range.
///
/// See also:
/// - [InclusiveBound], which represents an inclusive bound.
/// - [ExclusiveBound], which represents an exclusive bound.
/// - [UnboundedBound], which represents an unbounded bound.
@immutable
sealed class Bound<C extends Comparable<C>> {
  const Bound();

  const factory Bound.inclusive(C value) = InclusiveBound;
  factory Bound.inclusiveOrUnbounded(C? value) =>
      InclusiveBound.orUnbounded(value);

  const factory Bound.exclusive(C value) = ExclusiveBound;
  factory Bound.exclusiveOrUnbounded(C? value) =>
      ExclusiveBound.orUnbounded(value);

  const factory Bound.unbounded() = UnboundedBound;

  /// Returns the maximum of the two lower bounds [a] and [b].
  static Bound<C> maxLower<C extends Step<C>>(Bound<C> a, Bound<C>? b) {
    if (b == null) return a;

    return switch ((a, b)) {
      (InclusiveBound(value: final a), InclusiveBound(value: final b)) =>
        .inclusive(utils.max(a, b)),
      (
        InclusiveBound(value: final inclusive),
        ExclusiveBound(value: final exclusive),
      ) ||
      (
        ExclusiveBound(value: final exclusive),
        InclusiveBound(value: final inclusive),
      ) => () {
        final exclusiveToInclusive = exclusive.stepBy(1);
        if (exclusiveToInclusive == null) return ExclusiveBound(exclusive);
        return InclusiveBound(utils.max(inclusive, exclusiveToInclusive));
      }(),
      (ExclusiveBound(value: final a), ExclusiveBound(value: final b)) =>
        .exclusive(utils.max(a, b)),
      (UnboundedBound(), final other) ||
      (final other, UnboundedBound()) => other,
    };
  }

  /// Returns the minimum of the two upper bounds [a] and [b].
  static Bound<C> minUpper<C extends Step<C>>(Bound<C> a, Bound<C>? b) {
    if (b == null) return a;

    return switch ((a, b)) {
      (InclusiveBound(value: final a), InclusiveBound(value: final b)) =>
        .inclusive(utils.min(a, b)),
      (
        InclusiveBound(value: final inclusive),
        ExclusiveBound(value: final exclusive),
      ) ||
      (
        ExclusiveBound(value: final exclusive),
        InclusiveBound(value: final inclusive),
      ) => () {
        final exclusiveToInclusive = exclusive.stepBy(-1);
        if (exclusiveToInclusive == null) return ExclusiveBound(exclusive);
        return InclusiveBound(utils.min(inclusive, exclusiveToInclusive));
      }(),
      (ExclusiveBound(value: final a), ExclusiveBound(value: final b)) =>
        .exclusive(utils.min(a, b)),
      (UnboundedBound(), final other) ||
      (final other, UnboundedBound()) => other,
    };
  }

  /// Whether this is a bound with an exact (inclusive or exclusive) value.
  bool get isBounded;

  /// Whether this is an [UnboundedBound].
  bool get isUnbounded => !isBounded;

  /// Map the value of this bound using [mapper].
  Bound<D> map<D extends Comparable<D>>(D Function(C) mapper);

  /// Cast the value of this bound to [D].
  Bound<D> cast<D extends Comparable<D>>();

  @override
  bool operator ==(Object other);
  @override
  int get hashCode;
}

/// An inclusive end of a range.
///
/// See also:
/// - [ExclusiveBound], which represents an exclusive bound.
/// - [UnboundedBound], which represents an unbounded bound.
final class InclusiveBound<C extends Comparable<C>> extends Bound<C> {
  const InclusiveBound(this.value);
  static Bound<C> orUnbounded<C extends Comparable<C>>(C? value) =>
      value != null ? .inclusive(value) : const .unbounded();

  final C value;

  @override
  bool get isBounded => true;

  @override
  InclusiveBound<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      InclusiveBound(mapper(value));
  @override
  InclusiveBound<D> cast<D extends Comparable<D>>() =>
      InclusiveBound(value as D);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InclusiveBound<C> && value == other.value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'InclusiveBound($value)';
}

/// An exclusive end of a range.
///
/// See also:
/// - [InclusiveBound], which represents an inclusive bound.
/// - [UnboundedBound], which represents an unbounded bound.
final class ExclusiveBound<C extends Comparable<C>> extends Bound<C> {
  const ExclusiveBound(this.value);
  static Bound<C> orUnbounded<C extends Comparable<C>>(C? value) =>
      value != null ? .exclusive(value) : const .unbounded();

  final C value;

  @override
  bool get isBounded => true;

  @override
  ExclusiveBound<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      ExclusiveBound(mapper(value));
  @override
  ExclusiveBound<D> cast<D extends Comparable<D>>() =>
      ExclusiveBound(value as D);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExclusiveBound<C> && value == other.value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ExclusiveBound($value)';
}

/// An unbounded end of a range.
///
/// See also:
/// - [InclusiveBound], which represents an inclusive bound.
/// - [ExclusiveBound], which represents an exclusive bound.
final class UnboundedBound<C extends Comparable<C>> extends Bound<C> {
  const UnboundedBound();

  @override
  bool get isBounded => false;

  @override
  UnboundedBound<D> map<D extends Comparable<D>>(D Function(C) mapper) =>
      const UnboundedBound();
  @override
  UnboundedBound<D> cast<D extends Comparable<D>>() => UnboundedBound();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UnboundedBound<C>;
  @override
  int get hashCode => 0;

  @override
  String toString() => 'UnboundedBound';
}

/// Encodes a [Bound] as a map with a "type" key (one of "inclusive",
/// "exclusive", or "unbounded") and, unless unbounded, a "value" key.
class BoundAsMapCodec<C extends Comparable<C>> extends AsMapCodec<Bound<C>, C> {
  const BoundAsMapCodec([super.innerCodec]);

  static const _inclusive = 'inclusive';
  static const _exclusive = 'exclusive';
  static const _unbounded = 'unbounded';

  @override
  Map<String, dynamic> encode(Bound<C> input) => switch (input) {
    InclusiveBound(value: final value) => {
      'type': _inclusive,
      'value': encodeValue(value),
    },
    ExclusiveBound(value: final value) => {
      'type': _exclusive,
      'value': encodeValue(value),
    },
    UnboundedBound() => {'type': _unbounded},
  };

  @override
  Bound<C> decode(Map<String, dynamic> encoded) => switch (encoded['type']) {
    _inclusive => InclusiveBound(decodeValue(encoded['value'])),
    _exclusive => ExclusiveBound(decodeValue(encoded['value'])),
    _unbounded => const UnboundedBound(),
    final type => throw FormatException('Unknown bound type: $type', encoded),
  };
}
