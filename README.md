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

### Working with ranges

Beyond `contains(…)`, `containsRange(…)`, and `intersects(…)`, every range supports:

```dart
0.rangeUntil(10).clamp(42);            // 9 — limits a value to the range
0.rangeUntil(10).shift(5);             // IntRange(5..<15)
0.rangeUntil(10).copyWith(end: 20);    // IntRange(0..<20)
0.rangeUntil(10).copyWithBounds(       // AnyRange(0..=20)
  endBound: const InclusiveBound(20),
);
0.rangeUntil(10).reverse;              // 9, 8, 7, … 0
0.rangeUntil(1).isSingle;              // true
```

`clamp(…)` needs a bound it can land on, so it exists wherever that's well-defined: on any range whose values implement [`Step`], on [`RangeInclusive`]/[`RangeFrom`]/[`RangeTo`] for any [`Comparable`], and on the [`int`]/[`double`] equivalents.
It's deliberately absent from [`DoubleRange`] and [`DoubleRangeUntil`]: There is no largest [`double`] below an exclusive end.

`mapBounds(…)` and `castBounds(…)` convert the bound values while preserving the range's shape:

```dart
const RangeInclusive(1, 3).mapBounds((it) => it * 2); // RangeInclusive(2..=6)
```

Note that the mapper must preserve the order of values, or the resulting bounds end up swapped.

## Range sets

A single range can't describe values with a gap in the middle, so removing part of a range, or uniting two that don't touch, produces a [`RangeSet`]:

```dart
IntRange(0, 3) | IntRange(7, 10);  // RangeSet{0..<3, 7..<10}
IntRange(0, 10) - IntRange(3, 5);  // RangeSet{0..<3, 5..<10}
IntRange(0, 3).span(IntRange(7, 10)); // AnyRange(0..<10) (bridges the gap)
```

Ranges and sets share a base class, [`RangeLike`], which is where the set algebra lives.
The operators therefore work between the two interchangeably, in either direction:

```dart
final set = RangeSet.of([IntRange(0, 5), IntRange(10, 15)]);

~IntRange(0, 5);                 // RangeSet{..<0, 5..}
IntRange(3, 12) | set;           // RangeSet{0..<15}
set & IntRange(3, 12);           // RangeSet{3..<5, 10..<12}
set.intersects(IntRange(3, 12)); // true
```

They mirror the bitwise operators because that's exactly what set algebra is: [`|`][`rangeLike.|`] union, [`&`][`rangeLike.&`] intersection, [`-`][`rangeLike.-`] difference, and [`~`][`rangeLike.~`] complement.
All of them return a [`RangeSet`], since none can generally be described by a single range.

When you do want one range back, [`bounds`][`rangeLike.bounds`] and [`span(…)`][`rangeLike.span`] bridge the gaps, and [`intersect(…)`][`rangeBounds.intersect`] gives the exact overlap of two ranges without building a set:

```dart
set.bounds;               // AnyRange(0..<15), covering the gaps too
rangeA.span(rangeB);      // smallest range covering both
rangeA.intersect(rangeB); // their overlap, empty if disjoint
```

The contained [`ranges`][`rangeSet.ranges`] are always normalized: A set drops empty ranges, merges overlapping and adjoining ones, and sorts the rest.
Two sets are equal exactly when they describe the same values, however they were built.

Adjoining is decided from the bounds alone, so `0..<5` and `5..<10` merge but `0..=4` and `5..=9` don't – nothing there knows that no [`int`] lies between 4 and 5.
Supplying that knowledge closes those gaps too:

```dart
fooSet.coalesced;         // for types implementing `Step`
intSet.coalescedAsInts;   // for `RangeSet<num>` holding `int` ranges
set.coalescedBy(next);    // for anything else
```

[`coalescedAsInts`][`rangeSet.coalescedAsInts`] is spelled out rather than named `coalesced` because a [`RangeSet<num>`][`RangeSet`] can just as well hold [`double`] ranges ([`IntRange`] and [`DoubleRange`] are both [`Range<num>`][`Range`]) and stepping a [`double`] set by one would be wrong.

## Progressions

Unlike ranges, [`Progression`]s contain only values that are multiples of a given step size.
This [`step`][`progression.step`] supports both positive and negative values.
All progressions implement [`Iterable<T>`][`Iterable`], so you can use them in `for` loops and other iterable operations.

A progression runs from [`start`][`progression.start`] to [`endInclusive`][`progression.endInclusive`] – both are part of it, though [`endInclusive`][`progression.endInclusive`] is only reached if it's a whole number of steps away from [`start`][`progression.start`].

`reverse` yields the same values in the opposite order. It starts at the progression's `last` value rather than its `endInclusive`, which are only the same when `endInclusive` is a whole number of steps away from `start`:

```dart
const IntProgression(0, 9, 2);          // 0, 2, 4, 6, 8
const IntProgression(0, 9, 2).reverse;  // 8, 6, 4, 2, 0
```

You can create a progression using [`start.rangeTo(end).stepBy(step)`][`intRange.stepBy`] or use their constructor directly:

```dart
0.rangeTo(10).stepBy(2); // 0, 2, 4, 6, 8, 10
10.rangeTo(0).stepBy(-2); // 10, 8, 6, 4, 2, 0
// Equivalent: `IntProgression(10, 0, -2)`
```

For types other than [`int`], you can mix in [`Step`] and use [`StepProgression`].

## Implementing `Step`

The generic ranges only need [`Comparable`] for [`contains(…)`][`rangeBounds.contains`] and friends.
Anything that walks a range one value at a time – iterating, [`length`][`rangeInclusiveOfStepExtension.length`], indexing, [`reverse`][`rangeInclusiveOfStepExtension.reverse`], progressions, and converting between inclusive and exclusive bounds – additionally needs to know each value's successor and predecessor.
That's [`Step`]:

```dart
class Chapter with Step<Chapter> {
  const Chapter(this.number);

  final int number;

  @override
  Chapter? stepBy(int count) {
    final result = number + count;
    return result >= 1 ? Chapter(result) : null; // no chapter before the first
  }
  @override
  int stepsUntil(Chapter other) => other.number - number;
  @override
  int compareTo(Chapter other) => number.compareTo(other.number);

  // `==` and `hashCode` must be value-based – range values are compared a lot.
  @override
  bool operator ==(Object other) => other is Chapter && number == other.number;
  @override
  int get hashCode => number.hashCode;
}
```

Three members carry the contract:

- `stepBy(count)` returns the value `count` steps away, or `null` if there is none. It must be consistent with `stepsUntil(…)`: `a.stepBy(a.stepsUntil(b)) == b`.
- `stepsUntil(other)` returns how many steps `other` is away, negative if it comes first.
- `compareTo(other)` must order values the same way `stepBy(…)` walks them.

Mix in [`StepUnlimited`] instead when your type has no first or last value.
It narrows `stepBy(…)` to a non-nullable return, so the range API stops handing you nullable results.

This is also the workaround for [`int`] not being able to implement [`Step`] itself (see the note above): wrap it in a type of your own, which usually models the domain better anyway.

See [`example/main.dart`][`example`] for the full, runnable version, and the sibling [Chrono] package for a real-world set – its `Date`, `Year`, `YearMonth`, and `YearWeek` mix in [`StepUnlimited`], while its bounded `Weekday` mixes in [`Step`].

## Serialization

Every concrete range and progression type has a matching `…AsMapCodec`.
Each is a [`Codec`] and a [`JsonConverter`], so it works with both [`Codec`]-based APIs and `json_serializable`.

Types that are already JSON-encodable need no configuration:

```dart
const IntRangeAsMapCodec().encode(IntRange(2, 7)); // {"start": 2, "end": 7}
const IntProgressionAsMapCodec().encode(IntProgression(0, 10, 2));
// {"start": 0, "endInclusive": 10, "step": 2}
```

For other types, pass an `innerCodec` for the bound values. [`FunctionBasedCodec`] saves you from declaring a [`Codec`] class:

```dart
const dateRangeCodec = RangeAsMapCodec<DateTime>(
  FunctionBasedCodec(encode: _encodeDate, decode: _decodeDate),
);

Object? _encodeDate(DateTime it) => it.toIso8601String();
DateTime _decodeDate(Object? it) => DateTime.parse(it! as String);
```

[`AnyRangeAsMapCodec`] is the exception to the `{"start": …, "end": …}` shape: since [`AnyRange`] supports any combination of bounds, it encodes each bound's *kind* alongside its value using [`BoundAsMapCodec`]:

```json
{"start": {"type": "exclusive", "value": 2}, "end": {"type": "unbounded"}}
```

<!-- dart -->

[`Codec`]: https://api.dart.dev/dart-convert/Codec-class.html
[`Comparable`]: https://api.dart.dev/dart-core/Comparable-class.html
[`double`]: https://api.dart.dev/dart-core/double-class.html
[`int`]: https://api.dart.dev/dart-core/int-class.html
[`Iterable`]: https://api.dart.dev/dart-core/Iterable-class.html
[`num`]: https://api.dart.dev/dart-core/num-class.html

<!-- other packages -->

[`JsonConverter`]: https://pub.dev/documentation/json_annotation/latest/json_annotation/JsonConverter-class.html

<!-- other -->

[Chrono]: https://github.com/JonasWanke/chrono
[`example`]: https://github.com/JonasWanke/deranged/blob/main/example/main.dart

<!-- deranged -->

[`AnyRange`]: https://pub.dev/documentation/deranged/latest/deranged/AnyRange-class.html
[`AnyRangeAsMapCodec`]: https://pub.dev/documentation/deranged/latest/deranged/AnyRangeAsMapCodec-class.html
[`Bound`]: https://pub.dev/documentation/deranged/latest/deranged/Bound-class.html
[`BoundAsMapCodec`]: https://pub.dev/documentation/deranged/latest/deranged/BoundAsMapCodec-class.html
[`FunctionBasedCodec`]: https://pub.dev/documentation/deranged/latest/deranged/FunctionBasedCodec-class.html
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
[`rangeBounds.intersect`]: https://pub.dev/documentation/deranged/latest/deranged/RangeBounds/intersect.html
[`rangeLike.&`]: https://pub.dev/documentation/deranged/latest/deranged/RangeLike/operator_bitwise_and.html
[`rangeLike.-`]: https://pub.dev/documentation/deranged/latest/deranged/RangeLike/operator_minus.html
[`rangeLike.bounds`]: https://pub.dev/documentation/deranged/latest/deranged/RangeLike/bounds.html
[`rangeLike.span`]: https://pub.dev/documentation/deranged/latest/deranged/RangeLike/span.html
[`rangeLike.|`]: https://pub.dev/documentation/deranged/latest/deranged/RangeLike/operator_bitwise_or.html
[`rangeLike.~`]: https://pub.dev/documentation/deranged/latest/deranged/RangeLike/operator_unary_bitwise_negate.html
[`RangeLike`]: https://pub.dev/documentation/deranged/latest/deranged/RangeLike-class.html
[`rangeSet.coalescedAsInts`]: https://pub.dev/documentation/deranged/latest/deranged/RangeSetOfIntExtension/coalescedAsInts.html
[`rangeSet.ranges`]: https://pub.dev/documentation/deranged/latest/deranged/RangeSet/ranges.html
[`RangeSet`]: https://pub.dev/documentation/deranged/latest/deranged/RangeSet-class.html
[`Range`]: https://pub.dev/documentation/deranged/latest/deranged/Range-class.html
[`rangeBounds.contains`]: https://pub.dev/documentation/deranged/latest/deranged/RangeBounds/contains.html
[`RangeBounds`]: https://pub.dev/documentation/deranged/latest/deranged/RangeBounds-class.html
[`RangeFrom`]: https://pub.dev/documentation/deranged/latest/deranged/RangeFrom-class.html
[`RangeFull`]: https://pub.dev/documentation/deranged/latest/deranged/RangeFull-class.html
[`RangeInclusive`]: https://pub.dev/documentation/deranged/latest/deranged/RangeInclusive-class.html
[`rangeInclusiveOfStepExtension.length`]: https://pub.dev/documentation/deranged/latest/deranged/RangeInclusiveOfStepExtension/length.html
[`rangeInclusiveOfStepExtension.reverse`]: https://pub.dev/documentation/deranged/latest/deranged/RangeInclusiveOfStepExtension/reverse.html
[`RangeTo`]: https://pub.dev/documentation/deranged/latest/deranged/RangeTo-class.html
[`RangeUntil`]: https://pub.dev/documentation/deranged/latest/deranged/RangeUntil-class.html
[`Step`]: https://pub.dev/documentation/deranged/latest/deranged/Step-mixin.html
[`StepProgression`]: https://pub.dev/documentation/deranged/latest/deranged/StepProgression-class.html
[`StepUnlimited`]: https://pub.dev/documentation/deranged/latest/deranged/StepUnlimited-mixin.html
[`UnboundedBound`]: https://pub.dev/documentation/deranged/latest/deranged/UnboundedBound-class.html
