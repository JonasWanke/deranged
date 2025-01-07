import 'package:glados/glados.dart';
import 'package:meta/meta.dart';
import 'package:ranges/ranges.dart';

void main() {
  final examples = {
    const StepProgression(_Foo(0), _Foo(0), 1): [0],
    const StepProgression(_Foo(0), _Foo(1), 1): [0, 1],
    const StepProgression(_Foo(0), _Foo(2), 1): [0, 1, 2],
    const StepProgression(_Foo(0), _Foo(3), 1): [0, 1, 2, 3],
    const StepProgression(_Foo(0), _Foo(0), 2): [0],
    const StepProgression(_Foo(0), _Foo(1), 2): [0],
    const StepProgression(_Foo(0), _Foo(2), 2): [0, 2],
    const StepProgression(_Foo(0), _Foo(3), 2): [0, 2],
    const StepProgression(_Foo(0), _Foo(4), 2): [0, 2, 4],
    const StepProgression(_Foo(0), _Foo(0), -1): [0],
    const StepProgression(_Foo(0), _Foo(-1), -1): [0, -1],
    const StepProgression(_Foo(0), _Foo(-2), -1): [0, -1, -2],
    const StepProgression(_Foo(0), _Foo(-3), -1): [0, -1, -2, -3],
    const StepProgression(_Foo(0), _Foo(0), -2): [0],
    const StepProgression(_Foo(0), _Foo(-1), -2): [0],
    const StepProgression(_Foo(0), _Foo(-2), -2): [0, -2],
    const StepProgression(_Foo(0), _Foo(-3), -2): [0, -2],
    const StepProgression(_Foo(0), _Foo(-4), -2): [0, -2, -4],
  };
  for (final MapEntry(key: progression, value: intValues) in examples.entries) {
    final values = intValues.map(_Foo.new).toList();
    group(progression.toString(), () {
      test('most functions', () {
        expect(progression.isEmpty, values.isEmpty);
        expect(progression.toList(), values);
        expect(progression.length, values.length);
        if (values.isNotEmpty) {
          expect(progression.first, values.first);
          expect(progression.last, values.last);
        }
      });
      Glados(any.foo).test('contains(…)', (value) {
        expect(progression.contains(value), values.contains(value));
      });
    });
  }
}

@immutable
class _Foo implements Step<_Foo> {
  const _Foo(this.value);

  final int value;

  @override
  int compareTo(_Foo other) => value.compareTo(other.value);

  @override
  _Foo stepBy(int step) => _Foo(value + step);

  @override
  int stepsUntil(_Foo other) => other.value - value;

  @override
  bool operator ==(Object other) => other is _Foo && value == other.value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}

extension on Any {
  Generator<_Foo> get foo => this.int.map(_Foo.new);
}
