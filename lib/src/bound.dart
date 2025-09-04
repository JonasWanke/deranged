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
  bool operator ==(Object other) =>
      identical(this, other) || other is UnboundedBound<C>;
  @override
  int get hashCode => 0;

  @override
  String toString() => 'UnboundedBound';
}
