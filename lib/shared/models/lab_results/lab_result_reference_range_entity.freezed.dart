// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lab_result_reference_range_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LabResultReferenceRangeEntity {

 double get low; double get high;
/// Create a copy of LabResultReferenceRangeEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabResultReferenceRangeEntityCopyWith<LabResultReferenceRangeEntity> get copyWith => _$LabResultReferenceRangeEntityCopyWithImpl<LabResultReferenceRangeEntity>(this as LabResultReferenceRangeEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabResultReferenceRangeEntity&&(identical(other.low, low) || other.low == low)&&(identical(other.high, high) || other.high == high));
}


@override
int get hashCode => Object.hash(runtimeType,low,high);

@override
String toString() {
  return 'LabResultReferenceRangeEntity(low: $low, high: $high)';
}


}

/// @nodoc
abstract mixin class $LabResultReferenceRangeEntityCopyWith<$Res>  {
  factory $LabResultReferenceRangeEntityCopyWith(LabResultReferenceRangeEntity value, $Res Function(LabResultReferenceRangeEntity) _then) = _$LabResultReferenceRangeEntityCopyWithImpl;
@useResult
$Res call({
 double low, double high
});




}
/// @nodoc
class _$LabResultReferenceRangeEntityCopyWithImpl<$Res>
    implements $LabResultReferenceRangeEntityCopyWith<$Res> {
  _$LabResultReferenceRangeEntityCopyWithImpl(this._self, this._then);

  final LabResultReferenceRangeEntity _self;
  final $Res Function(LabResultReferenceRangeEntity) _then;

/// Create a copy of LabResultReferenceRangeEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? low = null,Object? high = null,}) {
  return _then(_self.copyWith(
low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LabResultReferenceRangeEntity].
extension LabResultReferenceRangeEntityPatterns on LabResultReferenceRangeEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabResultReferenceRangeEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabResultReferenceRangeEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabResultReferenceRangeEntity value)  $default,){
final _that = this;
switch (_that) {
case _LabResultReferenceRangeEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabResultReferenceRangeEntity value)?  $default,){
final _that = this;
switch (_that) {
case _LabResultReferenceRangeEntity() when $default != null:
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
case _LabResultReferenceRangeEntity() when $default != null:
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
case _LabResultReferenceRangeEntity():
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
case _LabResultReferenceRangeEntity() when $default != null:
return $default(_that.low,_that.high);case _:
  return null;

}
}

}

/// @nodoc


class _LabResultReferenceRangeEntity extends LabResultReferenceRangeEntity {
  const _LabResultReferenceRangeEntity({required this.low, required this.high}): super._();
  

@override final  double low;
@override final  double high;

/// Create a copy of LabResultReferenceRangeEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabResultReferenceRangeEntityCopyWith<_LabResultReferenceRangeEntity> get copyWith => __$LabResultReferenceRangeEntityCopyWithImpl<_LabResultReferenceRangeEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabResultReferenceRangeEntity&&(identical(other.low, low) || other.low == low)&&(identical(other.high, high) || other.high == high));
}


@override
int get hashCode => Object.hash(runtimeType,low,high);

@override
String toString() {
  return 'LabResultReferenceRangeEntity(low: $low, high: $high)';
}


}

/// @nodoc
abstract mixin class _$LabResultReferenceRangeEntityCopyWith<$Res> implements $LabResultReferenceRangeEntityCopyWith<$Res> {
  factory _$LabResultReferenceRangeEntityCopyWith(_LabResultReferenceRangeEntity value, $Res Function(_LabResultReferenceRangeEntity) _then) = __$LabResultReferenceRangeEntityCopyWithImpl;
@override @useResult
$Res call({
 double low, double high
});




}
/// @nodoc
class __$LabResultReferenceRangeEntityCopyWithImpl<$Res>
    implements _$LabResultReferenceRangeEntityCopyWith<$Res> {
  __$LabResultReferenceRangeEntityCopyWithImpl(this._self, this._then);

  final _LabResultReferenceRangeEntity _self;
  final $Res Function(_LabResultReferenceRangeEntity) _then;

/// Create a copy of LabResultReferenceRangeEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? low = null,Object? high = null,}) {
  return _then(_LabResultReferenceRangeEntity(
low: null == low ? _self.low : low // ignore: cast_nullable_to_non_nullable
as double,high: null == high ? _self.high : high // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}

// dart format on
