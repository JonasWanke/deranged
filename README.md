# Ranges

| Start     | End       | Generic Class      | `int` Class    |
| :-------- | :-------- | :----------------- | :------------- |
| Inclusive | Inclusive | `RangeInclusive`   | `IntRange`     |
| Inclusive | Exclusive | `Range`            | `IntRange`     |
| Inclusive | Unbounded | `RangeFrom`        | `IntRangeFrom` |
| Exclusive | Inclusive | —                  | —              |
| Exclusive | Exclusive | —                  | —              |
| Exclusive | Unbounded | —                  | —              |
| Unbounded | Inclusive | `RangeToInclusive` | `IntRangeTo`   |
| Unbounded | Exclusive | `RangeTo`          | `IntRangeTo`   |
| Unbounded | Unbounded | `RangeFull`        | `IntRangeFull` |
