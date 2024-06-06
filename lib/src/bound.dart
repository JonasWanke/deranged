sealed class Bound<C extends Comparable<C>> {
  const Bound();

  /// Whether this is a bound with an exact (inclusive or exclusive) value.
  bool get isBounded;

  /// Whether this is an [UnboundedBound].
  bool get isUnbounded => !isBounded;

  Bound<D> map<D extends Comparable<D>>(D Function(C) mapper);
}

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
