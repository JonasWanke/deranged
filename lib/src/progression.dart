import 'dart:math';

import 'package:meta/meta.dart';

import '../deranged.dart';

/// A progression of values of type [T], defined by a [start], [end]
/// (exclusive), and [step].
///
/// {@template deranged.Progression.empty}
/// A progression is empty if the [start] is greater than the [end]
/// when the [step] is positive, or if the [start] is less than the
/// [end] when the [step] is negative.
/// {@endtemplate}
///
/// See also:
///
/// - [IntProgression], a progression of [int] values.
/// - [StepProgression], a progression of values that implement [Step].
@immutable
abstract class Progression<T> implements Iterable<T> {
  const Progression(this.start, this.end, this.step) : assert(step != 0);

  final T start;
  final T end;
  final int step;

  T operator [](int index) => elementAt(index);

  @override
  bool operator ==(Object other) =>
      other is Progression<T> &&
      start == other.start &&
      end == other.end &&
      step == other.step;
  @override
  int get hashCode => Object.hash(start, end, step);

  @override
  String toString() => 'Progression($start..<$end stepBy $step)';
}

/// Objects that have successor and predecessor operations.
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
  C stepBy(int count);

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

extension StepExtension<C extends Step<C>> on C {
  /// Creates a range from `this` (inclusive) to `this.stepBy(length)`
  /// (exclusive).
  Range<C> rangeUntilWithLength(int length) => Range(this, stepBy(length));

  /// Creates a range from `this` (inclusive) to `this.stepBy(length)`
  /// (inclusive).
  RangeInclusive<C> rangeToWithLength(int length) =>
      RangeInclusive(this, stepBy(length));
}

/// A [Progression] of values of type [T], defined by a [start], [end],
/// and [step].
///
/// [T] must implement [Step] and [Comparable], which, together, provide the
/// necessary operations for the progression calculations.
///
/// {@macro deranged.Progression.empty}
///
/// See also:
///
/// - [Progression], the base class for progressions.
/// - [IntProgression], a progression of [int] values.
class StepProgression<T extends Step<T>> extends Progression<T>
    with Iterable<T> {
  const StepProgression(super.start, super.end, super.step) : assert(step != 0);

  StepProgression<T> stepBy(int step) => StepProgression(start, end, step);

  @override
  Iterator<T> get iterator =>
      Iterable.generate(length, (i) => start.stepBy(i * step)).iterator;
  @override
  int get length => max(0, (start.stepsUntil(end) + step) ~/ step);
  @override
  T get last {
    if (isEmpty) throw StateError('No element');

    return end.stepBy(
      step > 0
          ? -(start.stepsUntil(end) % step)
          : end.stepsUntil(start) % -step,
    );
  }

  @override
  T elementAt(int index) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(
        index,
        length,
        indexable: this,
        name: 'index',
      );
    }
    return start.stepBy(index * step);
  }

  @override
  bool contains(Object? element) {
    if (element is! T) return false;
    if (step > 0 &&
        (element.compareTo(start) < 0 || element.compareTo(end) > 0)) {
      return false;
    }
    if (step < 0 &&
        (element.compareTo(end) < 0 || element.compareTo(start) > 0)) {
      return false;
    }
    return start.stepsUntil(element) % step == 0;
  }

  @override
  String toString() => 'StepProgression($start..=$end stepBy $step)';
}
