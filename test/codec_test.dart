import 'package:deranged/deranged.dart';
import 'package:glados/glados.dart';
import 'package:meta/meta.dart';

void main() {
  group('without an innerCodec', () {
    test('IntRangeAsMapCodec', () {
      const codec = IntRangeAsMapCodec();
      const range = IntRange(2, 7);

      expect(codec.encode(range), {'start': 2, 'end': 7});
      expect(codec.decode({'start': 2, 'end': 7}), range);
      expect(codec.decode(codec.encode(range)), range);
    });

    test('DoubleRangeAsMapCodec decodes whole numbers as doubles', () {
      const codec = DoubleRangeAsMapCodec();
      const range = DoubleRange(2, 7);

      expect(codec.encode(range), {'start': 2.0, 'end': 7.0});
      // A JSON parser may hand back `2` rather than `2.0`.
      expect(codec.decode({'start': 2, 'end': 7}), range);
      expect(codec.decode({'start': 2.5, 'end': 7.5}).start, 2.5);
    });

    test('DoubleRangeInclusiveAsMapCodec', () {
      const codec = DoubleRangeInclusiveAsMapCodec();
      const range = DoubleRangeInclusive(2, 7);

      expect(codec.encode(range), {'start': 2.0, 'end': 7.0});
      expect(codec.decode({'start': 2, 'end': 7}), range);
    });

    test('IntProgressionAsMapCodec', () {
      const codec = IntProgressionAsMapCodec();
      const progression = IntProgression(0, 10, 2);

      expect(codec.encode(progression), {
        'start': 0,
        'endInclusive': 10,
        'step': 2,
      });
      expect(codec.decode(codec.encode(progression)), progression);
    });
  });

  group('with an innerCodec', () {
    const codec = RangeAsMapCodec<_Foo>(_fooCodec);

    test('encodes and decodes the bound values', () {
      const range = Range(_Foo(2), _Foo(7));

      expect(codec.encode(range), {'start': 2, 'end': 7});
      expect(codec.decode({'start': 2, 'end': 7}), range);
      expect(codec.decode(codec.encode(range)), range);
    });

    test('RangeInclusiveAsMapCodec', () {
      const codec = RangeInclusiveAsMapCodec<_Foo>(_fooCodec);
      const range = RangeInclusive(_Foo(2), _Foo(7));

      expect(codec.encode(range), {'start': 2, 'end': 7});
      expect(codec.decode(codec.encode(range)), range);
    });
  });

  group('single-bound codecs', () {
    test('RangeFromAsMapCodec uses a "start" key', () {
      const codec = RangeFromAsMapCodec<_Foo>(_fooCodec);
      const range = RangeFrom(_Foo(2));

      expect(codec.encode(range), {'start': 2});
      expect(codec.decode(codec.encode(range)), range);
    });

    test('RangeUntilAsMapCodec uses an "end" key', () {
      const codec = RangeUntilAsMapCodec<_Foo>(_fooCodec);
      const range = RangeUntil(_Foo(7));

      expect(codec.encode(range), {'end': 7});
      expect(codec.decode(codec.encode(range)), range);
    });

    test('RangeToAsMapCodec uses an "end" key', () {
      const codec = RangeToAsMapCodec<_Foo>(_fooCodec);
      const range = RangeTo(_Foo(7));

      expect(codec.encode(range), {'end': 7});
      expect(codec.decode(codec.encode(range)), range);
    });

    test('IntRangeFromAsMapCodec', () {
      const codec = IntRangeFromAsMapCodec();

      expect(codec.encode(const IntRangeFrom(2)), {'start': 2});
      expect(codec.decode({'start': 2}), const IntRangeFrom(2));
    });

    test('IntRangeUntilAsMapCodec', () {
      const codec = IntRangeUntilAsMapCodec();

      expect(codec.encode(const IntRangeUntil(7)), {'end': 7});
      expect(codec.decode({'end': 7}), const IntRangeUntil(7));
    });

    test('DoubleRangeFromAsMapCodec', () {
      const codec = DoubleRangeFromAsMapCodec();

      expect(codec.encode(const DoubleRangeFrom(2.5)), {'start': 2.5});
      // A JSON parser may hand back `2` rather than `2.0`.
      expect(codec.decode({'start': 2}), const DoubleRangeFrom(2));
    });

    test('DoubleRangeUntilAsMapCodec', () {
      const codec = DoubleRangeUntilAsMapCodec();

      expect(codec.encode(const DoubleRangeUntil(7.5)), {'end': 7.5});
      expect(codec.decode({'end': 7}), const DoubleRangeUntil(7));
    });

    test('DoubleRangeToAsMapCodec', () {
      const codec = DoubleRangeToAsMapCodec();

      expect(codec.encode(const DoubleRangeTo(7.5)), {'end': 7.5});
      expect(codec.decode({'end': 7}), const DoubleRangeTo(7));
    });
  });

  group('BoundAsMapCodec', () {
    const codec = BoundAsMapCodec<_Foo>(_fooCodec);

    test('round-trips every bound kind', () {
      expect(codec.encode(const InclusiveBound(_Foo(2))), {
        'type': 'inclusive',
        'value': 2,
      });
      expect(codec.encode(const ExclusiveBound(_Foo(2))), {
        'type': 'exclusive',
        'value': 2,
      });
      expect(codec.encode(const UnboundedBound<_Foo>()), {'type': 'unbounded'});

      for (final bound in const <Bound<_Foo>>[
        InclusiveBound(_Foo(2)),
        ExclusiveBound(_Foo(2)),
        UnboundedBound(),
      ]) {
        expect(codec.decode(codec.encode(bound)), bound);
      }
    });

    test('throws on an unknown type', () {
      expect(
        () => codec.decode({'type': 'nonsense'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('AnyRangeAsMapCodec', () {
    const codec = AnyRangeAsMapCodec<_Foo>(_fooCodec);

    test('round-trips mixed bound kinds', () {
      const range = AnyRange(ExclusiveBound(_Foo(2)), UnboundedBound<_Foo>());

      expect(codec.encode(range), {
        'start': {'type': 'exclusive', 'value': 2},
        'end': {'type': 'unbounded'},
      });
      expect(codec.decode(codec.encode(range)), range);
    });

    Glados2(any.foo, any.foo).test('round-trips inclusive bounds', (a, b) {
      final range = AnyRange(InclusiveBound(a), InclusiveBound(b));

      expect(codec.decode(codec.encode(range)), range);
    });
  });

  test('codecs are also JsonConverters', () {
    const codec = IntRangeAsMapCodec();
    const range = IntRange(2, 7);

    // `toJson`/`fromJson` come from `JsonConverter`, `encoder`/`decoder` from
    // `Codec` – both must agree with `encode`/`decode`.
    expect(codec.toJson(range), codec.encode(range));
    expect(codec.fromJson(codec.toJson(range)), range);
    expect(codec.encoder.convert(range), codec.encode(range));
    expect(codec.decoder.convert(codec.encode(range)), range);
  });
}

const _fooCodec = FunctionBasedCodec<_Foo, Object?>(
  encode: _encodeFoo,
  decode: _decodeFoo,
);
Object? _encodeFoo(_Foo value) => value.value;
_Foo _decodeFoo(Object? encoded) => _Foo(encoded! as int);

@immutable
class _Foo implements Comparable<_Foo> {
  const _Foo(this.value);

  final int value;

  @override
  int compareTo(_Foo other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is _Foo && value == other.value;
  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Foo($value)';
}

extension on Any {
  Generator<_Foo> get foo => this.int.map(_Foo.new);
}
