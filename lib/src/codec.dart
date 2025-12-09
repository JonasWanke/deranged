import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../deranged.dart';

/// Encodes a [Range] as a map with "start" and "end" keys.
class RangeAsMapCodec<C extends Comparable<C>>
    extends _CodecAndJsonConverter<Range<C>, Map<String, dynamic>> {
  const RangeAsMapCodec({this.fromJsonC});

  final C Function(dynamic json)? fromJsonC;

  @override
  Map<String, dynamic> encode(Range<C> input) {
    return {
      'start': input.start,
      'end': input.end,
    };
  }

  @override
  Range<C> decode(Map<String, dynamic> encoded) {
    final startRaw = encoded['start'];
    final start = fromJsonC != null ? fromJsonC!(startRaw) : startRaw as C;
    final endRaw = encoded['end'];
    final end = fromJsonC != null ? fromJsonC!(endRaw) : endRaw as C;
    return Range(start, end);
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
