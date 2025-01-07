import 'package:meta/meta.dart';

/// One end of a range.
///
/// See also:
/// - [InclusiveBound], which represents an inclusive bound.
/// - [ExclusiveBound], which represents an exclusive bound.
/// - [UnboundedBound], which represents an unbounded bound.
@immutable
sealed class Bound<C extends Comparable<C>> {
  const Bound();

  /// Whether this is a bound with an exact (inclusive or exclusive) value.
  bool get isBounded;

  /// Whether this is an [UnboundedBound].
  bool get isUnbounded => !isBounded;

  /// Maps the value of this bound using [mapper].
  Bound<D> map<D extends Comparable<D>>(D Function(C) mapper);
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
  String toString() => 'UnboundedBound';
}
