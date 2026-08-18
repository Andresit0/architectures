// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_result_value_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabResultValueEntity {

 DateTime get date; double? get value; String? get textValue;
/// Create a copy of LabResultValueEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultValueEntityCopyWith<LabResultValueEntity> get copyWith => _$LabResultValueEntityCopyWithImpl<LabResultValueEntity>(this as LabResultValueEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultValueEntity&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.textValue, textValue) || other.textValue == textValue));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,textValue);

@override
String toString() {
  return 'LabResultValueEntity(date: $date, value: $value, textValue: $textValue)';
}


}

/// @nodoc
abstract mixin class $LabResultValueEntityCopyWith<$Res>  {
  factory $LabResultValueEntityCopyWith(LabResultValueEntity value, $Res Function(LabResultValueEntity) _then) = _$LabResultValueEntityCopyWithImpl;
@useResult
$Res call({
 DateTime date, double? value, String? textValue
});




}
/// @nodoc
class _$LabResultValueEntityCopyWithImpl<$Res>
    implements $LabResultValueEntityCopyWith<$Res> {
  _$LabResultValueEntityCopyWithImpl(this._self, this._then);

  final LabResultValueEntity _self;
  final $Res Function(LabResultValueEntity) _then;

/// Create a copy of LabResultValueEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? value = freezed,Object? textValue = freezed,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,textValue: freezed == textValue ? _self.textValue : textValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LabResultValueEntity].
extension LabResultValueEntityPatterns on LabResultValueEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabResultValueEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabResultValueEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabResultValueEntity value)  $default,){
final _that = this;
switch (_that) {
case _LabResultValueEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabResultValueEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LabResultValueEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime date,  double? value,  String? textValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabResultValueEntity() when $default != null:
return $default(_that.date,_that.value,_that.textValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime date,  double? value,  String? textValue)  $default,) {final _that = this;
switch (_that) {
case _LabResultValueEntity():
return $default(_that.date,_that.value,_that.textValue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime date,  double? value,  String? textValue)?  $default,) {final _that = this;
switch (_that) {
case _LabResultValueEntity() when $default != null:
return $default(_that.date,_that.value,_that.textValue);case _:
  return null;

}
}

}

/// @nodoc


class _LabResultValueEntity extends LabResultValueEntity {
  const _LabResultValueEntity({required this.date, this.value, this.textValue}): super._();
  

@override final  DateTime date;
@override final  double? value;
@override final  String? textValue;

/// Create a copy of LabResultValueEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabResultValueEntityCopyWith<_LabResultValueEntity> get copyWith => __$LabResultValueEntityCopyWithImpl<_LabResultValueEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabResultValueEntity&&(identical(other.date, date) || other.date == date)&&(identical(other.value, value) || other.value == value)&&(identical(other.textValue, textValue) || other.textValue == textValue));
}


@override
int get hashCode => Object.hash(runtimeType,date,value,textValue);

@override
String toString() {
  return 'LabResultValueEntity(date: $date, value: $value, textValue: $textValue)';
}


}

/// @nodoc
abstract mixin class _$LabResultValueEntityCopyWith<$Res> implements $LabResultValueEntityCopyWith<$Res> {
  factory _$LabResultValueEntityCopyWith(_LabResultValueEntity value, $Res Function(_LabResultValueEntity) _then) = __$LabResultValueEntityCopyWithImpl;
@override @useResult
$Res call({
 DateTime date, double? value, String? textValue
});




}
/// @nodoc
class __$LabResultValueEntityCopyWithImpl<$Res>
    implements _$LabResultValueEntityCopyWith<$Res> {
  __$LabResultValueEntityCopyWithImpl(this._self, this._then);

  final _LabResultValueEntity _self;
  final $Res Function(_LabResultValueEntity) _then;

/// Create a copy of LabResultValueEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? value = freezed,Object? textValue = freezed,}) {
  return _then(_LabResultValueEntity(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,value: freezed == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as double?,textValue: freezed == textValue ? _self.textValue : textValue // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
