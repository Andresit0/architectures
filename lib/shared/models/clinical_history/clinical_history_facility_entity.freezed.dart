// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_facility_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClinicalHistoryFacilityEntity {

 String get id; String get name; String get city;
/// Create a copy of ClinicalHistoryFacilityEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryFacilityEntityCopyWith<ClinicalHistoryFacilityEntity> get copyWith => _$ClinicalHistoryFacilityEntityCopyWithImpl<ClinicalHistoryFacilityEntity>(this as ClinicalHistoryFacilityEntity, _$identity);

  /// Serializes this ClinicalHistoryFacilityEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryFacilityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city);

@override
String toString() {
  return 'ClinicalHistoryFacilityEntity(id: $id, name: $name, city: $city)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryFacilityEntityCopyWith<$Res>  {
  factory $ClinicalHistoryFacilityEntityCopyWith(ClinicalHistoryFacilityEntity value, $Res Function(ClinicalHistoryFacilityEntity) _then) = _$ClinicalHistoryFacilityEntityCopyWithImpl;
@useResult
$Res call({
 String id, String name, String city
});




}
/// @nodoc
class _$ClinicalHistoryFacilityEntityCopyWithImpl<$Res>
    implements $ClinicalHistoryFacilityEntityCopyWith<$Res> {
  _$ClinicalHistoryFacilityEntityCopyWithImpl(this._self, this._then);

  final ClinicalHistoryFacilityEntity _self;
  final $Res Function(ClinicalHistoryFacilityEntity) _then;

/// Create a copy of ClinicalHistoryFacilityEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? city = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalHistoryFacilityEntity].
extension ClinicalHistoryFacilityEntityPatterns on ClinicalHistoryFacilityEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryFacilityEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryFacilityEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryFacilityEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String city)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityEntity() when $default != null:
return $default(_that.id,_that.name,_that.city);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String city)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityEntity():
return $default(_that.id,_that.name,_that.city);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String city)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityEntity() when $default != null:
return $default(_that.id,_that.name,_that.city);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClinicalHistoryFacilityEntity extends ClinicalHistoryFacilityEntity {
  const _ClinicalHistoryFacilityEntity({required this.id, required this.name, required this.city}): super._();
  factory _ClinicalHistoryFacilityEntity.fromJson(Map<String, dynamic> json) => _$ClinicalHistoryFacilityEntityFromJson(json);

@override final  String id;
@override final  String name;
@override final  String city;

/// Create a copy of ClinicalHistoryFacilityEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryFacilityEntityCopyWith<_ClinicalHistoryFacilityEntity> get copyWith => __$ClinicalHistoryFacilityEntityCopyWithImpl<_ClinicalHistoryFacilityEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicalHistoryFacilityEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryFacilityEntity&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city);

@override
String toString() {
  return 'ClinicalHistoryFacilityEntity(id: $id, name: $name, city: $city)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryFacilityEntityCopyWith<$Res> implements $ClinicalHistoryFacilityEntityCopyWith<$Res> {
  factory _$ClinicalHistoryFacilityEntityCopyWith(_ClinicalHistoryFacilityEntity value, $Res Function(_ClinicalHistoryFacilityEntity) _then) = __$ClinicalHistoryFacilityEntityCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String city
});




}
/// @nodoc
class __$ClinicalHistoryFacilityEntityCopyWithImpl<$Res>
    implements _$ClinicalHistoryFacilityEntityCopyWith<$Res> {
  __$ClinicalHistoryFacilityEntityCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryFacilityEntity _self;
  final $Res Function(_ClinicalHistoryFacilityEntity) _then;

/// Create a copy of ClinicalHistoryFacilityEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? city = null,}) {
  return _then(_ClinicalHistoryFacilityEntity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
