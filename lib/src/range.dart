import 'bound.dart';

// TODO(JonasWanke): final class accepting two bounds?
abstract class RangeBounds<C extends Comparable<C>> {
  const RangeBounds();

  Bound<C> get startBound;
  Bound<C> get endBound;

  bool contains(C value) {
    final startMatches = switch (startBound) {
      InclusiveBound(value: final startValue) =>
        startValue.compareTo(value) <= 0,
      ExclusiveBound(value: final startValue) =>
        startValue.compareTo(value) < 0,
      UnboundedBound() => true,
    };
    final endMatches = switch (endBound) {
      InclusiveBound(value: final endValue) => endValue.compareTo(value) >= 0,
      ExclusiveBound(value: final endValue) => endValue.compareTo(value) > 0,
      UnboundedBound() => true,
    };
    return startMatches && endMatches;
  }

  bool containsRange(RangeBounds<C> range) {
    final startMatches = switch (startBound) {
      InclusiveBound(value: final thisStartValue) => switch (range.startBound) {
          InclusiveBound(value: final otherStartValue) ||
          ExclusiveBound(value: final otherStartValue) =>
            thisStartValue.compareTo(otherStartValue) <= 0,
          UnboundedBound() => false,
        },
      ExclusiveBound(value: final thisStartValue) => switch (range.startBound) {
          InclusiveBound(value: final otherStartValue) =>
            thisStartValue.compareTo(otherStartValue) < 0,
          ExclusiveBound(value: final otherStartValue) =>
            thisStartValue.compareTo(otherStartValue) <= 0,
          UnboundedBound() => false,
        },
      UnboundedBound() => true,
    };
    final endMatches = switch (endBound) {
      InclusiveBound(value: final thisEndValue) => switch (range.endBound) {
          InclusiveBound(value: final otherEndValue) ||
          ExclusiveBound(value: final otherEndValue) =>
            thisEndValue.compareTo(otherEndValue) >= 0,
          UnboundedBound() => false,
        },
      ExclusiveBound(value: final thisEndValue) => switch (range.endBound) {
          InclusiveBound(value: final otherEndValue) =>
            thisEndValue.compareTo(otherEndValue) > 0,
          ExclusiveBound(value: final otherEndValue) =>
            thisEndValue.compareTo(otherEndValue) >= 0,
          UnboundedBound() => false,
        },
      UnboundedBound() => true,
    };
    return startMatches && endMatches;
  }
}

class AnyRange<C extends Comparable<C>> extends RangeBounds<C> {
  const AnyRange(this.startBound, this.endBound);

  @override
  final InclusiveBound<C> startBound;
  @override
  final ExclusiveBound<C> endBound;

  @override
  String toString() => 'AnyRange($startBound, $endBound)';
}

/// An unbounded range.
class RangeFull<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeFull();

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  UnboundedBound<C> get endBound => const UnboundedBound();

  @override
  String toString() => 'RangeFull()';
}

// A half-open range: start is included, end is excluded.
class Range<C extends Comparable<C>> extends RangeBounds<C> {
  const Range(this.start, this.end);

  final C start;
  final C end;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  ExclusiveBound<C> get endBound => ExclusiveBound(end);

  @override
  String toString() => 'Range($start ≤ value < $end)';
}

// A closed range: both start and end are included.
class RangeInclusive<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeInclusive(this.start, this.endInclusive);

  final C start;
  final C endInclusive;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  InclusiveBound<C> get endBound => InclusiveBound(endInclusive);

  @override
  String toString() => 'RangeInclusive($start ≤ value ≤ $endInclusive)';
}

// A range starting from an inclusive bound and without an end bound.
class RangeFrom<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeFrom(this.start);

  final C start;

  @override
  InclusiveBound<C> get startBound => InclusiveBound(start);
  @override
  UnboundedBound<C> get endBound => const UnboundedBound();

  @override
  String toString() => 'RangeFrom($start ≤ value)';
}

// TODO(JonasWanke): Naming – `RangeUntil`?
// A range ending with an exclusive bound and without a start bound.
class RangeTo<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeTo(this.end);

  final C end;

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  ExclusiveBound<C> get endBound => ExclusiveBound(end);

  @override
  String toString() => 'RangeTo(value < $end)';
}

// A range ending with an inclusive bound and without a start bound.
class RangeToInclusive<C extends Comparable<C>> extends RangeBounds<C> {
  const RangeToInclusive(this.end);

  final C end;

  @override
  UnboundedBound<C> get startBound => const UnboundedBound();
  @override
  InclusiveBound<C> get endBound => InclusiveBound(end);

  @override
  String toString() => 'RangeToInclusive(value ≤ $end)';
}

extension CreateRangeExtension<C extends Comparable<C>> on C {
  Range<C> rangeUntil(C other) => Range(this, other);
  RangeInclusive<C> rangeTo(C other) => RangeInclusive(this, other);
}
