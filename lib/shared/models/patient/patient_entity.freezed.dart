// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PatientEntity {

 String get name; String get id;
/// Create a copy of PatientEntity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PatientEntityCopyWith<PatientEntity> get copyWith => _$PatientEntityCopyWithImpl<PatientEntity>(this as PatientEntity, _$identity);

  /// Serializes this PatientEntity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PatientEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,id);

@override
String toString() {
  return 'PatientEntity(name: $name, id: $id)';
}


}

/// @nodoc
abstract mixin class $PatientEntityCopyWith<$Res>  {
  factory $PatientEntityCopyWith(PatientEntity value, $Res Function(PatientEntity) _then) = _$PatientEntityCopyWithImpl;
@useResult
$Res call({
 String name, String id
});




}
/// @nodoc
class _$PatientEntityCopyWithImpl<$Res>
    implements $PatientEntityCopyWith<$Res> {
  _$PatientEntityCopyWithImpl(this._self, this._then);

  final PatientEntity _self;
  final $Res Function(PatientEntity) _then;

/// Create a copy of PatientEntity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? id = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PatientEntity].
extension PatientEntityPatterns on PatientEntity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PatientEntity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PatientEntity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PatientEntity value)  $default,){
final _that = this;
switch (_that) {
case _PatientEntity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PatientEntity value)?  $default,){
final _that = this;
switch (_that) {
case _PatientEntity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String id)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PatientEntity() when $default != null:
return $default(_that.name,_that.id);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String id)  $default,) {final _that = this;
switch (_that) {
case _PatientEntity():
return $default(_that.name,_that.id);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String id)?  $default,) {final _that = this;
switch (_that) {
case _PatientEntity() when $default != null:
return $default(_that.name,_that.id);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PatientEntity extends PatientEntity {
  const _PatientEntity({required this.name, required this.id}): super._();
  factory _PatientEntity.fromJson(Map<String, dynamic> json) => _$PatientEntityFromJson(json);

@override final  String name;
@override final  String id;

/// Create a copy of PatientEntity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PatientEntityCopyWith<_PatientEntity> get copyWith => __$PatientEntityCopyWithImpl<_PatientEntity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PatientEntityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PatientEntity&&(identical(other.name, name) || other.name == name)&&(identical(other.id, id) || other.id == id));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,id);

@override
String toString() {
  return 'PatientEntity(name: $name, id: $id)';
}


}

/// @nodoc
abstract mixin class _$PatientEntityCopyWith<$Res> implements $PatientEntityCopyWith<$Res> {
  factory _$PatientEntityCopyWith(_PatientEntity value, $Res Function(_PatientEntity) _then) = __$PatientEntityCopyWithImpl;
@override @useResult
$Res call({
 String name, String id
});




}
/// @nodoc
class __$PatientEntityCopyWithImpl<$Res>
    implements _$PatientEntityCopyWith<$Res> {
  __$PatientEntityCopyWithImpl(this._self, this._then);

  final _PatientEntity _self;
  final $Res Function(_PatientEntity) _then;

/// Create a copy of PatientEntity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? id = null,}) {
  return _then(_PatientEntity(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
