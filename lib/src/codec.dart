import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

/// A [Codec] that is also a [JsonConverter].
///
/// This lets the same object be used with [Codec]-based APIs and as a
/// `@JsonKey(fromJson: …, toJson: …)`/`@JsonSerializable` converter.
@immutable
@internal
abstract class CodecAndJsonConverter<S extends Object, T> extends Codec<S, T>
    implements JsonConverter<S, T> {
  const CodecAndJsonConverter();

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

/// A [CodecAndJsonConverter] built from an [encode] and a [decode] function.
///
/// Useful as the `innerCodec` of the range and progression codecs when you
/// don't want to declare a [Codec] class:
///
/// ```dart
/// const RangeAsMapCodec<DateTime>(
///   FunctionBasedCodec(
///     encode: _encodeDateTime,
///     decode: _decodeDateTime,
///   ),
/// );
///
/// Object? _encodeDateTime(DateTime it) => it.toIso8601String();
/// DateTime _decodeDateTime(Object? it) => DateTime.parse(it! as String);
/// ```
class FunctionBasedCodec<S extends Object, T>
    extends CodecAndJsonConverter<S, T> {
  const FunctionBasedCodec({required this._encode, required this._decode});

  final T Function(S) _encode;
  final S Function(T) _decode;

  @override
  T encode(S input) => _encode(input);
  @override
  S decode(T encoded) => _decode(encoded);
}

@internal
abstract class AsMapCodec<S extends Object, C extends Object>
    extends CodecAndJsonConverter<S, Map<String, dynamic>> {
  const AsMapCodec(this.innerCodec);

  /// Codec for the contained values.
  ///
  /// If this is `null`, values are passed through unchanged — which is what you
  /// want for types that are already JSON-encodable, such as [int] and
  /// [double].
  final Codec<C, Object?>? innerCodec;

  @protected
  Object? encodeValue(C value) {
    final innerCodec = this.innerCodec;
    return innerCodec == null ? value : innerCodec.encode(value);
  }

  @protected
  C decodeValue(Object? encoded) {
    final innerCodec = this.innerCodec;
    return innerCodec == null ? encoded! as C : innerCodec.decode(encoded);
  }
}

/// Encodes a range with a start and an end bound as a map with "start" and
/// "end" keys.
abstract class StartEndAsMapCodec<S extends Object, C extends Object>
    extends AsMapCodec<S, C> {
  const StartEndAsMapCodec(super.innerCodec);

  @protected
  (C start, C end) startAndEndOf(S range);

  /// Creates a range from the decoded [start] and [end] values.
  @protected
  S create(C start, C end);

  @override
  Map<String, dynamic> encode(S input) {
    final (start, end) = startAndEndOf(input);
    return {'start': encodeValue(start), 'end': encodeValue(end)};
  }

  @override
  S decode(Map<String, dynamic> encoded) =>
      create(decodeValue(encoded['start']), decodeValue(encoded['end']));
}

/// Encodes a range with exactly one bound as a map with a single [key].
abstract class SingleBoundAsMapCodec<S extends Object, C extends Object>
    extends AsMapCodec<S, C> {
  const SingleBoundAsMapCodec(super.innerCodec);

  /// The map key holding the bound value, e.g., "start" or "end".
  @protected
  String get key;

  @protected
  C valueOf(S range);

  /// Creates a range from the decoded bound [value].
  @protected
  S create(C value);

  @override
  Map<String, dynamic> encode(S input) => {key: encodeValue(valueOf(input))};

  @override
  S decode(Map<String, dynamic> encoded) => create(decodeValue(encoded[key]));
}

/// Encodes a progression as a map with "start", "endInclusive", and "step"
/// keys.
abstract class ProgressionAsMapCodec<S extends Object, C extends Object>
    extends AsMapCodec<S, C> {
  const ProgressionAsMapCodec(super.innerCodec);

  /// The start, inclusive end, and step of [progression].
  @protected
  (C start, C endInclusive, int step) partsOf(S progression);

  /// Creates a progression from the decoded parts.
  @protected
  S create(C start, C endInclusive, int step);

  @override
  Map<String, dynamic> encode(S input) {
    final (start, endInclusive, step) = partsOf(input);
    return {
      'start': encodeValue(start),
      'endInclusive': encodeValue(endInclusive),
      'step': step,
    };
  }

  @override
  S decode(Map<String, dynamic> encoded) => create(
    decodeValue(encoded['start']),
    decodeValue(encoded['endInclusive']),
    encoded['step'] as int,
  );
}
