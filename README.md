# Ranges

This package provides a set of range types for use in Dart programs, inspired by ranges in Rust and Kotlin.
All ranges are immutable and extend `RangeBounds<C extends Comparable<C>>`, which provides the following getters and methods:

```dart
Bound<C> get startBound;
Bound<C> get endBound;

bool contains(C value) { … }
bool containsRange(RangeBounds<C> range) { … }
```

`Bound<C extends Comparable<C>>` is a sealed class with three subclasses: `InclusiveBound<C>`, `ExclusiveBound<C>`, and `UnboundedBound<C>`.

Since some functions might take only specific kinds of ranges, there are multiple range subclasses with different start and end bounds:

| Start Bound | End Bound | Generic Class         | `int` Class      |
| :---------- | :-------- | :-------------------- | :--------------- |
| Inclusive   | Inclusive | `RangeInclusive<C>`   | `IntRange`\*     |
| Inclusive   | Exclusive | `Range<C>`            | `IntRange`\*     |
| Inclusive   | Unbounded | `RangeFrom<C>`        | `IntRangeFrom`\* |
| Exclusive   | Inclusive | —                     | —                |
| Exclusive   | Exclusive | —                     | —                |
| Exclusive   | Unbounded | —                     | —                |
| Unbounded   | Inclusive | `RangeToInclusive<C>` | `IntRangeTo`     |
| Unbounded   | Exclusive | `RangeTo<C>`          | `IntRangeTo`     |
| Unbounded   | Unbounded | `RangeFull<C>`        | `IntRangeFull`   |

\* marks classes that implement `Iterable<…>`. For example, you can write `for (final i in 0.rangeTo(10)) { … }`.

To create a range, you can use the constructors of these classes directly, or use extension functions `.rangeUntil(…)` (for `Range`) or `.rangeTo(…)` (for `RangeInclusive`) on `Comparable` objects.
If there's no specific range class for the bounds you want, you can use the `AnyRange` class with any bounds.

## Progressions

Unlike ranges, progressions contain only values that are multiples of a given step.

You can create a progression using `start.rangeTo(end).stepBy(step)` or `IntProgression(start, end, step)`.
`step` supports both positive and negative values.

For example:

```dart
0.rangeTo(10).stepBy(2).toList(); // [0, 2, 4, 6, 8, 10]
10.rangeTo(0).stepBy(-2).toList(); // [10, 8, 6, 4, 2, 0]
```

## Note about `int` Ranges

In Dart, `int` does not implement `Comparable<int>`, but rather `Comparable<num>`.
Hence, it's not possible to create a `Range<int>`.
Therefore, this package offers a set of range types that are specifically designed to work with `int` values.
These inherit from `Range<num>` (or other range classes with `num`), but have overrides for the public API to return `int` values.
