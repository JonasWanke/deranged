import 'package:meta/meta.dart';

import '../deranged.dart';

/// Objects that have successor and predecessor operations.
///
/// Classes that implement this interface might have a limited range of valid
/// values, in which case stepping beyond those values with [stepBy] would
/// return `null`.
///
/// See also:
///
/// - [StepUnlimited], which extends this interface to include unlimited
///   stepping.
@immutable
abstract interface class Step<C extends Step<C>> implements Comparable<C> {
  /// Returns the result of moving [count] steps forward from this.
  ///
  /// - If [count] is positive, the result is after this.
  /// - If [count] is zero, the result is this.
  /// - If [count] is negative, the result is before this.
  ///
  /// For example, if this were implemented for `int`:
  /// `2.stepBy(3) = 2 + 3 = 5`.
  C? stepBy(int count);

  /// The value directly before this one, or `null` if this is the first value.
  C? get previous => stepBy(-1);

  /// The value directly after this one, or `null` if this is the last value.
  C? get next => stepBy(1);

  /// The number of steps between this and [other].
  ///
  /// - If [other] is after this, the result is positive.
  /// - If [other] is the same as this, the result is zero.
  /// - If [other] is before this, the result is negative.
  ///
  /// For example, if this were implemented for `int`:
  /// `2.stepsUntil(5) = 5 - 2 = 3`.
  int stepsUntil(C other);
}

/// [Step] objects that can be stepped indefinitely in either direction (using
/// [stepBy]), without returning `null`.
@immutable
abstract interface class StepUnlimited<C extends StepUnlimited<C>>
    implements Step<C> {
  @override
  C stepBy(int count);

  /// The value directly before this one.
  @override
  C get previous => stepBy(-1);

  /// The value directly after this one.
  @override
  C get next => stepBy(1);
}

extension StepUnlimitedExtension<C extends StepUnlimited<C>> on C {
  /// Creates a range from `this` (inclusive) to `this.stepBy(length)`
  /// (exclusive).
  Range<C> rangeUntilWithLength(int length) => Range(this, stepBy(length));

  /// Creates a range from `this` (inclusive) to `this.stepBy(length)`
  /// (inclusive).
  RangeInclusive<C> rangeToWithLength(int length) =>
      RangeInclusive(this, stepBy(length));
}
