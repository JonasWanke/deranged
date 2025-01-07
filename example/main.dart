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
  // IntRange(0..=5) contains 6 elements: [0, 1, 2, 3, 4, 5]

  const intRangeTo = IntRangeTo(5);
  print('$intRangeTo contains 0? ${intRangeTo.contains(0)}'); // true
  print('$intRangeTo contains 2.2? ${intRangeTo.contains(2.2)}'); // false
  print('$intRangeTo contains 4? ${intRangeTo.contains(4)}'); // true
  print('$intRangeTo contains 5? ${intRangeTo.contains(5)}'); // true

  // Progression

  print('0..10 stepBy 2: ${0.rangeTo(10).stepBy(2).toList()}');
  // 0..10 stepBy 2: [0, 2, 4, 6, 8, 10]
}
