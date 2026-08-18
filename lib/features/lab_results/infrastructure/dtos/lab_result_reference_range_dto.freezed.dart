// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_result_reference_range_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LabResultReferenceRangeDto {

 double get low; double get high;
/// Create a copy of LabResultReferenceRangeDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultReferenceRangeDtoCopyWith<LabResultReferenceRangeDto> get copyWith => _$LabResultReferenceRangeDtoCopyWithImpl<LabResultReferenceRangeDto>(this as LabResultReferenceRangeDto, _$identity);

  /// Serializes this LabResultReferenceRangeDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultReferenceRangeDto&&(identical(other.low, low) || other.low == low)&&(identical(other.high, high) || other.high == high));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,low,high);

@override
String toString() {
  return 'LabResultReferenceRangeDto(low: $low, high: $high)';
}


}

/// @nodoc
abstract mixin class $LabResultReferenceRangeDtoCopyWith<$Res>  {
  factory $LabResultReferenceRangeDtoCopyWith(LabResultReferenceRangeDto value, $Res Function(LabResultReferenceRangeDto) _then) = _$LabResultReferenceRangeDtoCopyWithImpl;
@useResult
$Res call({
 double low, double high
});




}
/// @nodoc
class _$LabResultReferenceRangeDtoCopyWithImpl<$Res>
    implements $LabResultReferenceRangeDtoCopyWith<$Res> {
  _$LabResultReferenceRangeDtoCopyWithImpl(this._self, this._then);

  final LabResultReferenceRangeDto _self;
  final $Res Function(LabResultReferenceRangeDto) _then;

/// Create a copy of LabResultReferenceRangeDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? low = null,Object? high = null,}) {
  return _then(_self.copyWith(
low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LabResultReferenceRangeDto].
extension LabResultReferenceRangeDtoPatterns on LabResultReferenceRangeDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabResultReferenceRangeDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabResultReferenceRangeDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabResultReferenceRangeDto value)  $default,){
final _that = this;
switch (_that) {
case _LabResultReferenceRangeDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabResultReferenceRangeDto value)?  $default,){
final _that = this;
switch (_that) {
case _LabResultReferenceRangeDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double low,  double high)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabResultReferenceRangeDto() when $default != null:
return $default(_that.low,_that.high);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double low,  double high)  $default,) {final _that = this;
switch (_that) {
case _LabResultReferenceRangeDto():
return $default(_that.low,_that.high);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double low,  double high)?  $default,) {final _that = this;
switch (_that) {
case _LabResultReferenceRangeDto() when $default != null:
return $default(_that.low,_that.high);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabResultReferenceRangeDto implements LabResultReferenceRangeDto {
  const _LabResultReferenceRangeDto({required this.low, required this.high});
  factory _LabResultReferenceRangeDto.fromJson(Map<String, dynamic> json) => _$LabResultReferenceRangeDtoFromJson(json);

@override final  double low;
@override final  double high;

/// Create a copy of LabResultReferenceRangeDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabResultReferenceRangeDtoCopyWith<_LabResultReferenceRangeDto> get copyWith => __$LabResultReferenceRangeDtoCopyWithImpl<_LabResultReferenceRangeDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabResultReferenceRangeDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabResultReferenceRangeDto&&(identical(other.low, low) || other.low == low)&&(identical(other.high, high) || other.high == high));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,low,high);

@override
String toString() {
  return 'LabResultReferenceRangeDto(low: $low, high: $high)';
}


}

/// @nodoc
abstract mixin class _$LabResultReferenceRangeDtoCopyWith<$Res> implements $LabResultReferenceRangeDtoCopyWith<$Res> {
  factory _$LabResultReferenceRangeDtoCopyWith(_LabResultReferenceRangeDto value, $Res Function(_LabResultReferenceRangeDto) _then) = __$LabResultReferenceRangeDtoCopyWithImpl;
@override @useResult
$Res call({
 double low, double high
});




}
/// @nodoc
class __$LabResultReferenceRangeDtoCopyWithImpl<$Res>
    implements _$LabResultReferenceRangeDtoCopyWith<$Res> {
  __$LabResultReferenceRangeDtoCopyWithImpl(this._self, this._then);

  final _LabResultReferenceRangeDto _self;
  final $Res Function(_LabResultReferenceRangeDto) _then;

/// Create a copy of LabResultReferenceRangeDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? low = null,Object? high = null,}) {
  return _then(_LabResultReferenceRangeDto(
low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
