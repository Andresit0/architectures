// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_facility_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClinicalHistoryFacilityDto {

 String get id; String get name; String get city;
/// Create a copy of ClinicalHistoryFacilityDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryFacilityDtoCopyWith<ClinicalHistoryFacilityDto> get copyWith => _$ClinicalHistoryFacilityDtoCopyWithImpl<ClinicalHistoryFacilityDto>(this as ClinicalHistoryFacilityDto, _$identity);

  /// Serializes this ClinicalHistoryFacilityDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryFacilityDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city);

@override
String toString() {
  return 'ClinicalHistoryFacilityDto(id: $id, name: $name, city: $city)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryFacilityDtoCopyWith<$Res>  {
  factory $ClinicalHistoryFacilityDtoCopyWith(ClinicalHistoryFacilityDto value, $Res Function(ClinicalHistoryFacilityDto) _then) = _$ClinicalHistoryFacilityDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name, String city
});




}
/// @nodoc
class _$ClinicalHistoryFacilityDtoCopyWithImpl<$Res>
    implements $ClinicalHistoryFacilityDtoCopyWith<$Res> {
  _$ClinicalHistoryFacilityDtoCopyWithImpl(this._self, this._then);

  final ClinicalHistoryFacilityDto _self;
  final $Res Function(ClinicalHistoryFacilityDto) _then;

/// Create a copy of ClinicalHistoryFacilityDto
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


/// Adds pattern-matching-related methods to [ClinicalHistoryFacilityDto].
extension ClinicalHistoryFacilityDtoPatterns on ClinicalHistoryFacilityDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryFacilityDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryFacilityDto value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryFacilityDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryFacilityDto() when $default != null:
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
case _ClinicalHistoryFacilityDto() when $default != null:
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
case _ClinicalHistoryFacilityDto():
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
case _ClinicalHistoryFacilityDto() when $default != null:
return $default(_that.id,_that.name,_that.city);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClinicalHistoryFacilityDto implements ClinicalHistoryFacilityDto {
  const _ClinicalHistoryFacilityDto({required this.id, required this.name, required this.city});
  factory _ClinicalHistoryFacilityDto.fromJson(Map<String, dynamic> json) => _$ClinicalHistoryFacilityDtoFromJson(json);

@override final  String id;
@override final  String name;
@override final  String city;

/// Create a copy of ClinicalHistoryFacilityDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryFacilityDtoCopyWith<_ClinicalHistoryFacilityDto> get copyWith => __$ClinicalHistoryFacilityDtoCopyWithImpl<_ClinicalHistoryFacilityDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicalHistoryFacilityDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryFacilityDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.city, city) || other.city == city));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,city);

@override
String toString() {
  return 'ClinicalHistoryFacilityDto(id: $id, name: $name, city: $city)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryFacilityDtoCopyWith<$Res> implements $ClinicalHistoryFacilityDtoCopyWith<$Res> {
  factory _$ClinicalHistoryFacilityDtoCopyWith(_ClinicalHistoryFacilityDto value, $Res Function(_ClinicalHistoryFacilityDto) _then) = __$ClinicalHistoryFacilityDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String city
});




}
/// @nodoc
class __$ClinicalHistoryFacilityDtoCopyWithImpl<$Res>
    implements _$ClinicalHistoryFacilityDtoCopyWith<$Res> {
  __$ClinicalHistoryFacilityDtoCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryFacilityDto _self;
  final $Res Function(_ClinicalHistoryFacilityDto) _then;

/// Create a copy of ClinicalHistoryFacilityDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? city = null,}) {
  return _then(_ClinicalHistoryFacilityDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
