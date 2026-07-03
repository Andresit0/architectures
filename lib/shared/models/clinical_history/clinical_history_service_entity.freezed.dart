// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_history_service_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClinicalHistoryServiceEntity {

 String get code; String get name; String get category;
/// Create a copy of ClinicalHistoryServiceEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClinicalHistoryServiceEntityCopyWith<ClinicalHistoryServiceEntity> get copyWith => _$ClinicalHistoryServiceEntityCopyWithImpl<ClinicalHistoryServiceEntity>(this as ClinicalHistoryServiceEntity, _$identity);

  /// Serializes this ClinicalHistoryServiceEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClinicalHistoryServiceEntity&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,category);

@override
String toString() {
  return 'ClinicalHistoryServiceEntity(code: $code, name: $name, category: $category)';
}


}

/// @nodoc
abstract mixin class $ClinicalHistoryServiceEntityCopyWith<$Res>  {
  factory $ClinicalHistoryServiceEntityCopyWith(ClinicalHistoryServiceEntity value, $Res Function(ClinicalHistoryServiceEntity) _then) = _$ClinicalHistoryServiceEntityCopyWithImpl;
@useResult
$Res call({
 String code, String name, String category
});




}
/// @nodoc
class _$ClinicalHistoryServiceEntityCopyWithImpl<$Res>
    implements $ClinicalHistoryServiceEntityCopyWith<$Res> {
  _$ClinicalHistoryServiceEntityCopyWithImpl(this._self, this._then);

  final ClinicalHistoryServiceEntity _self;
  final $Res Function(ClinicalHistoryServiceEntity) _then;

/// Create a copy of ClinicalHistoryServiceEntity
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


/// Adds pattern-matching-related methods to [ClinicalHistoryServiceEntity].
extension ClinicalHistoryServiceEntityPatterns on ClinicalHistoryServiceEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClinicalHistoryServiceEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClinicalHistoryServiceEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClinicalHistoryServiceEntity value)  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryServiceEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClinicalHistoryServiceEntity value)?  $default,){
final _that = this;
switch (_that) {
case _ClinicalHistoryServiceEntity() when $default != null:
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
case _ClinicalHistoryServiceEntity() when $default != null:
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
case _ClinicalHistoryServiceEntity():
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
case _ClinicalHistoryServiceEntity() when $default != null:
return $default(_that.code,_that.name,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClinicalHistoryServiceEntity extends ClinicalHistoryServiceEntity {
  const _ClinicalHistoryServiceEntity({required this.code, required this.name, required this.category}): super._();
  factory _ClinicalHistoryServiceEntity.fromJson(Map<String, dynamic> json) => _$ClinicalHistoryServiceEntityFromJson(json);

@override final  String code;
@override final  String name;
@override final  String category;

/// Create a copy of ClinicalHistoryServiceEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClinicalHistoryServiceEntityCopyWith<_ClinicalHistoryServiceEntity> get copyWith => __$ClinicalHistoryServiceEntityCopyWithImpl<_ClinicalHistoryServiceEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClinicalHistoryServiceEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClinicalHistoryServiceEntity&&(identical(other.code, code) || other.code == code)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,name,category);

@override
String toString() {
  return 'ClinicalHistoryServiceEntity(code: $code, name: $name, category: $category)';
}


}

/// @nodoc
abstract mixin class _$ClinicalHistoryServiceEntityCopyWith<$Res> implements $ClinicalHistoryServiceEntityCopyWith<$Res> {
  factory _$ClinicalHistoryServiceEntityCopyWith(_ClinicalHistoryServiceEntity value, $Res Function(_ClinicalHistoryServiceEntity) _then) = __$ClinicalHistoryServiceEntityCopyWithImpl;
@override @useResult
$Res call({
 String code, String name, String category
});




}
/// @nodoc
class __$ClinicalHistoryServiceEntityCopyWithImpl<$Res>
    implements _$ClinicalHistoryServiceEntityCopyWith<$Res> {
  __$ClinicalHistoryServiceEntityCopyWithImpl(this._self, this._then);

  final _ClinicalHistoryServiceEntity _self;
  final $Res Function(_ClinicalHistoryServiceEntity) _then;

/// Create a copy of ClinicalHistoryServiceEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? name = null,Object? category = null,}) {
  return _then(_ClinicalHistoryServiceEntity(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
