// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_state_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicalHistoryStateEntity {

 String get code; String get label;
/// Create a copy of ClinicalHistoryStateEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryStateEntityCopyWith<ClinicalHistoryStateEntity> get copyWith => _$ClinicalHistoryStateEntityCopyWithImpl<ClinicalHistoryStateEntity>(this as ClinicalHistoryStateEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryStateEntity&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,code,label);

@override
String toString() {
  return 'ClinicalHistoryStateEntity(code: $code, label: $label)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryStateEntityCopyWith<$Res>  {
  factory $ClinicalHistoryStateEntityCopyWith(ClinicalHistoryStateEntity value, $Res Function(ClinicalHistoryStateEntity) _then) = _$ClinicalHistoryStateEntityCopyWithImpl;
@useResult
$Res call({
 String code, String label
});




}
/// @nodoc
class _$ClinicalHistoryStateEntityCopyWithImpl<$Res>
    implements $ClinicalHistoryStateEntityCopyWith<$Res> {
  _$ClinicalHistoryStateEntityCopyWithImpl(this._self, this._then);

  final ClinicalHistoryStateEntity _self;
  final $Res Function(ClinicalHistoryStateEntity) _then;

/// Create a copy of ClinicalHistoryStateEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? label = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalHistoryStateEntity].
extension ClinicalHistoryStateEntityPatterns on ClinicalHistoryStateEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryStateEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryStateEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryStateEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryStateEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryStateEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryStateEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryStateEntity() when $default != null:
return $default(_that.code,_that.label);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String label)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryStateEntity():
return $default(_that.code,_that.label);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String label)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryStateEntity() when $default != null:
return $default(_that.code,_that.label);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicalHistoryStateEntity extends ClinicalHistoryStateEntity {
  const _ClinicalHistoryStateEntity({required this.code, required this.label}): super._();
  

@override final  String code;
@override final  String label;

/// Create a copy of ClinicalHistoryStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryStateEntityCopyWith<_ClinicalHistoryStateEntity> get copyWith => __$ClinicalHistoryStateEntityCopyWithImpl<_ClinicalHistoryStateEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryStateEntity&&(identical(other.code, code) || other.code == code)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,code,label);

@override
String toString() {
  return 'ClinicalHistoryStateEntity(code: $code, label: $label)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryStateEntityCopyWith<$Res> implements $ClinicalHistoryStateEntityCopyWith<$Res> {
  factory _$ClinicalHistoryStateEntityCopyWith(_ClinicalHistoryStateEntity value, $Res Function(_ClinicalHistoryStateEntity) _then) = __$ClinicalHistoryStateEntityCopyWithImpl;
@override @useResult
$Res call({
 String code, String label
});




}
/// @nodoc
class __$ClinicalHistoryStateEntityCopyWithImpl<$Res>
    implements _$ClinicalHistoryStateEntityCopyWith<$Res> {
  __$ClinicalHistoryStateEntityCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryStateEntity _self;
  final $Res Function(_ClinicalHistoryStateEntity) _then;

/// Create a copy of ClinicalHistoryStateEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? label = null,}) {
  return _then(_ClinicalHistoryStateEntity(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
