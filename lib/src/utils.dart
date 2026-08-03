import 'package:meta/meta.dart';

@internal
C min<C extends Comparable<C>>(C a, C? b) {
  if (b == null) return a;

  return a.compareTo(b) <= 0 ? a : b;
}

@internal
C max<C extends Comparable<C>>(C a, C? b) {
  if (b == null) return a;

  return a.compareTo(b) >= 0 ? a : b;
}
