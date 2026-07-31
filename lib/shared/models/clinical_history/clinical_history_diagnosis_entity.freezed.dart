// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_diagnosis_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicalHistoryDiagnosisEntity {

 String get code; String get name;
/// Create a copy of ClinicalHistoryDiagnosisEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryDiagnosisEntityCopyWith<ClinicalHistoryDiagnosisEntity> get copyWith => _$ClinicalHistoryDiagnosisEntityCopyWithImpl<ClinicalHistoryDiagnosisEntity>(this as ClinicalHistoryDiagnosisEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryDiagnosisEntity&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'ClinicalHistoryDiagnosisEntity(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryDiagnosisEntityCopyWith<$Res>  {
  factory $ClinicalHistoryDiagnosisEntityCopyWith(ClinicalHistoryDiagnosisEntity value, $Res Function(ClinicalHistoryDiagnosisEntity) _then) = _$ClinicalHistoryDiagnosisEntityCopyWithImpl;
@useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class _$ClinicalHistoryDiagnosisEntityCopyWithImpl<$Res>
    implements $ClinicalHistoryDiagnosisEntityCopyWith<$Res> {
  _$ClinicalHistoryDiagnosisEntityCopyWithImpl(this._self, this._then);

  final ClinicalHistoryDiagnosisEntity _self;
  final $Res Function(ClinicalHistoryDiagnosisEntity) _then;

/// Create a copy of ClinicalHistoryDiagnosisEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalHistoryDiagnosisEntity].
extension ClinicalHistoryDiagnosisEntityPatterns on ClinicalHistoryDiagnosisEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryDiagnosisEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryDiagnosisEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryDiagnosisEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryDiagnosisEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryDiagnosisEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryDiagnosisEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryDiagnosisEntity() when $default != null:
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryDiagnosisEntity():
return $default(_that.code,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryDiagnosisEntity() when $default != null:
return $default(_that.code,_that.name);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicalHistoryDiagnosisEntity extends ClinicalHistoryDiagnosisEntity {
  const _ClinicalHistoryDiagnosisEntity({required this.code, required this.name}): super._();
  

@override final  String code;
@override final  String name;

/// Create a copy of ClinicalHistoryDiagnosisEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryDiagnosisEntityCopyWith<_ClinicalHistoryDiagnosisEntity> get copyWith => __$ClinicalHistoryDiagnosisEntityCopyWithImpl<_ClinicalHistoryDiagnosisEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryDiagnosisEntity&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name));
}


@override
int get hashCode => Object.hash(runtimeType,code,name);

@override
String toString() {
  return 'ClinicalHistoryDiagnosisEntity(code: $code, name: $name)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryDiagnosisEntityCopyWith<$Res> implements $ClinicalHistoryDiagnosisEntityCopyWith<$Res> {
  factory _$ClinicalHistoryDiagnosisEntityCopyWith(_ClinicalHistoryDiagnosisEntity value, $Res Function(_ClinicalHistoryDiagnosisEntity) _then) = __$ClinicalHistoryDiagnosisEntityCopyWithImpl;
@override @useResult
$Res call({
 String code, String name
});




}
/// @nodoc
class __$ClinicalHistoryDiagnosisEntityCopyWithImpl<$Res>
    implements _$ClinicalHistoryDiagnosisEntityCopyWith<$Res> {
  __$ClinicalHistoryDiagnosisEntityCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryDiagnosisEntity _self;
  final $Res Function(_ClinicalHistoryDiagnosisEntity) _then;

/// Create a copy of ClinicalHistoryDiagnosisEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,}) {
  return _then(_ClinicalHistoryDiagnosisEntity(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
