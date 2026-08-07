import 'dart:math';

import 'package:meta/meta.dart';

import '../deranged.dart';

/// A progression of values of type [T], defined by a [start], [endInclusive],
/// and [step].
///
/// Both [start] and [endInclusive] are part of the progression, though
/// [endInclusive] is only reached if it is a whole number of [step]s away from
/// [start].
///
/// {@template deranged.Progression.empty}
/// A progression is empty if the [start] is greater than the [endInclusive]
/// when the [step] is positive, or if the [start] is less than the
/// [endInclusive] when the [step] is negative.
/// {@endtemplate}
///
/// See also:
///
/// - [IntProgression], a progression of [int] values.
/// - [StepProgression], a progression of values that implement [Step].
@immutable
abstract class Progression<T> with Iterable<T> {
  const Progression(this.start, this.endInclusive, this.step)
    : assert(step != 0);

  final T start;
  final T endInclusive;
  final int step;

  T operator [](int index) => elementAt(index);

  @override
  bool operator ==(Object other) =>
      other is Progression<T> &&
      start == other.start &&
      endInclusive == other.endInclusive &&
      step == other.step;
  @override
  int get hashCode => Object.hash(start, endInclusive, step);

  @override
  String toString() => 'Progression($start..=$endInclusive stepBy $step)';
}

/// A [Progression] of values of type [T], defined by a [start],
/// [endInclusive], and [step].
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
class StepProgression<T extends Step<T>> extends Progression<T> {
  const StepProgression(super.start, super.endInclusive, super.step)
    : assert(step != 0);

  StepProgression<T> stepBy(int step) =>
      StepProgression(start, endInclusive, step);

  @override
  Iterator<T> get iterator =>
      Iterable.generate(length, (i) => start.stepBy(i * step)!).iterator;
  @override
  int get length => max(0, (start.stepsUntil(endInclusive) + step) ~/ step);
  @override
  T get last {
    if (isEmpty) throw StateError('No element');

    return endInclusive.stepBy(
      step > 0
          ? -(start.stepsUntil(endInclusive) % step)
          : endInclusive.stepsUntil(start) % -step,
    )!;
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
    return start.stepBy(index * step)!;
  }

  @override
  bool contains(Object? element) {
    if (element is! T) return false;
    if (step > 0 &&
        (element.compareTo(start) < 0 || element.compareTo(endInclusive) > 0)) {
      return false;
    }
    if (step < 0 &&
        (element.compareTo(endInclusive) < 0 || element.compareTo(start) > 0)) {
      return false;
    }
    return start.stepsUntil(element) % step == 0;
  }

  @override
  String toString() => 'StepProgression($start..=$endInclusive stepBy $step)';
}

/// Encodes a [StepProgression] as a map with "start", "endInclusive", and
/// "step" keys.
class StepProgressionAsMapCodec<T extends Step<T>>
    extends ProgressionAsMapCodec<StepProgression<T>, T> {
  const StepProgressionAsMapCodec([super.innerCodec]);

  @override
  (T, T, int) partsOf(StepProgression<T> progression) =>
      (progression.start, progression.endInclusive, progression.step);
  @override
  StepProgression<T> create(T start, T endInclusive, int step) =>
      StepProgression(start, endInclusive, step);
}
