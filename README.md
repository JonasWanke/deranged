# Deranged

This package provides range and progression types for Dart, inspired by Rust and Kotlin.

## Ranges

All ranges are immutable and extend `RangeBounds<C extends Comparable<C>>`, which provides the following getters and methods:

```dart
Bound<C> get startBound;
Bound<C> get endBound;

bool contains(C value) { … }
bool containsRange(RangeBounds<C> range) { … }
bool intersects(RangeBounds<C> range) { … }
```

`Bound<C extends Comparable<C>>` is a sealed class with three subclasses: `InclusiveBound<C>`, `ExclusiveBound<C>`, and `UnboundedBound<C>`.

Since some functions might take only specific kinds of ranges, there are multiple range subclasses with different start and end bounds:

| Start Bound | End Bound | Generic Class         | `int` Class      | `double` Class           |
| :---------- | :-------- | :-------------------- | :--------------- | :----------------------- |
| Inclusive   | Inclusive | `RangeInclusive<C>`   | `IntRange`\*     | `DoubleRangeInclusive`   |
| Inclusive   | Exclusive | `Range<C>`            | `IntRange`\*     | `DoubleRange`            |
| Inclusive   | Unbounded | `RangeFrom<C>`        | `IntRangeFrom`\* | `DoubleRangeFrom`        |
| Exclusive   | Inclusive | —                     | —                | —                        |
| Exclusive   | Exclusive | —                     | —                | —                        |
| Exclusive   | Unbounded | —                     | —                | —                        |
| Unbounded   | Inclusive | `RangeToInclusive<C>` | `IntRangeTo`     | `DoubleRangeToInclusive` |
| Unbounded   | Exclusive | `RangeTo<C>`          | `IntRangeTo`     | `DoubleRangeTo`          |
| Unbounded   | Unbounded | `RangeFull<C>`        | `IntRangeFull`   | `DoubleRangeFull`        |

\* marks classes that implement `Iterable<…>`. For example, you can write `for (final i in 0.rangeTo(10)) { … }`.

To create a range, you can use the constructors of these classes directly, or use extension functions `.rangeUntil(…)` (for `Range`) or `.rangeTo(…)` (for `RangeInclusive`) on `Comparable` objects.
If there's no specific range class for the bounds you want, you can use the `AnyRange` class with any bounds.

## Note About `int` and `double` Ranges

In Dart, `int` does not implement `Comparable<int>`, but rather `Comparable<num>`.
Hence, it's not possible to create a `Range<int>`.
Therefore, this package offers a set of range types that are specifically designed to work with `int` values.
These inherit from `Range<num>` (or other range classes with `num`), but have overrides for the public API to return `int` values.
The same applies to `double`.

## Progressions

Unlike ranges, `Progression`s contain only values that are multiples of a given `step` size.
`step` supports both positive and negative values.
All progressions implement `Iterable<T>`, so you can use them in `for` loops and other iterable operations.

You can create a progression using `start.rangeTo(end).stepBy(step)` or use their constructor directly:

```dart
0.rangeTo(10).stepBy(2); // 0, 2, 4, 6, 8, 10
10.rangeTo(0).stepBy(-2); // 10, 8, 6, 4, 2, 0
// Equivalent: `IntProgression(10, 0, -2)`
```

For types other than `int`, you can use `StepProgression`.
This requires the type to implement `Step` and `Comparable`.
