import 'package:meta/meta.dart';

import 'codec.dart';

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
      value != null ? .inclusive(value) : const .unbounded();

  const factory Bound.exclusive(C value) = ExclusiveBound;
  factory Bound.exclusiveOrUnbounded(C? value) =>
      value != null ? .exclusive(value) : const .unbounded();

  const factory Bound.unbounded() = UnboundedBound;

  /// Whichever of the two start bounds begins earlier, i.e., describes more
  /// values.
  ///
  /// See [compareStarts] for the ordering.
  static Bound<C> earlierStart<C extends Comparable<C>>(
    Bound<C> a,
    Bound<C> b,
  ) => compareStarts(a, b) <= 0 ? a : b;

  /// Whichever of the two start bounds begins later, i.e., describes fewer
  /// values.
  ///
  /// See [compareStarts] for the ordering.
  static Bound<C> laterStart<C extends Comparable<C>>(Bound<C> a, Bound<C> b) =>
      compareStarts(a, b) >= 0 ? a : b;

  /// Compares two bounds by where a range *starting* there begins.
  ///
  /// An unbounded start comes first, and among equal values an inclusive start
  /// comes before an exclusive one, since it also describes that value.
  static int compareStarts<C extends Comparable<C>>(Bound<C> a, Bound<C> b) {
    if (a.isUnbounded) return b.isUnbounded ? 0 : -1;
    if (b.isUnbounded) return 1;

    final byValue = a.valueOrNull!.compareTo(b.valueOrNull!);
    if (byValue != 0) return byValue;

    final aIsInclusive = a is InclusiveBound<C>;
    if (aIsInclusive == b is InclusiveBound<C>) return 0;
    return aIsInclusive ? -1 : 1;
  }

  /// Whichever of the two end bounds stops later, i.e., describes more values.
  ///
  /// See [compareEnds] for the ordering.
  static Bound<C> laterEnd<C extends Comparable<C>>(Bound<C> a, Bound<C> b) =>
      compareEnds(a, b) >= 0 ? a : b;

  /// Whichever of the two end bounds stops earlier, i.e., describes fewer
  /// values.
  ///
  /// See [compareEnds] for the ordering.
  static Bound<C> earlierEnd<C extends Comparable<C>>(Bound<C> a, Bound<C> b) =>
      compareEnds(a, b) <= 0 ? a : b;

  /// Compares two bounds by where a range *ending* there stops.
  ///
  /// An unbounded end comes last, and among equal values an exclusive end
  /// comes before an inclusive one, since it doesn't describe that value.
  static int compareEnds<C extends Comparable<C>>(Bound<C> a, Bound<C> b) {
    if (a.isUnbounded) return b.isUnbounded ? 0 : 1;
    if (b.isUnbounded) return -1;

    final byValue = a.valueOrNull!.compareTo(b.valueOrNull!);
    if (byValue != 0) return byValue;

    final aIsInclusive = a is InclusiveBound<C>;
    if (aIsInclusive == b is InclusiveBound<C>) return 0;
    return aIsInclusive ? 1 : -1;
  }

  /// Whether a range ending at [end] and one starting at [start] together
  /// describe an uninterrupted stretch of values.
  ///
  /// This only compares the bounds, so it can't tell an adjacency that depends
  /// on the values themselves: `..<5` and `5..` adjoin, but `..=4` and `5..`
  /// don't, because nothing here knows that no [int] lies between 4 and 5.
  ///
  /// Deliberately a static rather than a method on [end]: A
  /// `const UnboundedBound()` inside a generic class is an
  /// `UnboundedBound<Never>`, so as a method its parameter would be a
  /// `Bound<Never>` and reject every real bound at runtime.
  static bool adjoins<C extends Comparable<C>>(Bound<C> end, Bound<C> start) {
    if (end.isUnbounded || start.isUnbounded) return true;

    final comparison = end.valueOrNull!.compareTo(start.valueOrNull!);
    if (comparison != 0) return comparison > 0;

    // Both refer to the same value: It's covered unless both bounds exclude
    // it.
    return end is InclusiveBound<C> || start is InclusiveBound<C>;
  }

  /// Whether this is a bound with an exact (inclusive or exclusive) value.
  bool get isBounded;

  /// Whether this is an [UnboundedBound].
  bool get isUnbounded => !isBounded;

  C? get valueOrNull => switch (this) {
    InclusiveBound(value: final value) => value,
    ExclusiveBound(value: final value) => value,
    UnboundedBound() => null,
  };

  /// This bound as the opposite kind of edge: The end bound of everything
  /// before a start bound, and the start bound of everything after an end
  /// bound.
  ///
  /// Inclusive and exclusive swap, since the value itself changes sides. An
  /// unbounded bound stays unbounded, because there is nothing beyond it.
  Bound<C> get inverted => switch (this) {
    InclusiveBound(value: final value) => ExclusiveBound(value),
    ExclusiveBound(value: final value) => InclusiveBound(value),
    UnboundedBound() => this,
  };

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
  bool operator ==(Object other) {
    // Deliberately not `UnboundedBound<C>`: An unbounded bound holds no value,
    // so [C] is only ever phantom here. Comparing it would make `==`
    // asymmetric, because `const UnboundedBound()` inside a generic class can't
    // name that class's type parameter and becomes
    // `UnboundedBound<Never>`.
    return identical(this, other) || other is UnboundedBound;
  }

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
