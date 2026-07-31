// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_professional_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClinicalHistoryProfessionalEntity {

 String get id; String get fullname; String get specialty;
/// Create a copy of ClinicalHistoryProfessionalEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryProfessionalEntityCopyWith<ClinicalHistoryProfessionalEntity> get copyWith => _$ClinicalHistoryProfessionalEntityCopyWithImpl<ClinicalHistoryProfessionalEntity>(this as ClinicalHistoryProfessionalEntity, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryProfessionalEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.fullname, fullname) || other.fullname == fullname)&&(identical(other.specialty, specialty) || other.specialty == specialty));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullname,specialty);

@override
String toString() {
  return 'ClinicalHistoryProfessionalEntity(id: $id, fullname: $fullname, specialty: $specialty)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryProfessionalEntityCopyWith<$Res>  {
  factory $ClinicalHistoryProfessionalEntityCopyWith(ClinicalHistoryProfessionalEntity value, $Res Function(ClinicalHistoryProfessionalEntity) _then) = _$ClinicalHistoryProfessionalEntityCopyWithImpl;
@useResult
$Res call({
 String id, String fullname, String specialty
});




}
/// @nodoc
class _$ClinicalHistoryProfessionalEntityCopyWithImpl<$Res>
    implements $ClinicalHistoryProfessionalEntityCopyWith<$Res> {
  _$ClinicalHistoryProfessionalEntityCopyWithImpl(this._self, this._then);

  final ClinicalHistoryProfessionalEntity _self;
  final $Res Function(ClinicalHistoryProfessionalEntity) _then;

/// Create a copy of ClinicalHistoryProfessionalEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? fullname = null,Object? specialty = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullname: null == fullname ? _self.fullname : fullname // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalHistoryProfessionalEntity].
extension ClinicalHistoryProfessionalEntityPatterns on ClinicalHistoryProfessionalEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryProfessionalEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryProfessionalEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryProfessionalEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryProfessionalEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryProfessionalEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryProfessionalEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String fullname,  String specialty)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryProfessionalEntity() when $default != null:
return $default(_that.id,_that.fullname,_that.specialty);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String fullname,  String specialty)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryProfessionalEntity():
return $default(_that.id,_that.fullname,_that.specialty);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String fullname,  String specialty)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryProfessionalEntity() when $default != null:
return $default(_that.id,_that.fullname,_that.specialty);case _:
  return null;

}
}

}

/// @nodoc


class _ClinicalHistoryProfessionalEntity extends ClinicalHistoryProfessionalEntity {
  const _ClinicalHistoryProfessionalEntity({required this.id, required this.fullname, required this.specialty}): super._();
  

@override final  String id;
@override final  String fullname;
@override final  String specialty;

/// Create a copy of ClinicalHistoryProfessionalEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryProfessionalEntityCopyWith<_ClinicalHistoryProfessionalEntity> get copyWith => __$ClinicalHistoryProfessionalEntityCopyWithImpl<_ClinicalHistoryProfessionalEntity>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryProfessionalEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.fullname, fullname) || other.fullname == fullname)&&(identical(other.specialty, specialty) || other.specialty == specialty));
}


@override
int get hashCode => Object.hash(runtimeType,id,fullname,specialty);

@override
String toString() {
  return 'ClinicalHistoryProfessionalEntity(id: $id, fullname: $fullname, specialty: $specialty)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryProfessionalEntityCopyWith<$Res> implements $ClinicalHistoryProfessionalEntityCopyWith<$Res> {
  factory _$ClinicalHistoryProfessionalEntityCopyWith(_ClinicalHistoryProfessionalEntity value, $Res Function(_ClinicalHistoryProfessionalEntity) _then) = __$ClinicalHistoryProfessionalEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String fullname, String specialty
});




}
/// @nodoc
class __$ClinicalHistoryProfessionalEntityCopyWithImpl<$Res>
    implements _$ClinicalHistoryProfessionalEntityCopyWith<$Res> {
  __$ClinicalHistoryProfessionalEntityCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryProfessionalEntity _self;
  final $Res Function(_ClinicalHistoryProfessionalEntity) _then;

/// Create a copy of ClinicalHistoryProfessionalEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? fullname = null,Object? specialty = null,}) {
  return _then(_ClinicalHistoryProfessionalEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,fullname: null == fullname ? _self.fullname : fullname // ignore: cast_nullable_to_non_nullable
as String,specialty: null == specialty ? _self.specialty : specialty // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
