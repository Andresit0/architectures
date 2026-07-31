// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_service_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClinicalHistoryServiceDto {

 String get code; String get name; String get category;
/// Create a copy of ClinicalHistoryServiceDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryServiceDtoCopyWith<ClinicalHistoryServiceDto> get copyWith => _$ClinicalHistoryServiceDtoCopyWithImpl<ClinicalHistoryServiceDto>(this as ClinicalHistoryServiceDto, _$identity);

  /// Serializes this ClinicalHistoryServiceDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryServiceDto&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,category);

@override
String toString() {
  return 'ClinicalHistoryServiceDto(code: $code, name: $name, category: $category)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryServiceDtoCopyWith<$Res>  {
  factory $ClinicalHistoryServiceDtoCopyWith(ClinicalHistoryServiceDto value, $Res Function(ClinicalHistoryServiceDto) _then) = _$ClinicalHistoryServiceDtoCopyWithImpl;
@useResult
$Res call({
 String code, String name, String category
});




}
/// @nodoc
class _$ClinicalHistoryServiceDtoCopyWithImpl<$Res>
    implements $ClinicalHistoryServiceDtoCopyWith<$Res> {
  _$ClinicalHistoryServiceDtoCopyWithImpl(this._self, this._then);

  final ClinicalHistoryServiceDto _self;
  final $Res Function(ClinicalHistoryServiceDto) _then;

/// Create a copy of ClinicalHistoryServiceDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? name = null,Object? category = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ClinicalHistoryServiceDto].
extension ClinicalHistoryServiceDtoPatterns on ClinicalHistoryServiceDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryServiceDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryServiceDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryServiceDto value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryServiceDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryServiceDto value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryServiceDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String name,  String category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClinicalHistoryServiceDto() when $default != null:
return $default(_that.code,_that.name,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String name,  String category)  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryServiceDto():
return $default(_that.code,_that.name,_that.category);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String name,  String category)?  $default,) {final _that = this;
switch (_that) {
case _ClinicalHistoryServiceDto() when $default != null:
return $default(_that.code,_that.name,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClinicalHistoryServiceDto implements ClinicalHistoryServiceDto {
  const _ClinicalHistoryServiceDto({required this.code, required this.name, required this.category});
  factory _ClinicalHistoryServiceDto.fromJson(Map<String, dynamic> json) => _$ClinicalHistoryServiceDtoFromJson(json);

@override final  String code;
@override final  String name;
@override final  String category;

/// Create a copy of ClinicalHistoryServiceDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryServiceDtoCopyWith<_ClinicalHistoryServiceDto> get copyWith => __$ClinicalHistoryServiceDtoCopyWithImpl<_ClinicalHistoryServiceDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicalHistoryServiceDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryServiceDto&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,category);

@override
String toString() {
  return 'ClinicalHistoryServiceDto(code: $code, name: $name, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryServiceDtoCopyWith<$Res> implements $ClinicalHistoryServiceDtoCopyWith<$Res> {
  factory _$ClinicalHistoryServiceDtoCopyWith(_ClinicalHistoryServiceDto value, $Res Function(_ClinicalHistoryServiceDto) _then) = __$ClinicalHistoryServiceDtoCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String category
});




}
/// @nodoc
class __$ClinicalHistoryServiceDtoCopyWithImpl<$Res>
    implements _$ClinicalHistoryServiceDtoCopyWith<$Res> {
  __$ClinicalHistoryServiceDtoCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryServiceDto _self;
  final $Res Function(_ClinicalHistoryServiceDto) _then;

/// Create a copy of ClinicalHistoryServiceDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? category = null,}) {
  return _then(_ClinicalHistoryServiceDto(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
