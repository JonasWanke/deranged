import 'package:meta/meta.dart';

@internal
C min<C extends Comparable<C>>(C a, C b) => a.compareTo(b) <= 0 ? a : b;
@internal
C max<C extends Comparable<C>>(C a, C b) => a.compareTo(b) >= 0 ? a : b;
