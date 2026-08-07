# Deranged

This package provides range and progression types for Dart, inspired by Rust and Kotlin.

## Ranges

All ranges are immutable and extend [`RangeBounds<C extends Comparable<C>>`][`RangeBounds`], which provides the following getters and methods:

```dart
Bound<C> get startBound;
Bound<C> get endBound;

bool contains(C value) { … }
bool containsRange(RangeBounds<C> range) { … }
bool intersects(RangeBounds<C> range) { … }
```

[`Bound<C extends Comparable<C>>`][`Bound`] is a sealed class with three subclasses: [`InclusiveBound<C>`][`InclusiveBound`], [`ExclusiveBound<C>`][`ExclusiveBound`], and [`UnboundedBound<C>`][`UnboundedBound`].

Since some functions might take only specific kinds of ranges, there are multiple range subclasses with different start and end bounds:

| Start Bound | End Bound | Generic Class                           | [`int`] Class                | [`double`] Class         |
| :---------- | :-------- | :-------------------------------------- | :--------------------------- | :----------------------- |
| Inclusive   | Inclusive | [`RangeInclusive<C>`][`RangeInclusive`] | [`IntRange`]<sup>1, 2</sup>  | [`DoubleRangeInclusive`] |
| Inclusive   | Exclusive | [`Range<C>`][`Range`]                   | [`IntRange`]<sup>1</sup>     | [`DoubleRange`]          |
| Inclusive   | Unbounded | [`RangeFrom<C>`][`RangeFrom`]           | [`IntRangeFrom`]<sup>1</sup> | [`DoubleRangeFrom`]      |
| Exclusive   | Inclusive | —                                       | —                            | —                        |
| Exclusive   | Exclusive | —                                       | —                            | —                        |
| Exclusive   | Unbounded | —                                       | —                            | —                        |
| Unbounded   | Inclusive | [`RangeTo<C>`][`RangeTo`]               | —<sup>3</sup>                | [`DoubleRangeTo`]        |
| Unbounded   | Exclusive | [`RangeUntil<C>`][`RangeUntil`]         | [`IntRangeUntil`]            | [`DoubleRangeUntil`]     |
| Unbounded   | Unbounded | [`RangeFull<C>`][`RangeFull`]           | [`IntRangeFull`]             | [`DoubleRangeFull`]      |

<sup>1</sup> marks classes that implement [`Iterable<…>`][`Iterable`]. For example, you can write `for (final i in 0.rangeTo(10)) { … }`.\
<sup>2</sup> via the [`IntRange.inclusive(…)`][`IntRange.inclusive`] constructor rather than a separate class – see the note below.\
<sup>3</sup> no separate class; write `IntRangeUntil(end + 1)`.

Names follow one convention: **`until` means an exclusive end, `to` means an inclusive end.**
This holds for class names ([`RangeUntil`] is `..<end`, [`RangeTo`] is `..=end`) as well as method names ([`.rangeUntil(…)`][`comparableExtension.rangeUntil`] creates a [`Range`], [`.rangeTo(…)`][`comparableExtension.rangeTo`] creates a [`RangeInclusive`]).

To create a range, you can use the constructors of these classes directly, or those extension methods on [`Comparable`] objects.
If there's no specific range class for the bounds you want, you can use the [`AnyRange`] class with any bounds.

> Note about [`int`] and [`double`] ranges:
>
> In Dart, [`int`] does not implement [`Comparable<int>`][`Comparable`], but rather [`Comparable<num>`][`Comparable`].
> Hence, it's not possible to create a [`Range<int>`][`Range`].
> Therefore, this package offers a set of range types that are specifically designed to work with [`int`]/[`double`] values.
> These inherit from [`Range<num>`][`Range`] (or other range classes with [`num`]), but have overrides for the public API to return [`int`]/[`double`] values.
>
> [`int`] is discrete, so half-open and closed ranges represent the same values and only differ in how you write them down.
> [`IntRange`] is therefore the single canonical (half-open) type, with [`IntRange.inclusive(…)`][`IntRange.inclusive`] as an alternative constructor – its length is `end - start`, empty ranges are always representable, and adjacent ranges tile without gaps.
> [`double`] is continuous, where the two forms are *not* interchangeable, so it has both [`DoubleRange`] and [`DoubleRangeInclusive`].

## Progressions

Unlike ranges, [`Progression`]s contain only values that are multiples of a given step size.
This [`step`][`progression.step`] supports both positive and negative values.
All progressions implement [`Iterable<T>`][`Iterable`], so you can use them in `for` loops and other iterable operations.

A progression runs from [`start`][`progression.start`] to [`endInclusive`][`progression.endInclusive`] — both are part of it, though [`endInclusive`][`progression.endInclusive`] is only reached if it's a whole number of steps away from [`start`][`progression.start`].

You can create a progression using [`start.rangeTo(end).stepBy(step)`][`intRange.stepBy`] or use their constructor directly:

```dart
0.rangeTo(10).stepBy(2); // 0, 2, 4, 6, 8, 10
10.rangeTo(0).stepBy(-2); // 10, 8, 6, 4, 2, 0
// Equivalent: `IntProgression(10, 0, -2)`
```

For types other than [`int`], you can use [`StepProgression`].
This requires the type to implement [`Step`] and [`Comparable`].

<!-- dart -->

[`Comparable`]: https://api.dart.dev/dart-core/Comparable-class.html
[`double`]: https://api.dart.dev/dart-core/double-class.html
[`int`]: https://api.dart.dev/dart-core/int-class.html
[`Iterable`]: https://api.dart.dev/dart-core/Iterable-class.html
[`num`]: https://api.dart.dev/dart-core/num-class.html

<!-- deranged -->

[`AnyRange`]: https://pub.dev/documentation/deranged/latest/deranged/AnyRange-class.html
[`Bound`]: https://pub.dev/documentation/deranged/latest/deranged/Bound-class.html
[`comparableExtension.rangeTo`]: https://pub.dev/documentation/deranged/latest/deranged/ComparableExtension/rangeTo.html
[`comparableExtension.rangeUntil`]: https://pub.dev/documentation/deranged/latest/deranged/ComparableExtension/rangeUntil.html
[`DoubleRange`]: https://pub.dev/documentation/deranged/latest/deranged/DoubleRange-class.html
[`DoubleRangeFrom`]: https://pub.dev/documentation/deranged/latest/deranged/DoubleRangeFrom-class.html
[`DoubleRangeFull`]: https://pub.dev/documentation/deranged/latest/deranged/DoubleRangeFull-class.html
[`DoubleRangeInclusive`]: https://pub.dev/documentation/deranged/latest/deranged/DoubleRangeInclusive-class.html
[`DoubleRangeTo`]: https://pub.dev/documentation/deranged/latest/deranged/DoubleRangeTo-class.html
[`DoubleRangeUntil`]: https://pub.dev/documentation/deranged/latest/deranged/DoubleRangeUntil-class.html
[`ExclusiveBound`]: https://pub.dev/documentation/deranged/latest/deranged/ExclusiveBound-class.html
[`InclusiveBound`]: https://pub.dev/documentation/deranged/latest/deranged/InclusiveBound-class.html
[`IntRange.inclusive`]: https://pub.dev/documentation/deranged/latest/deranged/IntRange/IntRange.inclusive.html
[`intRange.stepBy`]: https://pub.dev/documentation/deranged/latest/deranged/IntRange/stepBy.html
[`IntRange`]: https://pub.dev/documentation/deranged/latest/deranged/IntRange-class.html
[`IntRangeFrom`]: https://pub.dev/documentation/deranged/latest/deranged/IntRangeFrom-class.html
[`IntRangeFull`]: https://pub.dev/documentation/deranged/latest/deranged/IntRangeFull-class.html
[`IntRangeUntil`]: https://pub.dev/documentation/deranged/latest/deranged/IntRangeUntil-class.html
[`progression.endInclusive`]: https://pub.dev/documentation/deranged/latest/deranged/Progression/endInclusive.html
[`progression.start`]: https://pub.dev/documentation/deranged/latest/deranged/Progression/start.html
[`progression.step`]: https://pub.dev/documentation/deranged/latest/deranged/Progression/step.html
[`Progression`]: https://pub.dev/documentation/deranged/latest/deranged/Progression-class.html
[`Range`]: https://pub.dev/documentation/deranged/latest/deranged/Range-class.html
[`RangeBounds`]: https://pub.dev/documentation/deranged/latest/deranged/RangeBounds-class.html
[`RangeFrom`]: https://pub.dev/documentation/deranged/latest/deranged/RangeFrom-class.html
[`RangeFull`]: https://pub.dev/documentation/deranged/latest/deranged/RangeFull-class.html
[`RangeInclusive`]: https://pub.dev/documentation/deranged/latest/deranged/RangeInclusive-class.html
[`RangeTo`]: https://pub.dev/documentation/deranged/latest/deranged/RangeTo-class.html
[`RangeUntil`]: https://pub.dev/documentation/deranged/latest/deranged/RangeUntil-class.html
[`Step`]: https://pub.dev/documentation/deranged/latest/deranged/Step-class.html
[`StepProgression`]: https://pub.dev/documentation/deranged/latest/deranged/StepProgression-class.html
[`UnboundedBound`]: https://pub.dev/documentation/deranged/latest/deranged/UnboundedBound-class.html
