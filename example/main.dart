// ignore_for_file: avoid_print, avoid-collection-methods-with-unrelated-types

import 'package:deranged/deranged.dart';

void main() {
  // Ranges

  final rangeUntil = 0.rangeUntil(5);
  print(
    '$rangeUntil contains ${rangeUntil.length} elements: '
    '${rangeUntil.toList()}',
  );
  print('Contains 0? ${rangeUntil.contains(0)}'); // true
  print('Contains 1? ${rangeUntil.contains(1)}'); // true
  print('Contains 2.5? ${rangeUntil.contains(2.5)}'); // false
  print('Contains 4? ${rangeUntil.contains(4)}'); // true
  print('Contains 5? ${rangeUntil.contains(5)}'); // false

  final rangeTo = 0.rangeTo(5);
  print('$rangeTo contains ${rangeTo.length} elements: ${rangeTo.toList()}');
  // IntRange(0..<6) contains 6 elements: [0, 1, 2, 3, 4, 5]

  const intRangeUntil = IntRangeUntil(5);
  print('$intRangeUntil contains 0? ${intRangeUntil.contains(0)}'); // true
  print('$intRangeUntil contains 2.2? ${intRangeUntil.contains(2.2)}'); // false
  print('$intRangeUntil contains 4? ${intRangeUntil.contains(4)}'); // true
  print('$intRangeUntil contains 5? ${intRangeUntil.contains(5)}'); // false

  // Progression

  print('0..10 stepBy 2: ${0.rangeTo(10).stepBy(2).toList()}');
  // 0..10 stepBy 2: [0, 2, 4, 6, 8, 10]

  // Step: ranges over your own types

  final chapters = const Chapter(1).rangeTo(const Chapter(5));
  print('$chapters has ${chapters.length} chapters: ${chapters.iter.toList()}');
  // RangeInclusive(Chapter 1..=Chapter 5) has 5 chapters:
  // [Chapter 1, Chapter 2, Chapter 3, Chapter 4, Chapter 5]
  print('Every other one: ${chapters.stepBy(2).toList()}');
  // [Chapter 1, Chapter 3, Chapter 5]
  print('Backwards: ${chapters.reverse.toList()}');
  // [Chapter 5, Chapter 4, Chapter 3, Chapter 2, Chapter 1]
  print('Third chapter: ${chapters[2]}'); // Chapter 3
  print('Contains chapter 3? ${chapters.contains(const Chapter(3))}'); // true
  print('Contains chapter 9? ${chapters.contains(const Chapter(9))}'); // false

  // The same range with an exclusive end. This is nullable because a `Step`
  // value may have no successor – see `Chapter.stepBy(…)` below.
  print('As a half-open range: ${chapters.exclusive}');
  // Range(Chapter 1..<Chapter 6)

  // Ranges of `Step` values support the usual set operations.
  final laterChapters = const Chapter(4).rangeTo(const Chapter(8));
  print('Union: ${chapters | laterChapters}');
  // RangeInclusive(Chapter 1..=Chapter 8)
  print('Intersection: ${chapters & laterChapters}');
  // RangeInclusive(Chapter 4..=Chapter 5)

  // Stepping past the first chapter yields `null` rather than an invalid value.
  print('After chapter 1: ${const Chapter(1).next}'); // Chapter 2
  print('Before chapter 1: ${const Chapter(1).previous}'); // null
}

/// A chapter in a book, numbered from one.
///
/// Implementing [Step] is what makes the generic ranges usable with a custom
/// type: It provides the successor/predecessor operations that iterating,
/// [DerangedRangeInclusiveOfStep.length] and converting between inclusive and
/// exclusive bounds all need.
///
/// This also shows the workaround for [int] not being able to implement [Step]
/// itself: [int] implements `Comparable<num>` rather than `Comparable<int>`, so
/// it doesn't satisfy `Step`'s `C extends Step<C>` bound. Wrapping it in your
/// own type – as here – sidesteps that, and usually models the domain better
/// anyway.
///
/// Chapters have a first value but no last one, so [stepBy] returns `null` when
/// stepping below chapter one. A type that can be stepped indefinitely in both
/// directions should mix in [StepUnlimited] instead, which never returns
/// `null`.
class Chapter with Step<Chapter> {
  const Chapter(this.number) : assert(number >= 1, 'Chapters start at one.');

  final int number;

  /// Returns the chapter [count] chapters after this one, or `null` if that
  /// would be before the first chapter.
  @override
  Chapter? stepBy(int count) {
    final result = number + count;
    return result >= 1 ? Chapter(result) : null;
  }

  /// The number of chapters between this one and [other], negative if [other]
  /// comes first.
  ///
  /// This must be consistent with [stepBy]: `a.stepBy(a.stepsUntil(b)) == b`.
  @override
  int stepsUntil(Chapter other) => other.number - number;

  @override
  int compareTo(Chapter other) => number.compareTo(other.number);

  // `Step` values are used as elements and compared for equality throughout, so
  // `==` and `hashCode` must be value-based.
  @override
  bool operator ==(Object other) => other is Chapter && number == other.number;
  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'Chapter $number';
}
