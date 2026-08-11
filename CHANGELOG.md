# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- Template:
## NEW · 2025-xx-xx

### ⚠️ BREAKING CHANGES
### 🎉 New Features
### ⚡ Changes
### 🐛 Bug Fixes
### ⏩ Performance Improvements
### 📜 Documentation updates
### 🏗️ Refactoring
### 📦 Build & CI
-->

## 0.1.0 · 2026-08-11

### ⚠️ BREAKING CHANGES

**`RangeTo` changed meaning.**
Naming now follows one convention throughout: **`until` means an exclusive end, `to` means an inclusive end**, in class names as well as method names. Previously, `RangeTo(5)` was `..<5`, while `x.rangeTo(5)` was `x..=5`, i.e., `to` meant opposite things depending on where you read it. ([`4561e4a`](https://github.com/JonasWanke/deranged/commit/4561e4a4126856d7345c8dd80ee8cd644e2d97a1))

| Old                      | New                | Meaning |
| :----------------------- | :----------------- | :------ |
| `RangeTo`                | `RangeUntil`       | `..<x`  |
| `RangeToInclusive`       | `RangeTo`          | `..=x`  |
| `IntRangeTo`             | `IntRangeUntil`    | `..<x`  |
| `DoubleRangeTo`          | `DoubleRangeUntil` | `..<x`  |
| `DoubleRangeToInclusive` | `DoubleRangeTo`    | `..=x`  |

⚠️ `RangeTo` and `DoubleRangeTo` are **reused rather than retired**, so existing code that names them still compiles but now builds an *inclusive* range. Search your code for `RangeTo` before upgrading. The `x.rangeUntil(…)`/`x.rangeTo(…)` methods are unchanged.

Matching factory renames on `RangeBounds`: `RangeBounds.to(…)` → `RangeBounds.until(…)` and `RangeBounds.toInclusive(…)` → `RangeBounds.to(…)`. ([`4561e4a`](https://github.com/JonasWanke/deranged/commit/4561e4a4126856d7345c8dd80ee8cd644e2d97a1), [`41995a3`](https://github.com/JonasWanke/deranged/commit/41995a3df833ce7114eb7aa42057c573e9472980))

**Other breaking changes:**

- Every extension declaration was renamed from a `…Extension` suffix to a `Deranged…` prefix: `IntExtension` → `DerangedInt`, `ComparableExtension` → `DerangedComparable`, `RangeOfStepExtension` → `DerangedRangeOfStep`, and so on. ([`715a4bb`](https://github.com/JonasWanke/deranged/commit/715a4bb557077a95635ca01bfa25bdfda7a75feb))
- `Step` was split into `Step` and `StepUnlimited`, and both became mixins instead of an `abstract interface class`. `Step`'s stepping methods return `null` when the step can't be taken, while `StepUnlimited` (for types like `int` that can always step) narrows them to non-nullable returns. ([`2456dad`](https://github.com/JonasWanke/deranged/commit/2456dade37cedc87fbf2e12ef1bece93b6b30f91), [`cd171ce`](https://github.com/JonasWanke/deranged/commit/cd171ce9b7103bb7967c97ddc4d3b6405d626791))
- `Progression.end` was renamed to `Progression.endInclusive`. The name said exclusive while `length`, `last`, `contains` and `toString` all treated it as inclusive. Affects `IntProgression` and `StepProgression`. ([`4561e4a`](https://github.com/JonasWanke/deranged/commit/4561e4a4126856d7345c8dd80ee8cd644e2d97a1))
- The bound-conversion getters on `RangeBounds` dropped their `As` infix: `startAsInclusive` → `startInclusive`, `startAsExclusive` → `startExclusive`, `endAsInclusive` → `endInclusive`, `endAsExclusive` → `endExclusive`. They now match the names the concrete range classes already used. ([`eabe3e2`](https://github.com/JonasWanke/deranged/commit/eabe3e269e6a836940024dad1df8a3990bf921d7))
- `IntRange` no longer implements `IntProgression`. The two used different `==` implementations, which made equality asymmetric (`IntProgression(0, 3, 1) == IntRange(0, 3)` was `true`, the reverse `false`). `IntRange.step` was removed along with it; use `IntRange.stepBy(…)` to get an `IntProgression`. ([`9e25702`](https://github.com/JonasWanke/deranged/commit/9e2570233384558c134c3efd9002f7e446421961))
- `IntRangeUntil.contains(…)` (formerly `IntRangeTo`) now excludes its end, matching its exclusive `endBound` and its `..<end` representation. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `DoubleRange.contains(…)` now excludes its end, matching its exclusive `endBound`. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `double.rangeTo(…)` now returns a `DoubleRangeInclusive` instead of the exclusive `DoubleRange`, matching its documented inclusive semantics. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- The `endExclusive` getters on the two unbounded-start `double` ranges were removed – they subtracted `1` from a `double` end, which is meaningless. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `IntRangeFrom.length` now throws an `UnsupportedError` instead of looping forever. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- Removed `rangeToWithLength(…)` from both `DerangedStep` and `DerangedStepUnlimited`. A range's length is only `end - start` when the end is exclusive, so a closed range built from a length contained `length + 1` values – the name did not match the result. Use `rangeUntilWithLength(…)`, followed by `.inclusive` if you need a `RangeInclusive`. ([`9d9c323`](https://github.com/JonasWanke/deranged/commit/9d9c3235947718edafa645bcb44a68dcda1c693c))
- Renamed `int.rangeWithLength(…)` to `int.rangeUntilWithLength(…)`, matching `DerangedStep` and making the exclusive end explicit. ([`bdfb268`](https://github.com/JonasWanke/deranged/commit/bdfb268c050f615576e28b6586c1159296db2355))
- `RangeInclusive.operator |` was the smallest range covering both operands, bridging any gap between them. `|` is now the true union on all of `RangeBounds` and returns a `RangeSet`, so gaps survive. The old behavior moved to `RangeBounds.span(…)`, which returns an `AnyRange`. ⚠️ Both spellings still compile where the result is only passed on, so check any `|` on ranges when upgrading. ([`7a923c6`](https://github.com/JonasWanke/deranged/commit/7a923c60b6f665c28c8c4b301a4aa9a1676a89cf), [`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- `Iterable<RangeInclusive>.union` was renamed to `.span`, matching the above, and still returns a `RangeInclusive?`. For the true union, use `.asRangeSet`. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- `RangeBounds` and `RangeSet` now share a `RangeLike` base class, which carries the set algebra. `|`, `&`, `-`, `~`, `contains(…)`, `containsAll(…)`, `intersects(…)`, `isEmpty`, `isFull`, `bounds`, `span(…)`, `asRangeSet`, `mapBounds(…)`, and `castBounds(…)` all live there, so they accept and mix ranges and sets freely: `~someRange`, `range | set`, and `set & range` all work now. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- `RangeBounds.isUnbounded` was renamed to `isFull`. It means "describes every value", which for a set isn't the same as being unbounded: `{..<0, 5..}` has no bound in either direction yet is missing everything in between. The old name also collided with `Bound.isUnbounded`, which is about a single bound. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- `RangeBounds.containsRange(…)` and `RangeSet.containsRange(…)` were renamed to `containsAll(…)`, since they now accept a set as well as a range. `RangeBounds.containsAll(…)` also returns `true` for an empty argument, which the old `containsRange(…)` got wrong. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- `RangeInclusive.operator &` returned a precise `RangeInclusive?`; `&` now comes from `RangeLike` and returns a `RangeSet`. The precise pairwise form is `RangeBounds.intersect(…)`, which returns an `AnyRange` that is empty when the ranges are disjoint. It pairs with `span(…)` exactly as `&` pairs with `|`. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- `RangeSet.span` (the getter for the covering range) was renamed to `bounds`, freeing `span` to mean the same thing everywhere: `a.span(b)` is the smallest range covering both, and now works between ranges and sets in either direction. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- `RangeBoundsAsRangeSetExtension` is gone; `asRangeSet` is a `RangeLike` member. `IterableOfRangeBoundsExtension` became `DerangedIterableOfRangeLike`, and `RangeSet.of(…)`/`RangeSet.single(…)` accept sets as well as ranges. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7), [`715a4bb`](https://github.com/JonasWanke/deranged/commit/715a4bb557077a95635ca01bfa25bdfda7a75feb))
- The range codecs take a single optional positional `innerCodec` instead of the `innerCodec` + `encodeInner` + `decodeInner` named triple, which could previously be combined in ways an `assert` had to reject. `RangeAsMapCodec(innerCodec: c)` becomes `RangeAsMapCodec(c)`; to pass functions, wrap them in the new `FunctionBasedCodec`. ([`22e6570`](https://github.com/JonasWanke/deranged/commit/22e6570724ee85eca0b897256b2c4586f89b107d))

### 🎉 New Features

#### Ranges

- Added the `IntRange.inclusive(start, endInclusive)` constructor. `int` is discrete, so half-open and closed ranges represent the same values; `IntRange` stays the single canonical half-open type and this constructor covers the inclusive spelling. `int.rangeTo(…)` now delegates to it. ([`9e25702`](https://github.com/JonasWanke/deranged/commit/9e2570233384558c134c3efd9002f7e446421961))
- Added `isEmpty` and `isNotEmpty` to `RangeBounds`, so a range can be tested without materializing its values. ([`93f1bf7`](https://github.com/JonasWanke/deranged/commit/93f1bf7c4f2e1125170dac65d754dbd4677d6434))
- Added `isSingle`, which reports whether a range describes exactly one value, first to `RangeInclusive` ([`8faa051`](https://github.com/JonasWanke/deranged/commit/8faa051d8d67e9b83f70d3b83018f4b4e469c173)) and then to `Range` (for `Step` values), `IntRange`, and `DoubleRangeInclusive` ([`87ceefe`](https://github.com/JonasWanke/deranged/commit/87ceefeee5524df252f74a1f871658030e198af4)).
- Added `clamp(…)`, which limits a value to a range. It's available wherever it's well-defined: on any `RangeBounds` whose values implement `Step`, on `RangeInclusive`/`RangeFrom`/`RangeTo` for any `Comparable`, and on the `int`/`double` equivalents. It's deliberately absent from `DoubleRange` and `DoubleRangeUntil`, since there is no largest `double` below an exclusive end. ([`39962f3`](https://github.com/JonasWanke/deranged/commit/39962f3303b787f5b00a5601cdbd3fa735d7daad))
- Added `mapBounds(…)` and `castBounds(…)` on `RangeBounds`, which convert the bound values while preserving the range's shape. They aren't called `map`/`cast` because `IntRange` & co. also implement `Iterable`, where those names mean mapping the range's *elements*. The `int` and `double` ranges narrow `mapBounds(…)`, so the mapper receives an `int` or `double` rather than a `num`. ([`8d9d75f`](https://github.com/JonasWanke/deranged/commit/8d9d75f1a0912699114262b4391ec34b0d11a5c7))
- Added `shift(…)`, which moves a range's bounds by an offset. On `Step` types it returns `null` if a bound can't be stepped that far; on `StepUnlimited`, `int`, and `double` types it's non-nullable. ([`eadb75f`](https://github.com/JonasWanke/deranged/commit/eadb75f76bca3a24f3a6b3fc7929d1def7fb1eda))
- Added `copyWith(…)` on the ranges with both a start and an end (`Range`, `RangeInclusive`, `IntRange`, `DoubleRange`, `DoubleRangeInclusive`), which narrow it to their own return and parameter types. Single-bound ranges don't have it – `RangeFrom(newStart)` is already as short as a `copyWith` call. ([`5ddd4c4`](https://github.com/JonasWanke/deranged/commit/5ddd4c419137daab9a048868b5ffebc797ee2b6f))
- Added `copyWithBounds(…)` on `RangeBounds`, which replaces whole `Bound`s rather than their values. It returns an `AnyRange`, since replacing a bound can change the range's shape. ([`5ddd4c4`](https://github.com/JonasWanke/deranged/commit/5ddd4c419137daab9a048868b5ffebc797ee2b6f))
- Added `reverse` to `Range` and `RangeInclusive` of `Step` values ([`b9632d6`](https://github.com/JonasWanke/deranged/commit/b9632d63eabc03958eeae5e853a4a10dfeabdf5d), [`5c4686f`](https://github.com/JonasWanke/deranged/commit/5c4686fdf389919fb01790ea5f73e454bf79d00f)), then to `IntRange`, `IntProgression`, and `StepProgression` ([`e5e9b3b`](https://github.com/JonasWanke/deranged/commit/e5e9b3bd86aa36d8e690c42b0e62e00a00f4e803)). A progression's `reverse` starts at its `last` value rather than its `endInclusive`, so both contain exactly the same values.
- Added factory constructors on `RangeBounds` – `.full()`, `.from(…)`, `.until(…)`, `.to(…)`, `.inclusiveOrUnbounded(…)`, `.exclusiveOrUnbounded(…)` – so ranges can be written with dot shorthands, and made them `const` where possible. ([`41995a3`](https://github.com/JonasWanke/deranged/commit/41995a3df833ce7114eb7aa42057c573e9472980), [`c4780f1`](https://github.com/JonasWanke/deranged/commit/c4780f19dfac4f7a5df790c632cce756987f7b4f), [`d0783f7`](https://github.com/JonasWanke/deranged/commit/d0783f720c6c5e44aec1345e5ae26fbb352bc640))
- Added `AnyRange.inclusiveOrUnbounded(…)` and `AnyRange.exclusiveOrUnbounded(…)`, which build a range from nullable bound values. ([`f6b4d41`](https://github.com/JonasWanke/deranged/commit/f6b4d412a6df8719329a0f48bc150d766cd89509))
- `RangeBounds` and `Progression` now override `==`, `hashCode`, and `toString()`. ([`a6ac502`](https://github.com/JonasWanke/deranged/commit/a6ac502b2cbaf19523405b6cdc42938185662847))

#### Iteration

- Added `.iter` on ranges of `Step` values, which iterates the range one value at a time. ([`6f8f212`](https://github.com/JonasWanke/deranged/commit/6f8f212c34c4b4a9a8464387e56ba09925d6c5e3))
- Added `stepBy(…)` on ranges of `Step` values, producing a `StepProgression`. ([`6d7a1cd`](https://github.com/JonasWanke/deranged/commit/6d7a1cd143c519ba84ab9e67cdc938b7961f140b))
- Added `IntProgression.stepBy(…)`, for parity with `StepProgression.stepBy(…)`. ([`e5e9b3b`](https://github.com/JonasWanke/deranged/commit/e5e9b3bd86aa36d8e690c42b0e62e00a00f4e803))
- Added `length` to the iterable ranges of `Step` values. ([`61d3d25`](https://github.com/JonasWanke/deranged/commit/61d3d259e5efd832f4945ad311cf4732606d957f))
- Added `operator []` to the iterable ranges and to `Progression`, as a shorthand for `elementAt(…)`. ([`18df627`](https://github.com/JonasWanke/deranged/commit/18df627eb9b6bdb828e744068f980fd3aa09c716), [`899f4e1`](https://github.com/JonasWanke/deranged/commit/899f4e17a72870f9db1a4c271aeb1e73aee1903a))
- Added `rangeUntilWithLength(…)` on `int` and on `Step`/`StepUnlimited` values, which builds a range from a start and a length. ([`3ee643d`](https://github.com/JonasWanke/deranged/commit/3ee643df0b4b7b4b1f0ee4fb3affde66661eed55), [`d3623a0`](https://github.com/JonasWanke/deranged/commit/d3623a08412048eea309e156017944159ef5dfed))

#### `Step` and `Bound`

- Added `StepUnlimited`, the counterpart of `Step` for types that can always take a step, along with the `DerangedStep` and `DerangedStepUnlimited` extensions carrying `previous`, `next`, and the range-building helpers. ([`2456dad`](https://github.com/JonasWanke/deranged/commit/2456dade37cedc87fbf2e12ef1bece93b6b30f91), [`1ff8e26`](https://github.com/JonasWanke/deranged/commit/1ff8e2635e4b09be5de0daa38bd5a924d537c143), [`2d00eb1`](https://github.com/JonasWanke/deranged/commit/2d00eb1e86e49068d42a6e3938f5f736311ff99d))
- Added inclusive/exclusive bound conversion for ranges of `Step` values: the `startInclusive`, `startExclusive`, `endInclusive`, and `endExclusive` getters, plus the `.inclusive`/`.exclusive` conversions between `Range` and `RangeInclusive`. ([`27e52ed`](https://github.com/JonasWanke/deranged/commit/27e52ed88673bf04262988c0457a4e1530fcf365), [`43a0ccc`](https://github.com/JonasWanke/deranged/commit/43a0ccc34ae0c81ff8a8af73501a38a4f886c484), [`8d79ef6`](https://github.com/JonasWanke/deranged/commit/8d79ef65100f19dc46552b7c4ceea7e08f6020b8))
- Added `Bound` factory constructors – `.inclusive(…)`, `.exclusive(…)`, `.unbounded()`, `.inclusiveOrUnbounded(…)`, `.exclusiveOrUnbounded(…)` – usable with dot shorthands. ([`71f6d48`](https://github.com/JonasWanke/deranged/commit/71f6d4809021ba05f6d587cb99e29cfe56034712), [`c4780f1`](https://github.com/JonasWanke/deranged/commit/c4780f19dfac4f7a5df790c632cce756987f7b4f))
- Added `Bound.valueOrNull` ([`d47b002`](https://github.com/JonasWanke/deranged/commit/d47b002509d5ce8ae58971577ccb5d3e5c515ab3)), `Bound.map(…)`/`Bound.cast(…)` ([`171d952`](https://github.com/JonasWanke/deranged/commit/171d952255e362bf1a0ba4f9dd79707e58d26b23)), and `==`/`hashCode` overrides ([`94c5898`](https://github.com/JonasWanke/deranged/commit/94c5898414c7513c369f974867a4519457156269)).
- Added bound-level helpers on `Bound`, which the range and set logic is built from: the static `Bound.compareStarts(…)`/`Bound.compareEnds(…)` order two bounds by where a range starting/ending there begins/stops, `Bound.laterStart(…)`/`Bound.earlierEnd(…)` pick the narrower of two, `Bound.adjoins(end, start)` reports whether two ranges meet without a gap, and `Bound.inverted` turns a start bound into the end bound of everything before it and vice versa. ([`78aa979`](https://github.com/JonasWanke/deranged/commit/78aa979dc8cd426f875ce27b11953a1094021c99), [`24a9dbc`](https://github.com/JonasWanke/deranged/commit/24a9dbc918b3eec63fba62e061e914a7b1496ebd))

#### Set operations

- Added `RangeSet`, a normalized set of disjoint ranges, with the full set algebra spelled as the bitwise operators – `|` union, `&` intersection, `-` difference, and `~` complement – plus `contains(…)`, `containsAll(…)`, `intersects(…)`, `bounds`, and `mapBounds(…)`. It stores `AnyRange`s, so unbounded and exclusive bounds work throughout, which is what makes `~` expressible. Normalization drops empty ranges, merges overlapping and adjoining ones, and sorts the rest, so two sets are equal exactly when they describe the same values. Since the ranges stay sorted, `|` and `&` are a single linear sweep rather than a re-sort. ([`7a923c6`](https://github.com/JonasWanke/deranged/commit/7a923c60b6f665c28c8c4b301a4aa9a1676a89cf))
- Added `RangeSet.coalescedBy(…)`, which merges ranges with no values between them. Normalization only compares bound values, so it keeps `{0..=4, 5..=9}` apart; `coalescedBy(…)` takes the successor function that decides such cases. `DerangedRangeSetOfStep.coalesced` derives it from a `Step` type, and `DerangedRangeSetOfInt.coalescedAsInts` covers `int` sets – spelled out because a `RangeSet<num>` can just as well hold `double` ranges, which must not be stepped by one. ([`7a923c6`](https://github.com/JonasWanke/deranged/commit/7a923c60b6f665c28c8c4b301a4aa9a1676a89cf))
- Added `RangeBounds.asRangeSet` and `Iterable<RangeBounds>.asRangeSet`, and `RangeSetAsListCodec`. ([`7a923c6`](https://github.com/JonasWanke/deranged/commit/7a923c60b6f665c28c8c4b301a4aa9a1676a89cf))
- `RangeSet` gained `isFull`, the counterpart of `isEmpty`: whether it describes every value. A set is full exactly when it normalized down to a single full range, so a set with a gap is not full even though its `bounds` are. ([`f199321`](https://github.com/JonasWanke/deranged/commit/f199321ee6793680392e867d8627b440ccc69db7))
- Added the pairwise `|` and `&` on `RangeInclusive`, `&` on ranges of `Step` values, and `intersectRangeBounds(…)`, ahead of the general `RangeLike` algebra. ([`715dcb2`](https://github.com/JonasWanke/deranged/commit/715dcb28d27aa3bf3ff270f5f14fe00814f01d30), [`759832b`](https://github.com/JonasWanke/deranged/commit/759832b46a26dd5a59f105bd8944a3329980dac5), [`d38153c`](https://github.com/JonasWanke/deranged/commit/d38153c57df8cbc5130161109b3610eaac0f1e6a))
- Added `DerangedIterableOfRangeInclusive`, with `span` and `intersection` over an iterable of ranges. ([`aeb981b`](https://github.com/JonasWanke/deranged/commit/aeb981b9c9bc6d61bc5c853e4540d69f3487540e))

#### Serialization

- Added codecs for the range and progression types: `RangeAsMapCodec`, `RangeInclusiveAsMapCodec`, `IntRangeAsMapCodec`, `DoubleRangeAsMapCodec`, `RangeFromAsMapCodec`, `RangeUntilAsMapCodec`, `RangeToAsMapCodec`, `DoubleRangeInclusiveAsMapCodec`, `StepProgressionAsMapCodec`, and `IntProgressionAsMapCodec`. ([`101342b`](https://github.com/JonasWanke/deranged/commit/101342b8059c78760a6d267185e4061455d5fde2), [`44ebd4d`](https://github.com/JonasWanke/deranged/commit/44ebd4d390fe3cadb0f395d692b737729eeaf34b), [`8a20a7a`](https://github.com/JonasWanke/deranged/commit/8a20a7ab836fb51c8d3fac89a67a4ce537d42a11), [`d46b2ad`](https://github.com/JonasWanke/deranged/commit/d46b2ad7e6a42d124307cce1e7fe09552b67ffe0))
- Added `BoundAsMapCodec` and `AnyRangeAsMapCodec`. Unlike the other range codecs, these round-trip the *kind* of each bound alongside its value (`{"type": "inclusive", "value": …}`), so every range shape can be serialized. ([`d46b2ad`](https://github.com/JonasWanke/deranged/commit/d46b2ad7e6a42d124307cce1e7fe09552b67ffe0))
- Every codec takes an optional `innerCodec` for the bound values, so ranges of custom types can be serialized. ([`4690fbb`](https://github.com/JonasWanke/deranged/commit/4690fbb1418d9224dd206f3e6e02c38e15102fd9))
- Added `FunctionBasedCodec`, so an `innerCodec` can be supplied without declaring a `Codec` class. ([`22e6570`](https://github.com/JonasWanke/deranged/commit/22e6570724ee85eca0b897256b2c4586f89b107d))
- Exported the `StartEndAsMapCodec`, `SingleBoundAsMapCodec`, and `ProgressionAsMapCodec` base classes, so custom codecs can reuse them. `CodecAndJsonConverter` and `AsMapCodec` remain internal. ([`d46b2ad`](https://github.com/JonasWanke/deranged/commit/d46b2ad7e6a42d124307cce1e7fe09552b67ffe0), [`22e6570`](https://github.com/JonasWanke/deranged/commit/22e6570724ee85eca0b897256b2c4586f89b107d))

### 🐛 Bug Fixes

- `double.rangeUntil(…)` no longer subtracts `1` from the end. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `IntRange.stepBy(…)` now passes its inclusive end to `IntProgression`, whose end is inclusive. `0.rangeTo(9).stepBy(2)` returned `0, 2, 4, 6, 8, 10` and now returns `0, 2, 4, 6, 8`. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `IntRangeFrom.elementAt(…)` no longer hangs on negative indices; it throws a `RangeError`. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `Range.length`, `RangeInclusive.length`, and `IntRange.length` now return `0` for empty ranges instead of a negative number. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `Range.inclusive` now returns `null` when the range's end is the smallest possible value, instead of a one-element range for an empty range. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `DoubleRangeUntil.toString()` now uses the exclusive `..<end` notation. ([`f5cba63`](https://github.com/JonasWanke/deranged/commit/f5cba638059668670edee50c3a89627b06699427))
- `UnboundedBound.operator ==` no longer compares its type argument, which made equality asymmetric. `const UnboundedBound()` inside a generic class can't name that class's type parameter and becomes an `UnboundedBound<Never>` – which is what every range's unbounded `startBound`/`endBound` was – so `UnboundedBound<Never>() == UnboundedBound<num>()` was `false` while the reverse was `true`. An unbounded bound holds no value, so the type argument is phantom here. ([`1a1bc9e`](https://github.com/JonasWanke/deranged/commit/1a1bc9e70ced9cc8d5b6063550a438d48e6058cd))
- `AnyRange` no longer over-constrains the generic type of its bounds. ([`cdc895d`](https://github.com/JonasWanke/deranged/commit/cdc895dffe6572c6178652dffc4a3f2b44e9ce02))
- `Iterable<RangeInclusive<C>>.union` no longer fails for an empty iterable. ([`ec94e1f`](https://github.com/JonasWanke/deranged/commit/ec94e1f255653413eb600ca17d4adbb6afa8783e))
- The `IntRange*` and `DoubleRange*` constructors now take `int`/`double` parameters instead of `num`. ([`bae4053`](https://github.com/JonasWanke/deranged/commit/bae40531d2d3292952eef2d635f8522f0559d2b3))
- `Bound.laterStart(…)`/`Bound.earlierEnd(…)` (then `Bound.maxLower(…)`/`.minUpper(…)`) and `RangeInclusive.operator &` now accept `null` arguments. ([`d2661fa`](https://github.com/JonasWanke/deranged/commit/d2661fa09c3304d6b4e759f677be5be819553360))
- `DerangedRangeOfStep.stepBy(…)`'s return type is no longer nullable. ([`25461c2`](https://github.com/JonasWanke/deranged/commit/25461c2f61aa086f43ff1aa931e3b0f9ec619ffa))

### 🏗️ Refactoring

- `Progression` now mixes in `Iterable<T>` itself, so `IntProgression` and `StepProgression` no longer each declare it. ([`4561e4a`](https://github.com/JonasWanke/deranged/commit/4561e4a4126856d7345c8dd80ee8cd644e2d97a1))
- `Step` and `StepUnlimited` moved out of `progression.dart` into their own `step.dart`, and the codecs into `codec.dart`. ([`2456dad`](https://github.com/JonasWanke/deranged/commit/2456dade37cedc87fbf2e12ef1bece93b6b30f91), [`d845a9d`](https://github.com/JonasWanke/deranged/commit/d845a9dca18758389a414cf0bb00e092b65366e1))

### 📜 Documentation updates

- `Progression`'s documentation and `toString()` no longer describe its end as exclusive. ([`4561e4a`](https://github.com/JonasWanke/deranged/commit/4561e4a4126856d7345c8dd80ee8cd644e2d97a1))
- Swapped the mixed-up references in `Iterable<RangeInclusive>.union` and `.intersection`. ([`4561e4a`](https://github.com/JonasWanke/deranged/commit/4561e4a4126856d7345c8dd80ee8cd644e2d97a1))
- Documented the `until`/`to` convention, and the discrete-vs-continuous reasoning behind `int` having one range type where `double` has two, in the README and on `RangeBounds`. ([`4561e4a`](https://github.com/JonasWanke/deranged/commit/4561e4a4126856d7345c8dd80ee8cd644e2d97a1), [`dbb1bd4`](https://github.com/JonasWanke/deranged/commit/dbb1bd486be901ed44530d8d7e642d7ece2a5db1))
- Documented `Step`, `StepUnlimited`, and `previous`/`next`. ([`899db1c`](https://github.com/JonasWanke/deranged/commit/899db1cce72df41217e621268ee561e6b958260c), [`4444618`](https://github.com/JonasWanke/deranged/commit/44446186738f16c9a8fd5d7f7e9011232ccef430))
- Added a serialization section to the README, documented `.iter`, and shortened the rest. ([`de43393`](https://github.com/JonasWanke/deranged/commit/de4339336a12e24708fd3379ad6764232967e7fe), [`d5f3d2c`](https://github.com/JonasWanke/deranged/commit/d5f3d2cbb6a99f0b7ed5ef63b138dbde575dedf2), [`41f9a95`](https://github.com/JonasWanke/deranged/commit/41f9a953b85c42320427152d4222ca2d534bfb21))

### 📦 Build & CI

- Upgrade to Dart `^3.5.0` ([`5e0bd8b`](https://github.com/JonasWanke/deranged/commit/5e0bd8bd4ff1498efb993b603ddfdc162a47dc26), [`6de3d02`](https://github.com/JonasWanke/deranged/commit/6de3d025a1a9ad4676b3c287e17af64eec36da84), [`d1207b0`](https://github.com/JonasWanke/deranged/commit/d1207b01fb88dea2778cf72ec0b0bd2892623b66), [`959df44`](https://github.com/JonasWanke/deranged/commit/959df44946f21d60312fc78911d32f521fecfe21))
- Reformat with the new formatter ([`1bffeba`](https://github.com/JonasWanke/deranged/commit/1bffebadd7f68272561cbc328d9357c9207c3f73), [`dfd1e2a`](https://github.com/JonasWanke/deranged/commit/dfd1e2acd67c29690db338cdd81c23204fbe04c0))
- Bump `actions/checkout` to v7, `codecov/codecov-action` to v7, and `dependabot/fetch-metadata` to v3.1.0 ([#7](https://github.com/JonasWanke/deranged/pull/7), [#9](https://github.com/JonasWanke/deranged/pull/9), [#10](https://github.com/JonasWanke/deranged/pull/10), [#11](https://github.com/JonasWanke/deranged/pull/11), [#12](https://github.com/JonasWanke/deranged/pull/12), [#13](https://github.com/JonasWanke/deranged/pull/13))

## 0.0.0 · 2025-01-07

Initial release 🎉
