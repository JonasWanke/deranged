import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../deranged.dart';

/// Encodes a [Range] as a map with "start" and "end" keys.
class RangeAsMapCodec<C extends Comparable<C>>
    extends _CodecAndJsonConverter<Range<C>, Map<String, dynamic>> {
  const RangeAsMapCodec({this.innerCodec, this.encodeInner, this.decodeInner})
    : assert(
        innerCodec == null || (encodeInner == null && decodeInner == null),
        'Cannot provide both innerCodec and encodeInner/decodeInner.',
      );

  final Codec<C, dynamic>? innerCodec;
  final dynamic Function(C)? encodeInner;
  final C Function(dynamic)? decodeInner;

  @override
  Map<String, dynamic> encode(Range<C> input) => {
    'start': _encode(input.start, innerCodec, encodeInner),
    'end': _encode(input.end, innerCodec, encodeInner),
  };

  @override
  Range<C> decode(Map<String, dynamic> encoded) => Range(
    _decode(encoded['start'], innerCodec, decodeInner),
    _decode(encoded['end'], innerCodec, decodeInner),
  );
}

/// Encodes a [RangeInclusive] as a map with "start" and "end" keys.
class RangeInclusiveAsMapCodec<C extends Comparable<C>>
    extends _CodecAndJsonConverter<RangeInclusive<C>, Map<String, dynamic>> {
  const RangeInclusiveAsMapCodec({
    this.innerCodec,
    this.encodeInner,
    this.decodeInner,
  }) : assert(
         innerCodec == null || (encodeInner == null && decodeInner == null),
         'Cannot provide both innerCodec and encodeInner/decodeInner.',
       );

  final Codec<C, dynamic>? innerCodec;
  final dynamic Function(C)? encodeInner;
  final C Function(dynamic)? decodeInner;

  @override
  Map<String, dynamic> encode(RangeInclusive<C> input) => {
    'start': _encode(input.start, innerCodec, encodeInner),
    'end': _encode(input.end, innerCodec, encodeInner),
  };

  @override
  RangeInclusive<C> decode(Map<String, dynamic> encoded) => RangeInclusive(
    _decode(encoded['start'], innerCodec, decodeInner),
    _decode(encoded['end'], innerCodec, decodeInner),
  );
}

dynamic _encode<C>(
  C input,
  Codec<C, dynamic>? innerCodec,
  dynamic Function(C)? encodeInner,
) {
  if (innerCodec case final innerCodec?) {
    return innerCodec.encode(input);
  } else if (encodeInner case final encodeInner?) {
    return encodeInner(input);
  } else {
    return input;
  }
}

C _decode<C>(
  dynamic encoded,
  Codec<C, dynamic>? innerCodec,
  C Function(dynamic)? decodeInner,
) {
  if (innerCodec case final innerCodec?) {
    return innerCodec.decode(encoded);
  } else if (decodeInner case final decodeInner?) {
    return decodeInner(encoded);
  } else {
    return encoded as C;
  }
}

@immutable
abstract class _CodecAndJsonConverter<S extends Object, T> extends Codec<S, T>
    implements JsonConverter<S, T> {
  const _CodecAndJsonConverter();

  @override
  Converter<S, T> get encoder => _FunctionBasedConverter(encode);
  @override
  Converter<T, S> get decoder => _FunctionBasedConverter(decode);

  @override
  T encode(S input);
  @override
  T toJson(S object) => encode(object);

  @override
  S decode(T encoded);
  @override
  S fromJson(T json) => decode(json);
}

class _FunctionBasedConverter<S, T> extends Converter<S, T> {
  const _FunctionBasedConverter(this._convert);

  final T Function(S) _convert;

  @override
  T convert(S input) => _convert(input);
}
