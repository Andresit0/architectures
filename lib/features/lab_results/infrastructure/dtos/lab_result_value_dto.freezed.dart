// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_result_value_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LabResultValueDto {

 DateTime get date; dynamic get value;
/// Create a copy of LabResultValueDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultValueDtoCopyWith<LabResultValueDto> get copyWith => _$LabResultValueDtoCopyWithImpl<LabResultValueDto>(this as LabResultValueDto, _$identity);

  /// Serializes this LabResultValueDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultValueDto&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'LabResultValueDto(date: $date, value: $value)';
}


}

/// @nodoc
abstract mixin class $LabResultValueDtoCopyWith<$Res>  {
  factory $LabResultValueDtoCopyWith(LabResultValueDto value, $Res Function(LabResultValueDto) _then) = _$LabResultValueDtoCopyWithImpl;
@useResult
$Res call({
 DateTime date, dynamic value
});




}
/// @nodoc
class _$LabResultValueDtoCopyWithImpl<$Res>
    implements $LabResultValueDtoCopyWith<$Res> {
  _$LabResultValueDtoCopyWithImpl(this._self, this._then);

  final LabResultValueDto _self;
  final $Res Function(LabResultValueDto) _then;

/// Create a copy of LabResultValueDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}

}


/// Adds pattern-matching-related methods to [LabResultValueDto].
extension LabResultValueDtoPatterns on LabResultValueDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabResultValueDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabResultValueDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabResultValueDto value)  $default,){
final _that = this;
switch (_that) {
case _LabResultValueDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabResultValueDto value)?  $default,){
final _that = this;
switch (_that) {
case _LabResultValueDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  dynamic value)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabResultValueDto() when $default != null:
return $default(_that.date,_that.value);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  dynamic value)  $default,) {final _that = this;
switch (_that) {
case _LabResultValueDto():
return $default(_that.date,_that.value);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  dynamic value)?  $default,) {final _that = this;
switch (_that) {
case _LabResultValueDto() when $default != null:
return $default(_that.date,_that.value);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabResultValueDto implements LabResultValueDto {
  const _LabResultValueDto({required this.date, required this.value});
  factory _LabResultValueDto.fromJson(Map<String, dynamic> json) => _$LabResultValueDtoFromJson(json);

@override final  DateTime date;
@override final  dynamic value;

/// Create a copy of LabResultValueDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabResultValueDtoCopyWith<_LabResultValueDto> get copyWith => __$LabResultValueDtoCopyWithImpl<_LabResultValueDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabResultValueDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabResultValueDto&&(identical(other.date, date) || other.date == date)&&const DeepCollectionEquality().equals(other.value, value));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,const DeepCollectionEquality().hash(value));

@override
String toString() {
  return 'LabResultValueDto(date: $date, value: $value)';
}


}

/// @nodoc
abstract mixin class _$LabResultValueDtoCopyWith<$Res> implements $LabResultValueDtoCopyWith<$Res> {
  factory _$LabResultValueDtoCopyWith(_LabResultValueDto value, $Res Function(_LabResultValueDto) _then) = __$LabResultValueDtoCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, dynamic value
});




}
/// @nodoc
class __$LabResultValueDtoCopyWithImpl<$Res>
    implements _$LabResultValueDtoCopyWith<$Res> {
  __$LabResultValueDtoCopyWithImpl(this._self, this._then);

  final _LabResultValueDto _self;
  final $Res Function(_LabResultValueDto) _then;

/// Create a copy of LabResultValueDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = freezed,}) {
  return _then(_LabResultValueDto(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as dynamic,
  ));
}


}

// dart format on
